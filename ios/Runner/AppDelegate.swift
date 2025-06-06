import UIKit
import Flutter
import Foundation
import CryptoKit
import Security
import LocalAuthentication

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private let CHANNEL = "chrono_encryption"
  private let service = "com.example.chronosync"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      
      guard let args = call.arguments as? [String: Any],
        let alias = args["alias"] as? String, !alias.isEmpty else {
          result(FlutterError(code: "INVALID_ALIAS", message: "Alias is null or empty", details: nil))
          return
        }

      switch call.method {
        case "encrypt":
          guard let rawUser = args["rawUser"] as? String, let rawPass = args["rawPass"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing input", details: nil))
            return
          }

          let rawBytes = self.concatBytes(userString: rawUser, passString: rawPass)

          do {
            let encrypted = try self.encrypt(rawBytes: rawBytes, alias: alias)
            result(encrypted)
          } catch {
            result(FlutterError(code: "ENCRYPTION_FAILED", message: error.localizedDescription, details: nil))
          }


        case "decrypt":
          guard let cipherText = args["cipherText"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing cipherText", details: nil))
            return
          }

          do {
            let decrypted = try self.decrypt(cipher64: cipherText, alias: alias)
            if let (decryptedUser, decryptedPass) = self.splitBytes(decrypted) {
              result(["privateUser": decryptedUser, "privatePass": decryptedPass])
            } else {
              throw NSError(domain: "DECRYPT_SPLIT_FAILED", code: -1)
            }
          } catch {
            result(FlutterError(code: "DECRYPTION_FAILED", message: error.localizedDescription, details: nil))
          }

        case "remove":
          result(remove(alias: alias))

        default:
          result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  enum AuthRes {
    case Success(SymmetricKey)
    case Failure(String)
  }

  func initKey(alias: String) throws -> AuthRes {
    let context = LAContext()
    context.interactionNotAllowed = false

    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: alias,
        kSecAttrService as String: service,
        kSecReturnData as String: true,
        kSecUseAuthenticationContext as String: context,
        kSecMatchLimit as String: kSecMatchLimitOne
    ]

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)

    if status == errSecSuccess, let data = item as? Data {
      let key = SymmetricKey(data: data)
      return .Success(key)
    } else if status == errSecUserCanceled {
      let reason = "canceled"
      return .Failure(reason)
    }

    // no existing key -> generate new + store in keychain
    if status == errSecItemNotFound {
        let key = SymmetricKey(size: .bits256)
        let keyData = key.withUnsafeBytes { Data($0) }

        let accessControl = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .userPresence,
            nil
        )!

        let storeQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: alias,
            kSecAttrService as String: service,
            kSecAttrAccessControl as String: accessControl,
            kSecUseAuthenticationContext as String: context,
            kSecValueData as String: keyData
        ]

        let storeStatus = SecItemAdd(storeQuery as CFDictionary, nil)
        if storeStatus != errSecSuccess {
          throw NSError(domain: "KeychainError", code: Int(storeStatus), userInfo: [NSLocalizedDescriptionKey: "Failed to store new key"])
        }

        return .Success(key)
    }

    // unknown error
    throw NSError(domain: "KeychainError", code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve key"])
  }

  private func concatBytes(userString: String, passString: String) -> Data {
    var data = Data()
    for str in [userString, passString] {
      let bytes = str.data(using: .utf8)!
      var len = UInt32(bytes.count).bigEndian
      data.append(Data(bytes: &len, count: 4))
      data.append(bytes)
    }
    return data
  }

  private func splitBytes(_ raw: Data) -> (String, String)? {
    var offset = 0

    func nextString() -> String? {
      guard raw.count >= offset + 4 else { return nil }
      let len = raw.subdata(in: offset..<offset+4).withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
      offset += 4
      guard raw.count >= offset + Int(len) else { return nil }
      let strData = raw.subdata(in: offset..<offset+Int(len))
      offset += Int(len)
      return String(data: strData, encoding: .utf8)
    }

    guard let user = nextString(), let pass = nextString() else { return nil }
    return (user, pass)
  }

  private func encrypt(rawBytes: Data, alias: String) throws -> String {
    let authRes = try initKey(alias: alias)

    switch authRes {
      case .Failure(let reason):
        return reason
      
      case .Success(let key):
        let sealed = try AES.GCM.seal(rawBytes, using: key)
        guard let uniqueCipher = sealed.combined else {
          throw NSError(domain: "ENCRYPTION_FAILED", code: -1)
        }
        return uniqueCipher.base64EncodedString()
    }
  }

  private func decrypt(cipher64: String, alias: String) throws -> Data {
    guard let encrypted = Data(base64Encoded: cipher64) else {
      throw NSError(domain: "INVALID_CIPHERTEXT", code: -1, userInfo: nil)
    }

    let sealedBox = try AES.GCM.SealedBox(combined: encrypted)
    let authRes = try initKey(alias: alias)

    switch authRes {
      case .Failure(let reason):
        return concatBytes(userString: reason, passString: reason)
      
      case .Success(let key):
        return try AES.GCM.open(sealedBox, using: key)
    }
  }

  private func remove(alias: String) -> Bool {
    let tag = alias.data(using: .utf8)!
    let query: [String: Any] = [
      kSecClass as String: kSecClassKey,
      kSecAttrApplicationTag as String: tag,
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom
    ]
    let status = SecItemDelete(query as CFDictionary)
    return status == errSecSuccess
  }
}

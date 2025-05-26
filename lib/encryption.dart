import 'dart:async';
// import 'package:flutter/material.dart';
import 'package:chronosync/secure.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

import 'package:shared_preferences/shared_preferences.dart';

class SecureDataCache {
  static final SecureDataCache single = SecureDataCache._internal();

  factory SecureDataCache() {
    return single;
  }

  String? user, pass;

  SecureDataCache._internal();

  bool userCached() {
    return single.user != null && single.pass != null;
  }

  Future<bool> userSaved() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? secure_ = prefs.getString("secureUser");
    return secure_ != null;
  }

  Future<bool> loadMemory() async {
    // print("loadMemory() triggered");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? secure_ = prefs.getString("secureUser");

    if (secure_ == null) {
      // print("no user on disk");
      return false;
    }

    ({String user_, String pass_}) private = await EncryptionInterface.decrypt(secure_);
    String? user_ = private.user_;
    String? pass_ = private.pass_;

    // print("decrypt complete");

    if (user_.isEmpty || pass_.isEmpty) {
      return false;
    }

    if (user_ == "failed" || pass_ == "failed") {
      // print("decryption failed authentication");
      return false;
    }

    if (user_ == "cancelled" || pass_ == "cancelled") {
      // print("cancelled authentication");
      single.pass = pass_;
      return false;
    }

    single.user = user_;
    single.pass = pass_;

    return true;
  }

  Future<bool> storeDevice(String userRaw, String passRaw) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String secure = await EncryptionInterface.encrypt(userRaw, passRaw);

    if (secure.isEmpty) {
      // print("got nothin back - encryption");
      return false;
    }

    if (secure == "failed" || secure == "cancelled") {
      // print("encryption failed or cancelled authentication");
      return false;
    }

    await prefs.setString("secureUser", secure);

    single.user = userRaw;
    single.pass = passRaw;

    return true;
  }

  bool authCancelled() {
    return single.user == "cancelled" || single.pass == "cancelled";
  }

  bool authFailed() {
    return single.user == "failed" || single.pass == "failed";
  }

  void pause() {
    single.pass = null;
  }

  void clear({bool removeKey = false}) {
    single.user = null;
    single.pass = null;

    if (removeKey) {
      EncryptionInterface.remove();
    }
  }
}

class EncryptionInterface {
  static const MethodChannel _channel = MethodChannel('chrono_encryption');

  static Future<String> encrypt(String rawUser, String rawPass) async {
    String keyAliasAccount = await initKeyAlias();
    if (Platform.isAndroid || Platform.isIOS) {
      final String? encrypted = await _channel.invokeMethod<String>(
        'encrypt',
        {'rawUser': rawUser, 'rawPass': rawPass, 'alias': keyAliasAccount},
      );

      return encrypted ?? '';
    } else {
      throw UnsupportedError('Unsupported platform - Encryption');
    }
  }

  static Future<({String user_, String pass_})> decrypt(String encryptedText) async {
    String keyAliasAccount = await initKeyAlias();
    if (Platform.isAndroid || Platform.isIOS) {
      final Map<String, String>? decrypted = (await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'decrypt',
        {'cipherText': encryptedText, 'alias': keyAliasAccount},
      ))?.map((key, value) => MapEntry(key.toString(), value.toString()));
      
      if (decrypted == null) {
        // print("decrypt returned null");
        return (user_: '', pass_: '');
      }

      return (user_: decrypted["privateUser"] ?? '', pass_: decrypted["privatePass"] ?? '');
    } else {
      // print("aw hell naw");
      throw UnsupportedError('Unsupported platform - Decryption');
    }
  }

  static Future<bool> remove() async {
    String keyAliasAccount = await initKeyAlias();
    if (Platform.isAndroid || Platform.isIOS) {
      final bool? removed = await _channel.invokeMethod<bool>('remove', {'alias': keyAliasAccount});

      return removed ?? false;
    } else {
      throw UnsupportedError('Unsupported platform - Remove');
    }
  }
}

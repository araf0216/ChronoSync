package com.example.chronosync

import io.flutter.embedding.android.FlutterFragmentActivity
import androidx.annotation.NonNull
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer
import android.util.Base64

import androidx.lifecycle.lifecycleScope

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.async
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.withContext
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlinx.coroutines.CancellationException

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "chrono_encryption"
    // private var alias = "ed56926a7b7c68bb8da4acae630c864d6d42400d5d96f258daf9aa9223cc8ab3"
    // private val alias = "chrono_test_secret_1005"
    private val keystore = "AndroidKeyStore"
    private val transform = "AES/GCM/NoPadding"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            val alias = call.argument<String>("alias") ?: ""
            when (call.method) {
                "encrypt" -> {
                    val rawUser = call.argument<String>("rawUser") ?: ""
                    val rawPass = call.argument<String>("rawPass") ?: ""
                    val byteData = concatBytes(rawUser, rawPass)
                    lifecycleScope.launch {
                        try {
                            val encrypted = encrypt(byteData, alias)
                            result.success(encrypted)
                        } catch (e: Exception) {
                            result.error("ENCRYPTION_FAILED", e.message, null)
                        }
                    }
                }
                "decrypt" -> {
                    val cipherText = call.argument<String>("cipherText") ?: ""
                    lifecycleScope.launch {
                        try {
                            val decryptedData = decrypt(cipherText, alias)
                            val (decryptedUser, decryptedPass) = splitBytes(decryptedData)
                            val decrypted = mapOf("privateUser" to decryptedUser, "privatePass" to decryptedPass)
                            result.success(decrypted)
                        } catch (e: Exception) {
                            result.error("DECRYPTION_FAILED", e.message, null)
                        }
                    }
                }
                "remove" -> {
                    try {
                        val keyStore = KeyStore.getInstance(keystore)
                        keyStore.load(null)

                        if (keyStore.containsAlias(alias)) {
                            keyStore.deleteEntry(alias)
                        }

                        result.success(true)
                    } catch (e: Exception) {
                        throw Exception("REMOVE_FAILED")
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun concatBytes(userString: String, passString: String): ByteArray {
        val output = ByteArrayOutputStream()
        listOf(userString, passString).forEach { str ->
            val bytes = str.toByteArray(Charsets.UTF_8)
            val lengthBytes = ByteBuffer.allocate(4).putInt(bytes.size).array()
            output.write(lengthBytes)
            output.write(bytes)
        }

        return output.toByteArray()
    }

    private fun splitBytes(raw: ByteArray): Pair<String, String> {
        var pos = 0
        fun nextString(): String {
            val length = ByteBuffer.wrap(raw, pos, 4).int
            pos += 4
            val strBytes = raw.copyOfRange(pos, pos + length)
            pos += length
            return strBytes.toString(Charsets.UTF_8)
        }

        val user: String = nextString()
        val pass: String = nextString()

        return Pair(user, pass)
    }

    private fun initKey(alias: String): SecretKey {
        val keyStore = KeyStore.getInstance(keystore).apply { load(null) }

        return if (keyStore.containsAlias(alias)) {
            (keyStore.getKey(alias, null) as SecretKey)
        } else {
            val keyGenerator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, keystore)
            val parameterSpec = KeyGenParameterSpec.Builder(
                alias,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
            )
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setUserAuthenticationRequired(true)
                .setUserAuthenticationValidityDurationSeconds(-1)
                .build()

            keyGenerator.init(parameterSpec)
            keyGenerator.generateKey()
        }
    }

    sealed class AuthRes {
        data class Success(val cipher: Cipher) : AuthRes()
        data class Failure(val reason: String) : AuthRes()
    }

    private suspend fun initAuthCipher(cipher: Cipher): AuthRes {
        return suspendCancellableCoroutine { cont ->

            val cryptoObject = BiometricPrompt.CryptoObject(cipher)
            val executor = ContextCompat.getMainExecutor(this)

            val biometricPrompt = BiometricPrompt(this, executor,
                object : BiometricPrompt.AuthenticationCallback() {
                    override fun onAuthenticationSucceeded(resultAuth: BiometricPrompt.AuthenticationResult) {
                        val resAuthCipher = resultAuth.cryptoObject?.cipher
                        if (resAuthCipher != null) {
                            cont.resume(AuthRes.Success(resAuthCipher))
                        } else {
                            cont.resumeWithException(IllegalStateException("Authenticated cipher is null"))
                        }
                    }

                    override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                        when (errorCode) {
                            BiometricPrompt.ERROR_USER_CANCELED -> {
                                cont.resume(AuthRes.Failure("cancelled"))
                            }

                            else -> {
                                cont.resumeWithException(Exception("Biometric authentication error #$errorCode: $errString"))
                            }
                        }
                    }

                    override fun onAuthenticationFailed() {
                        cont.resume(AuthRes.Failure("failed"))
                    }
                }
            )

            val promptInfo = BiometricPrompt.PromptInfo.Builder()
                .setTitle("Authenticate")
                .setSubtitle("Use biometric or device credentials")
                .setDeviceCredentialAllowed(true)
                .build()

            biometricPrompt.authenticate(promptInfo, cryptoObject)
        }
    }

    private suspend fun encrypt(rawBytes: ByteArray, alias: String): String {
        val key = initKey(alias)
        val cipher = Cipher.getInstance(transform)
        cipher.init(Cipher.ENCRYPT_MODE, key)

        val authRes: AuthRes = initAuthCipher(cipher)

        when (authRes) {
            is AuthRes.Failure -> return authRes.reason

            is AuthRes.Success -> {
                val authCipher: Cipher = authRes.cipher

                val iv = authCipher.iv
                val encrypted = try {
                    authCipher.doFinal(rawBytes)
                } catch (e: Exception) {
                    throw IllegalStateException("failed doFinal() - encrypt")
                }

                val uniqueCipher = ByteArray(iv.size + encrypted.size)
                System.arraycopy(iv, 0, uniqueCipher, 0, iv.size)
                System.arraycopy(encrypted, 0, uniqueCipher, iv.size, encrypted.size)

                return Base64.encodeToString(uniqueCipher, Base64.DEFAULT)
            }
        }
    }

    private suspend fun decrypt(cipher64: String, alias: String): ByteArray {
        val key = initKey(alias)
        val uniqueCipher = Base64.decode(cipher64, Base64.DEFAULT)

        val iv = uniqueCipher.copyOfRange(0, 12)
        val encryptedData = uniqueCipher.copyOfRange(12, uniqueCipher.size)

        val cipher = Cipher.getInstance(transform)
        val spec = GCMParameterSpec(128, iv)
        cipher.init(Cipher.DECRYPT_MODE, key, spec)

        val authRes: AuthRes = initAuthCipher(cipher)

        when (authRes) {
            is AuthRes.Failure -> return concatBytes(authRes.reason, authRes.reason)
            is AuthRes.Success -> {
                val authCipher: Cipher = authRes.cipher

                val decrypted = try {
                    authCipher.doFinal(encryptedData)
                } catch (e: Exception) {
                    throw IllegalStateException("failed doFinal() - decrypt")
                }

                return decrypted
            }
        }
    }
}
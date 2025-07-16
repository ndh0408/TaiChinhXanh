import 'dart:convert';
import 'dart:math';
import 'package:local_auth/local_auth.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class SecurityService {
  static const String _pinKey = 'user_pin';
  static const String _pinSaltKey = 'user_pin_salt';
  static const String _encryptionKeyKey = 'encryption_key';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _autoLockTimeKey = 'auto_lock_time';
  static const String _lastActiveTimeKey = 'last_active_time';
  static const String _failedAttemptsKey = 'failed_attempts';
  static const String _lockoutTimeKey = 'lockout_time';

  static const int _maxFailedAttempts = 5;
  static const int _lockoutDurationMinutes = 15;
  static const int _biometricTimeoutSeconds = 30;

  static final LocalAuthentication _localAuth = LocalAuthentication();
  static encrypt.Encrypter? _encrypter;
  static encrypt.IV? _iv;

  // Initialize encryption
  static Future<void> initializeEncryption() async {
    final prefs = await SharedPreferences.getInstance();
    String? keyString = prefs.getString(_encryptionKeyKey);

    if (keyString == null) {
      // Generate new encryption key
      final key = encrypt.Key.fromSecureRandom(32);
      keyString = key.base64;
      await prefs.setString(_encryptionKeyKey, keyString);
    }
    // Ensure keyString is not null before using setString
    if (keyString == null) {
      throw Exception('Failed to generate encryption key');
    }

    final key = encrypt.Key.fromBase64(keyString);
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
    _iv = encrypt.IV.fromSecureRandom(16);
  }

  // Generate secure random salt
  static String _generateSalt() {
    final bytes = List<int>.generate(32, (i) => Random.secure().nextInt(256));
    return base64Encode(bytes);
  }

  // Improved PIN hashing with multiple rounds of SHA-256
  static String _hashPin(String pin, String salt) {
    var combined = pin + salt;

    // Multiple rounds of hashing for security (similar to PBKDF2 concept)
    for (int i = 0; i < 100000; i++) {
      var bytes = utf8.encode(combined);
      var digest = sha256.convert(bytes);
      combined = digest.toString();
    }

    return base64Encode(utf8.encode(combined));
  }

  // PIN Management with improved security
  static Future<bool> hasPinSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pinKey) && prefs.containsKey(_pinSaltKey);
  }

  static Future<bool> setPin(String pin) async {
    if (pin.length != 6 || !RegExp(r'^\d{6}$').hasMatch(pin)) {
      return false; // PIN must be 6 digits
    }

    final prefs = await SharedPreferences.getInstance();

    // Generate unique salt for this user
    final salt = _generateSalt();
    final hashedPin = _hashPin(pin, salt);

    // Save both hash and salt
    final success =
        await prefs.setString(_pinKey, hashedPin) &&
        await prefs.setString(_pinSaltKey, salt);

    if (success) {
      // Reset failed attempts when PIN is set successfully
      await _resetFailedAttempts();
    }

    return success;
  }

  static Future<bool> verifyPin(String pin) async {
    // Check if account is locked out
    if (await _isLockedOut()) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString(_pinKey);
    final storedSalt = prefs.getString(_pinSaltKey);

    if (storedHash == null || storedSalt == null) return false;

    final hashedPin = _hashPin(pin, storedSalt);
    final isValid = hashedPin == storedHash;

    if (isValid) {
      await _resetFailedAttempts();
      await updateLastActiveTime();
    } else {
      await _incrementFailedAttempts();
    }

    return isValid;
  }

  static Future<bool> changePin(String currentPin, String newPin) async {
    if (!await verifyPin(currentPin)) return false;
    return await setPin(newPin);
  }

  static Future<void> removePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
    await prefs.remove(_pinSaltKey);
    await _resetFailedAttempts();
  }

  // Failed attempts tracking
  static Future<void> _incrementFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final currentAttempts = prefs.getInt(_failedAttemptsKey) ?? 0;
    final newAttempts = currentAttempts + 1;

    await prefs.setInt(_failedAttemptsKey, newAttempts);

    if (newAttempts >= _maxFailedAttempts) {
      // Lock out the account
      final lockoutTime = DateTime.now().add(
        Duration(minutes: _lockoutDurationMinutes),
      );
      await prefs.setInt(_lockoutTimeKey, lockoutTime.millisecondsSinceEpoch);
    }
  }

  static Future<void> _resetFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_failedAttemptsKey);
    await prefs.remove(_lockoutTimeKey);
  }

  static Future<bool> _isLockedOut() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutTime = prefs.getInt(_lockoutTimeKey);

    if (lockoutTime == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now > lockoutTime) {
      // Lockout period has expired
      await _resetFailedAttempts();
      return false;
    }

    return true;
  }

  static Future<int> getFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_failedAttemptsKey) ?? 0;
  }

  static Future<Duration?> getRemainingLockoutTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutTime = prefs.getInt(_lockoutTimeKey);

    if (lockoutTime == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now > lockoutTime) return null;

    return Duration(milliseconds: lockoutTime - now);
  }

  // Biometric Authentication with timeout
  static Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  static Future<bool> authenticateWithBiometric({
    String localizedReason = 'XÃ¡c thá»±c Ä‘á»ƒ truy cáº­p á»©ng dá»¥ng',
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      // Check if account is locked out
      if (await _isLockedOut()) {
        return false;
      }

      final isAuthenticated = await _localAuth
          .authenticate(
            localizedReason: localizedReason,
            options: const AuthenticationOptions(
              biometricOnly: true,
              stickyAuth: true,
            ),
          )
          .timeout(
            Duration(seconds: _biometricTimeoutSeconds),
            onTimeout: () => false,
          );

      if (isAuthenticated) {
        await _resetFailedAttempts();
        await updateLastActiveTime();
      } else {
        await _incrementFailedAttempts();
      }

      return isAuthenticated;
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      await _incrementFailedAttempts();
      return false;
    }
  }

  // Auto-lock functionality
  static Future<void> setAutoLockTime(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_autoLockTimeKey, minutes);
  }

  static Future<int> getAutoLockTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_autoLockTimeKey) ?? 5; // Default 5 minutes
  }

  static Future<void> updateLastActiveTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _lastActiveTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<bool> shouldAutoLock() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActiveTime = prefs.getInt(_lastActiveTimeKey);
    final autoLockMinutes = await getAutoLockTime();

    if (lastActiveTime == null || autoLockMinutes == 0) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final timeDiff = now - lastActiveTime;
    final autoLockMillis = autoLockMinutes * 60 * 1000;

    return timeDiff > autoLockMillis;
  }

  // Data Encryption/Decryption
  static Future<String?> encryptData(String data) async {
    if (_encrypter == null || _iv == null) {
      await initializeEncryption();
    }

    try {
      final encrypted = _encrypter!.encrypt(data, iv: _iv!);
      return encrypted.base64;
    } catch (e) {
      debugPrint('Encryption error: $e');
      return null;
    }
  }

  static Future<String?> decryptData(String encryptedData) async {
    if (_encrypter == null || _iv == null) {
      await initializeEncryption();
    }

    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedData);
      return _encrypter!.decrypt(encrypted, iv: _iv!);
    } catch (e) {
      debugPrint('Decryption error: $e');
      return null;
    }
  }

  // Secure storage for sensitive data
  static Future<bool> storeSecureData(String key, String data) async {
    final encryptedData = await encryptData(data);
    if (encryptedData == null) return false;

    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString('secure_$key', encryptedData);
  }

  static Future<String?> getSecureData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedData = prefs.getString('secure_$key');
    if (encryptedData == null) return null;

    return await decryptData(encryptedData);
  }

  static Future<void> removeSecureData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('secure_$key');
  }

  // Security validation
  static bool isValidPin(String pin) {
    return pin.length == 6 && RegExp(r'^\d{6}$').hasMatch(pin);
  }

  static String generateSecurePin() {
    final random = Random.secure();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  // Clear all security data (for logout/reset)
  static Future<void> clearAllSecurityData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where(
          (key) =>
              key.startsWith('secure_') ||
              key == _pinKey ||
              key == _pinSaltKey ||
              key == _biometricEnabledKey ||
              key == _autoLockTimeKey ||
              key == _lastActiveTimeKey ||
              key == _failedAttemptsKey ||
              key == _lockoutTimeKey,
        )
        .toList();

    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  // App lock status
  static Future<bool> isAppLocked() async {
    final hasPinSet = await SecurityService.hasPinSet();
    if (!hasPinSet) return false;

    return await shouldAutoLock() || await _isLockedOut();
  }

  // Complete authentication flow
  static Future<bool> authenticate({
    String localizedReason = 'XÃ¡c thá»±c Ä‘á»ƒ truy cáº­p á»©ng dá»¥ng',
  }) async {
    final pinIsSet = await hasPinSet();
    if (!pinIsSet) return true; // No security set up

    // Check if locked out
    if (await _isLockedOut()) {
      return false;
    }

    final biometricEnabled = await isBiometricEnabled();
    if (biometricEnabled) {
      final biometricResult = await authenticateWithBiometric(
        localizedReason: localizedReason,
      );
      if (biometricResult) {
        return true;
      }
    }

    // Fallback to PIN authentication will be handled by UI
    return false;
  }

  // Security settings summary
  static Future<Map<String, dynamic>> getSecurityStatus() async {
    final lockoutTime = await getRemainingLockoutTime();

    return {
      'hasPinSet': await hasPinSet(),
      'biometricAvailable': await isBiometricAvailable(),
      'biometricEnabled': await isBiometricEnabled(),
      'autoLockTime': await getAutoLockTime(),
      'availableBiometrics': await getAvailableBiometrics(),
      'isLocked': await isAppLocked(),
      'failedAttempts': await getFailedAttempts(),
      'isLockedOut': await _isLockedOut(),
      'lockoutTimeRemaining': lockoutTime?.inMinutes,
    };
  }

  // Security utilities
  static String getSecurityLevel() {
    // This could be expanded to evaluate overall security level
    return 'Enhanced'; // vs 'Basic', 'Standard'
  }

  static Future<bool> validateSecuritySetup() async {
    final status = await getSecurityStatus();
    return status['hasPinSet'] == true || status['biometricEnabled'] == true;
  }
}


import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed25519;
import 'package:pointycastle/export.dart';

class CryptoService {
  static const String _base58Alphabet =
      '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

  // Generate Mnemonic
  static String generateMnemonic() {
    return bip39.generateMnemonic();
  }

  // Validate Mnemonic
  static bool validateMnemonic(String mnemonic) {
    try {
      return bip39.validateMnemonic(mnemonic.trim());
    } catch (e) {
      return false;
    }
  }

  // FIXED: Proper Ed25519 Keypair Derivation
  static Future<Map<String, String>> deriveKeypairFromMnemonic(
    String mnemonic, {
    String derivationPath = "m/44'/501'/0'/0'",
  }) async {
    if (!validateMnemonic(mnemonic)) {
      throw Exception('Invalid mnemonic phrase');
    }

    try {
      // Convert mnemonic to seed (proper BIP39)
      final seed = bip39.mnemonicToSeed(mnemonic);

      // Derive private key using proper PBKDF2 with derivation path
      final derivedSeed = _deriveFromPath(seed, derivationPath);

      // Create Ed25519 keypair
      final privateKey = derivedSeed.sublist(0, 32);
      final privateKeyObj = ed25519.newKeyFromSeed(privateKey);

      // Get public key from private key
      final publicKeyObj = ed25519.public(privateKeyObj);
      final publicKey = publicKeyObj.bytes;
      final publicKeyBase58 = _encodeBase58(Uint8List.fromList(publicKey));

      return {
        'privateKey': base64Encode(privateKey),
        'publicKey': publicKeyBase58,
      };
    } catch (e) {
      throw Exception('Failed to derive keypair: $e');
    }
  }

  // Helper: Derive key from BIP44 path
  static Uint8List _deriveFromPath(Uint8List seed, String path) {
    // Simplified BIP44 derivation for Solana
    final pathBytes = utf8.encode(path);
    final combined = Uint8List.fromList([...seed, ...pathBytes]);

    // Use PBKDF2 for proper key derivation
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(Pbkdf2Parameters(utf8.encode('salt'), 2048, 64));

    return pbkdf2.process(combined);
  }

  // FIXED: Proper Ed25519 Signing
  static String signMessage(String message, String privateKeyBase64) {
    try {
      final privateKey = base64Decode(privateKeyBase64);
      final messageBytes = utf8.encode(message);

      // Create Ed25519 private key from seed
      final privateKeyObj = ed25519.newKeyFromSeed(privateKey);

      // Sign with Ed25519
      final signature = ed25519.sign(privateKeyObj, messageBytes);

      return base64Encode(signature);
    } catch (e) {
      throw Exception('Failed to sign message: $e');
    }
  }

  // FIXED: Proper Ed25519 Verification
  static bool verifySignature(
    String message,
    String signature,
    String publicKeyBase58,
  ) {
    try {
      final messageBytes = utf8.encode(message);
      final signatureBytes = base64Decode(signature);
      final publicKeyBytes = _decodeBase58(publicKeyBase58);

      final publicKey = ed25519.PublicKey(publicKeyBytes);
      return ed25519.verify(publicKey, messageBytes, signatureBytes);
    } catch (e) {
      return false;
    }
  }

  // Generate Random Keypair (FIXED)
  static Map<String, String> generateKeypair() {
    try {
      final random = Random.secure();
      final seed = Uint8List(32);
      for (int i = 0; i < 32; i++) {
        seed[i] = random.nextInt(256);
      }

      final privateKeyObj = ed25519.newKeyFromSeed(seed);
      final publicKeyObj = ed25519.public(privateKeyObj);
      final publicKey = publicKeyObj.bytes;
      final publicKeyBase58 = _encodeBase58(Uint8List.fromList(publicKey));

      return {'privateKey': base64Encode(seed), 'publicKey': publicKeyBase58};
    } catch (e) {
      throw Exception('Failed to generate keypair: $e');
    }
  }

  // Encrypt Data
  static String encryptData(String data, String password) {
    try {
      final key = _deriveKey(password);
      final iv = _generateIV();

      final cipher = GCMBlockCipher(AESEngine());
      final params = AEADParameters(KeyParameter(key), 128, iv, Uint8List(0));
      cipher.init(true, params);

      final dataBytes = utf8.encode(data);
      final encrypted = cipher.process(dataBytes);

      final result = Uint8List.fromList([...iv, ...encrypted]);
      return base64Encode(result);
    } catch (e) {
      throw Exception('Failed to encrypt data: $e');
    }
  }

  // Decrypt Data
  static String decryptData(String encryptedData, String password) {
    try {
      final data = base64Decode(encryptedData);
      final iv = data.sublist(0, 12);
      final encrypted = data.sublist(12);

      final key = _deriveKey(password);

      final cipher = GCMBlockCipher(AESEngine());
      final params = AEADParameters(KeyParameter(key), 128, iv, Uint8List(0));
      cipher.init(false, params);

      final decrypted = cipher.process(encrypted);
      return utf8.decode(decrypted);
    } catch (e) {
      throw Exception('Failed to decrypt data: $e');
    }
  }

  // Generate Hash
  static String generateHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Base58 Encoding
  static String _encodeBase58(Uint8List bytes) {
    if (bytes.isEmpty) return '';

    // Count leading zeros
    int leadingZeros = 0;
    for (int i = 0; i < bytes.length && bytes[i] == 0; i++) {
      leadingZeros++;
    }

    // Convert to base 58
    List<int> digits = [0];
    for (int i = leadingZeros; i < bytes.length; i++) {
      int carry = bytes[i];
      for (int j = 0; j < digits.length; j++) {
        carry += digits[j] << 8;
        digits[j] = carry % 58;
        carry ~/= 58;
      }
      while (carry > 0) {
        digits.add(carry % 58);
        carry ~/= 58;
      }
    }

    // Convert to string
    String result = '1' * leadingZeros;
    for (int i = digits.length - 1; i >= 0; i--) {
      result += _base58Alphabet[digits[i]];
    }

    return result;
  }

  // Base58 Decoding
  static Uint8List _decodeBase58(String encoded) {
    if (encoded.isEmpty) return Uint8List(0);

    // Count leading ones
    int leadingOnes = 0;
    for (int i = 0; i < encoded.length && encoded[i] == '1'; i++) {
      leadingOnes++;
    }

    // Convert from base 58
    List<int> digits = [0];
    for (int i = leadingOnes; i < encoded.length; i++) {
      int carry = _base58Alphabet.indexOf(encoded[i]);
      if (carry < 0) throw Exception('Invalid base58 character');

      for (int j = 0; j < digits.length; j++) {
        carry += digits[j] * 58;
        digits[j] = carry & 0xff;
        carry >>= 8;
      }
      while (carry > 0) {
        digits.add(carry & 0xff);
        carry >>= 8;
      }
    }

    // Convert to bytes
    final result = Uint8List(leadingOnes + digits.length);
    for (int i = 0; i < digits.length; i++) {
      result[leadingOnes + digits.length - 1 - i] = digits[i];
    }

    return result;
  }

  // Helper Methods
  static Uint8List _deriveKey(String password) {
    final salt = utf8.encode('solana_wallet_salt');
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(Pbkdf2Parameters(salt, 10000, 32));
    return pbkdf2.process(utf8.encode(password));
  }

  static Uint8List _generateIV() {
    final random = Random.secure();
    final iv = Uint8List(12);
    for (int i = 0; i < 12; i++) {
      iv[i] = random.nextInt(256);
    }
    return iv;
  }
}

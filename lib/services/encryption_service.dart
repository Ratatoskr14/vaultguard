import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/api.dart';

class EncryptionService {
  static const _ivLength = 16;

  // Your 32-byte key (must stay exactly the same!)
  static final Key _key = Key.fromUtf8('32charlongsecretkeymustb32bytes!');
  // Encrypter in CBC mode with PKCS7 padding
  static final Encrypter _encrypter =
  Encrypter(AES(_key, mode: AESMode.cbc, padding: 'PKCS7'));

  // For fallback: your old “all-zeros” IV
  static final IV _staticIv = IV.fromLength(_ivLength);

  /// Encrypts [plain] with a random IV ⟶ returns base64(iv + ciphertext)
  String encrypt(String plain) {
    final iv = IV.fromSecureRandom(_ivLength);
    final encrypted = _encrypter.encrypt(plain, iv: iv);
    // prefix IV bytes to cipher bytes
    final combined = Uint8List.fromList(iv.bytes + encrypted.bytes);
    return base64Encode(combined);
  }

  /// Decrypts a base64 string.
  /// First tries `[iv][cipher]` split; if that fails, falls back to static IV.
  String decrypt(String data) {
    final bytes = base64Decode(data);
    // If it’s at least ivLength+1 bytes, try dynamic-IV decrypt
    if (bytes.length > _ivLength) {
      try {
        final ivBytes = bytes.sublist(0, _ivLength);
        final cipherBytes = bytes.sublist(_ivLength);
        return _encrypter.decrypt(
          Encrypted(cipherBytes),
          iv: IV(Uint8List.fromList(ivBytes)),
        );
      } catch (_) {
        // ignore and fall back
      }
    }
    // Fallback to your old static-IV scheme
    try {
      return _encrypter.decrypt(
        Encrypted.fromBase64(data),
        iv: _staticIv,
      );
    } catch (e) {
      // rethrow so you can see the error if even fallback fails
      rethrow;
    }
  }
}

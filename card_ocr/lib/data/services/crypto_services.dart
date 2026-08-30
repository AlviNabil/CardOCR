import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

const _kStorageKey = 'card_ocr_encryption_key';
const _nonceLength = 12;
const _macLength = 16;

@lazySingleton
class CryptoServices {
  final FlutterSecureStorage secureStorage;
  final encryptionAlgorithm = AesGcm.with256bits();

  CryptoServices({required this.secureStorage});

  Future<SecretKey> _getOrCreateKey() async {
    final storedKey = await secureStorage.read(key: _kStorageKey);
    if (storedKey != null) {
      return SecretKey(base64Decode(storedKey));
    }
    final newKey = await encryptionAlgorithm.newSecretKey();
    final newKeyBytes = await newKey.extractBytes();
    await secureStorage.write(key: _kStorageKey, value: base64Encode(newKeyBytes));
    return newKey;
  }

  Future<Uint8List> encrypt(Uint8List plainText) async {
    final secretKey = await _getOrCreateKey();
    final secretBox = await encryptionAlgorithm.encrypt(plainText, secretKey: secretKey);
    return Uint8List.fromList([...secretBox.nonce, ...secretBox.mac.bytes, ...secretBox.cipherText]);
  }

  Future<Uint8List> decrypt(Uint8List combined) async {
    final secretKey = await _getOrCreateKey();
    final nonce = combined.sublist(0, _nonceLength);
    final mac = combined.sublist(_nonceLength, _nonceLength + _macLength);
    final cipherText = combined.sublist(_nonceLength + _macLength);
    final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(mac));
    final plainText = await encryptionAlgorithm.decrypt(secretBox, secretKey: secretKey);
    return Uint8List.fromList(plainText);
  }
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:card_ocr/data/models/models.dart';
import 'package:card_ocr/data/services/crypto_services.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

@lazySingleton
class CardLocalDataSource {
  final CryptoServices cryptoService;
  Database? _db;

  CardLocalDataSource({required this.cryptoService});

  Future<Database> get _database async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'card_ocr.db');

    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE cards (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          label TEXT NOT NULL,
          network TEXT NOT NULL,
          pan_last4 TEXT NOT NULL,
          saved_at TEXT NOT NULL,
          encrypted_blob BLOB NOT NULL
        )
      '''),
    );
    return _db!;
  }

  Future<void> save(CardRecordModel model) async {
    final db = await _database;
    final plainText = utf8.encode(jsonEncode(model.toJson()));
    final encryptedBlob = await cryptoService.encrypt(Uint8List.fromList(plainText));

    await db.insert('cards', {
      'label': model.label,
      'network': model.network,
      'pan_last4': model.pan.length >= 4 ? model.pan.substring(model.pan.length - 4) : model.pan,
      'saved_at': model.savedAt.toIso8601String(),
      'encrypted_blob': encryptedBlob,
    });
  }

  Future<List<CardRecordModel>> getAll() async {
    final db = await _database;
    final result = await db.query('cards', orderBy: 'saved_at DESC');

    final models = <CardRecordModel>[];
    for (final row in result) {
      final encryptedBlob = row['encrypted_blob'] as Uint8List;
      final decryptedBytes = await cryptoService.decrypt(encryptedBlob);
      final decryptedJson = jsonDecode(utf8.decode(decryptedBytes)) as Map<String, dynamic>;
      final parsed = CardRecordModel.fromJson(decryptedJson);
      models.add(
        CardRecordModel(
          id: row['id'] as int,
          label: parsed.label,
          cardholderName: parsed.cardholderName,
          network: parsed.network,
          pan: parsed.pan,
          savedAt: parsed.savedAt,
          expiryMonth: parsed.expiryMonth,
          expiryYear: parsed.expiryYear,
        ),
      );
    }
    return models;
  }

  Future<void> delete(int id) async {
    final db = await _database;
    await db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }
}

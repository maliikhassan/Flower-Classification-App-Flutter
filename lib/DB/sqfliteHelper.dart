import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'seed_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE seeds(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imagePath TEXT,
        seedType TEXT,
        confidence REAL,
        dateTime TEXT
      )
    ''');
  }

  Future<void> insertSeed(Seed seed) async {
    final db = await database;
    await db.insert('seeds', seed.toMap());
  }

  Future<List<Seed>> getSeeds() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('seeds');
    return List.generate(maps.length, (i) {
      return Seed.fromMap(maps[i]);
    });
  }
}

class Seed {
  final int? id;
  final String imagePath;
  final String seedType;
  final double confidence;
  final String dateTime;

  Seed({
    this.id,
    required this.imagePath,
    required this.seedType,
    required this.confidence,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'seedType': seedType,
      'confidence': confidence,
      'dateTime': dateTime,
    };
  }

  factory Seed.fromMap(Map<String, dynamic> map) {
    return Seed(
      id: map['id'],
      imagePath: map['imagePath'],
      seedType: map['seedType'],
      confidence: map['confidence'],
      dateTime: map['dateTime'],
    );
  }
}
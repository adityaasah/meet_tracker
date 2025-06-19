// database_handler.dart
// SQLite handler for Flutter powerlifting app to store top 3 lifters after a meet.
// Uses `sqflite` and `path` packages for local persistence (no Firebase):contentReference[oaicite:0]{index=0}.

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Model class to represent a lifter's stats
class Lifter {
  final int? id; // id will be auto-generated in the database
  final String name;
  final bool onTeam;
  final int bestSquat;
  final int bestBench;
  final int bestDeadlift;
  final int total;

  Lifter({
    this.id,
    required this.name,
    required this.onTeam,
    required this.bestSquat,
    required this.bestBench,
    required this.bestDeadlift,
    required this.total,
  });

  // Convert a Lifter into a Map for insertion into SQLite
  Map<String, Object?> toMap() {
    return {
      'name': name,
      'onTeam': onTeam ? 1 : 0, // SQLite has no bool type; store as 1 or 0:contentReference[oaicite:1]{index=1}
      'bestSquat': bestSquat,
      'bestBench': bestBench,
      'bestDeadlift': bestDeadlift,
      'total': total,
    };
  }

  // Create a Lifter object from a Map retrieved from SQLite
  static Lifter fromMap(Map<String, Object?> map) {
    return Lifter(
      id: map['id'] as int?,
      name: map['name'] as String,
      onTeam: (map['onTeam'] as int) == 1, // retrieve bool from integer:contentReference[oaicite:2]{index=2}
      bestSquat: map['bestSquat'] as int,
      bestBench: map['bestBench'] as int,
      bestDeadlift: map['bestDeadlift'] as int,
      total: map['total'] as int,
    );
  }
}

class DatabaseHandler {
  // Singleton instance
  static final DatabaseHandler instance = DatabaseHandler._init();
  static Database? _database;

  DatabaseHandler._init();

  // Accessor for the database (initializes if needed)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('powerlifting.db');
    return _database!;
  }

  // Open the database and create tables if they do not exist
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName); // use join for correct path on each platform:contentReference[oaicite:3]{index=3}:contentReference[oaicite:4]{index=4}
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Create the "lifters" table to store the lifters' stats
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE lifters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        onTeam INTEGER NOT NULL,
        bestSquat INTEGER NOT NULL,
        bestBench INTEGER NOT NULL,
        bestDeadlift INTEGER NOT NULL,
        total INTEGER NOT NULL
      )
    ''' ); // Example create table usage:contentReference[oaicite:5]{index=5}
  }

  // Insert a single lifter into the database
  Future<void> insertLifter(Lifter lifter) async {
    final db = await database;
    await db.insert(
      'lifters',
      lifter.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // replaces on conflict:contentReference[oaicite:6]{index=6}
    );
  }

  // Save only top 3 lifters after meet completion
  Future<void> saveTopLifters(List<Lifter> lifters) async {
    final db = await database;
    // Sort lifters by total descending and take top 3
    lifters.sort((a, b) => b.total.compareTo(a.total));
    final top3 = lifters.length > 3 ? lifters.sublist(0, 3) : lifters;
    // Optional: clear previous entries if starting fresh each meet
    // await db.delete('lifters');
    for (var lifter in top3) {
      await db.insert(
        'lifters',
        lifter.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Retrieve all saved lifters (the top 3 from last meet)
  Future<List<Lifter>> getTopLifters() async {
    final db = await database;
    final result = await db.query('lifters');
    return result.map((row) => Lifter.fromMap(row)).toList();
  }

  // Close the database (optional; Flutter will close it on app termination)
  Future close() async {
    final db = await database;
    db.close();
  }
}

/*
Usage example (call after the Deadlift page / meet completion):
final List<Lifter> allLifters = [
  Lifter(name: 'Alice', onTeam: true, bestSquat: 200, bestBench: 120, bestDeadlift: 250, total: 570),
  Lifter(name: 'Bob', onTeam: false, bestSquat: 210, bestBench: 110, bestDeadlift: 240, total: 560),
  Lifter(name: 'Charlie', onTeam: true, bestSquat: 190, bestBench: 130, bestDeadlift: 260, total: 580),
  // ... other lifters ...
];
// Save top 3 to database
await DatabaseHandler.instance.saveTopLifters(allLifters);
// Later, retrieve and display top lifters
List<Lifter> topLifters = await DatabaseHandler.instance.getTopLifters();
print('Top lifters: \$topLifters');
*/

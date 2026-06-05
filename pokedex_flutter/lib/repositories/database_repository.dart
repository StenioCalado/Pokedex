import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pokemon.dart';

class DatabaseRepository {
  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pokedex.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favoritos (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            types TEXT NOT NULL,
            image_url TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE historico (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pokemon_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            types TEXT NOT NULL,
            image_url TEXT NOT NULL,
            viewed_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // ── FAVORITOS ──────────────────────────────────────────

  Future<void> addFavorite(Pokemon pokemon) async {
    final db = await database;
    await db.insert(
      'favoritos',
      pokemon.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeFavorite(int pokemonId) async {
    final db = await database;
    await db.delete('favoritos', where: 'id = ?', whereArgs: [pokemonId]);
  }

  Future<bool> isFavorite(int pokemonId) async {
    final db = await database;
    final result = await db.query(
      'favoritos',
      where: 'id = ?',
      whereArgs: [pokemonId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<List<Pokemon>> getFavorites() async {
    final db = await database;
    final rows = await db.query('favoritos', orderBy: 'id ASC');
    return rows.map(Pokemon.fromMap).toList();
  }

  // ── HISTÓRICO ──────────────────────────────────────────

  Future<void> addToHistory(Pokemon pokemon) async {
    final db = await database;
    // Remove entrada duplicada antes de inserir (mantém sempre a mais recente)
    await db.delete(
      'historico',
      where: 'pokemon_id = ?',
      whereArgs: [pokemon.id],
    );
    await db.insert('historico', {
      'pokemon_id': pokemon.id,
      'name': pokemon.name,
      'types': pokemon.types.join(','),
      'image_url': pokemon.imageUrl,
      'viewed_at': DateTime.now().toIso8601String(),
    });
    // Mantém no máximo 30 entradas
    await db.execute('''
      DELETE FROM historico WHERE id NOT IN (
        SELECT id FROM historico ORDER BY viewed_at DESC LIMIT 30
      )
    ''');
  }

  Future<List<Pokemon>> getHistory() async {
    final db = await database;
    final rows = await db.query('historico', orderBy: 'viewed_at DESC');
    return rows
        .map((r) => Pokemon.fromMap({
              'id': r['pokemon_id'],
              'name': r['name'],
              'types': r['types'],
              'image_url': r['image_url'],
            }))
        .toList();
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('historico');
  }
}

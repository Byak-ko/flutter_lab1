import 'package:path/path.dart' as p;
import 'package:sqflite_common/sqlite_api.dart';

import '../models/post.dart';
import '../models/user.dart';

class LocalDb {
  LocalDb(this._factory, {this.path});

  final DatabaseFactory _factory;

  final String? path;

  Database? _db;

  Future<Database> get _database async {
    final existing = _db;
    if (existing != null) return existing;
    final dbPath =
        path ?? p.join(await _factory.getDatabasesPath(), 'flutter_lab.db');
    return _db = await _factory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(version: 1, onCreate: _onCreate),
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        website TEXT NOT NULL,
        company TEXT NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id),
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        favorite INTEGER NOT NULL DEFAULT 0
      )''');
  }

  Future<void> saveUsers(List<User> users) async {
    final db = await _database;
    final batch = db.batch();
    for (final user in users) {
      batch.insert(
        'users',
        user.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> savePosts(List<Post> posts) async {
    final db = await _database;
    final batch = db.batch();
    for (final post in posts) {
      batch.rawInsert(
        '''
        INSERT INTO posts (id, user_id, title, body) VALUES (?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
          user_id = excluded.user_id,
          title = excluded.title,
          body = excluded.body''',
        [post.id, post.userId, post.title, post.body],
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<User>> loadUsers() async {
    final rows = await (await _database).query('users', orderBy: 'id');
    return rows.map(User.fromDbMap).toList();
  }

  Future<List<Post>> loadPosts() async {
    final rows = await (await _database).query('posts', orderBy: 'id');
    return rows.map(Post.fromDbMap).toList();
  }

  Future<void> setFavorite(int postId, bool favorite) async {
    await (await _database).update(
      'posts',
      {'favorite': favorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [postId],
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}

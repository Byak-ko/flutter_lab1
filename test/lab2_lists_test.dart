import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_lab1/data/api_client.dart';
import 'package:flutter_lab1/data/local_db.dart';
import 'package:flutter_lab1/data/repository.dart';
import 'package:flutter_lab1/models/post.dart';
import 'package:flutter_lab1/models/user.dart';
import 'package:flutter_lab1/pages/lists_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _usersJson = [
  {
    'id': 1,
    'name': 'Leanne Graham',
    'username': 'Bret',
    'email': 'leanne@example.com',
    'phone': '1-770',
    'website': 'hildegard.org',
    'company': {'name': 'Romaguera-Crona'},
  },
  {
    'id': 2,
    'name': 'Ervin Howell',
    'username': 'Antonette',
    'email': 'ervin@example.com',
    'phone': '010-692',
    'website': 'anastasia.net',
    'company': {'name': 'Deckow-Crist'},
  },
];

const _postsJson = [
  {'userId': 1, 'id': 1, 'title': 'first', 'body': 'body 1'},
  {'userId': 1, 'id': 2, 'title': 'second', 'body': 'body 2'},
  {'userId': 2, 'id': 3, 'title': 'third', 'body': 'body 3'},
];

MockClient _onlineClient() => MockClient(
  (request) async => switch (request.url.path) {
    '/users' => http.Response(jsonEncode(_usersJson), 200),
    '/posts' => http.Response(jsonEncode(_postsJson), 200),
    _ => http.Response('not found', 404),
  },
);

MockClient _offlineClient() =>
    MockClient((request) async => throw http.ClientException('offline'));

void main() {
  sqfliteFfiInit();

  group('models', () {
    test('User.fromJson parses nested company and initials', () {
      final user = User.fromJson(_usersJson.first);
      expect(user.companyName, 'Romaguera-Crona');
      expect(user.initials, 'LG');
      expect(User.fromDbMap(user.toDbMap()).email, user.email);
    });

    test('Post round-trips through DB map with favorite flag', () {
      final post = Post.fromJson(_postsJson.first).copyWith(isFavorite: true);
      final restored = Post.fromDbMap(post.toDbMap());
      expect(restored.isFavorite, isTrue);
      expect(restored.title, 'first');
    });
  });

  group('buildEntries', () {
    final users = _usersJson.map(User.fromJson).toList();
    final posts = _postsJson.map(Post.fromJson).toList();

    test('groups posts under their user header', () {
      final entries = buildEntries(users, posts);
      expect(entries.map((e) => e.runtimeType).toList(), [
        UserEntry,
        PostEntry,
        PostEntry,
        UserEntry,
        PostEntry,
      ]);
      expect((entries.first as UserEntry).postCount, 2);
    });

    test('favoritesOnly hides users without favorite posts', () {
      final withFav = [posts[0], posts[1], posts[2].copyWith(isFavorite: true)];
      final entries = buildEntries(users, withFav, favoritesOnly: true);
      expect(entries, hasLength(2));
      expect((entries.first as UserEntry).user.id, 2);
    });
  });

  group('FeedRepository', () {
    late LocalDb db;

    setUp(() => db = LocalDb(databaseFactoryFfi, path: inMemoryDatabasePath));
    tearDown(() => db.close());

    test('loads from API and caches to DB', () async {
      final repo = FeedRepository(
        api: JsonPlaceholderApi(client: _onlineClient()),
        db: db,
      );
      final data = await repo.load();
      expect(data.source, DataSource.api);
      expect(data.users, hasLength(2));
      expect(await db.loadPosts(), hasLength(3));
    });

    test('falls back to DB when offline and keeps favorites', () async {
      await FeedRepository(
        api: JsonPlaceholderApi(client: _onlineClient()),
        db: db,
      ).load();
      await db.setFavorite(3, true);

      final online = await FeedRepository(
        api: JsonPlaceholderApi(client: _onlineClient()),
        db: db,
      ).load();
      expect(online.posts.firstWhere((p) => p.id == 3).isFavorite, isTrue);

      final offline = await FeedRepository(
        api: JsonPlaceholderApi(client: _offlineClient()),
        db: db,
      ).load();
      expect(offline.source, DataSource.cache);
      expect(offline.posts.firstWhere((p) => p.id == 3).isFavorite, isTrue);
    });

    test('throws when offline and cache is empty', () async {
      final repo = FeedRepository(
        api: JsonPlaceholderApi(client: _offlineClient()),
        db: db,
      );
      expect(repo.load(), throwsStateError);
    });
  });

  testWidgets('ListsPage renders user headers and posts', (tester) async {
    final db = LocalDb(databaseFactoryFfi, path: inMemoryDatabasePath);
    final repo = FeedRepository(
      api: JsonPlaceholderApi(client: _onlineClient()),
      db: db,
    );

    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(home: ListsPage(repository: repo)));
      for (var i = 0; i < 20 && find.byType(PostTile).evaluate().isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();
      }
    });
    await tester.pump();

    expect(find.byType(UserHeaderTile), findsNWidgets(2));
    expect(find.byType(PostTile), findsNWidgets(3));
    expect(find.text('Leanne Graham'), findsOneWidget);

    await tester.runAsync(() => db.close());
  });
}

import '../models/post.dart';
import '../models/user.dart';
import 'api_client.dart';
import 'local_db.dart';

enum DataSource { api, cache }

class FeedData {
  const FeedData({
    required this.users,
    required this.posts,
    required this.source,
  });

  final List<User> users;
  final List<Post> posts;
  final DataSource source;
}

class FeedRepository {
  FeedRepository({required this.api, required this.db});

  final JsonPlaceholderApi api;
  final LocalDb db;

  Future<FeedData> load() async {
    var source = DataSource.api;
    try {
      final results = await Future.wait([api.fetchUsers(), api.fetchPosts()]);
      await db.saveUsers(results[0] as List<User>);
      await db.savePosts(results[1] as List<Post>);
    } catch (_) {
      source = DataSource.cache;
    }
    final users = await db.loadUsers();
    final posts = await db.loadPosts();
    if (users.isEmpty && source == DataSource.cache) {
      throw StateError('Немає з\'єднання з мережею і локальний кеш порожній');
    }
    return FeedData(users: users, posts: posts, source: source);
  }

  Future<void> setFavorite(Post post, bool favorite) =>
      db.setFavorite(post.id, favorite);
}

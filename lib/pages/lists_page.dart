import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../data/db_factory.dart';
import '../data/local_db.dart';
import '../data/repository.dart';
import '../models/post.dart';
import '../models/user.dart';

sealed class FeedEntry {
  const FeedEntry();
}

class UserEntry extends FeedEntry {
  const UserEntry(this.user, this.postCount);
  final User user;
  final int postCount;
}

class PostEntry extends FeedEntry {
  const PostEntry(this.post);
  final Post post;
}

List<FeedEntry> buildEntries(
  List<User> users,
  List<Post> posts, {
  bool favoritesOnly = false,
}) {
  final byUser = <int, List<Post>>{};
  for (final post in posts) {
    if (favoritesOnly && !post.isFavorite) continue;
    byUser.putIfAbsent(post.userId, () => []).add(post);
  }
  return [
    for (final user in users)
      if (byUser[user.id] case final userPosts?) ...[
        UserEntry(user, userPosts.length),
        for (final post in userPosts) PostEntry(post),
      ],
  ];
}

class ListsPage extends StatefulWidget {
  const ListsPage({super.key, this.repository});

  final FeedRepository? repository;

  static FeedRepository? _defaultRepository;
  static FeedRepository get defaultRepository =>
      _defaultRepository ??= FeedRepository(
        api: JsonPlaceholderApi(),
        db: LocalDb(createDatabaseFactory()),
      );

  @override
  State<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  late final FeedRepository _repository =
      widget.repository ?? ListsPage.defaultRepository;

  List<User> _users = const [];
  List<Post> _posts = const [];
  DataSource? _source;
  Object? _error;
  bool _loading = true;
  bool _favoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repository.load();
      if (!mounted) return;
      setState(() {
        _users = data.users;
        _posts = data.posts;
        _source = data.source;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleFavorite(Post post) async {
    final updated = post.copyWith(isFavorite: !post.isFavorite);
    setState(() {
      _posts = [for (final p in _posts) p.id == post.id ? updated : p];
    });
    await _repository.setFavorite(post, updated.isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final entries = buildEntries(_users, _posts, favoritesOnly: _favoritesOnly);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Списки'),
        actions: [
          IconButton(
            tooltip: 'Лише обрані',
            isSelected: _favoritesOnly,
            icon: const Icon(Icons.star_border),
            selectedIcon: const Icon(Icons.star),
            onPressed: () => setState(() => _favoritesOnly = !_favoritesOnly),
          ),
          IconButton(
            tooltip: 'Оновити',
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_source == DataSource.cache) const _OfflineBanner(),
          if (_loading) const LinearProgressIndicator(),
          Expanded(child: _buildBody(entries)),
        ],
      ),
    );
  }

  Widget _buildBody(List<FeedEntry> entries) {
    if (_error != null && _users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Не вдалося завантажити дані.\nПеревір підключення до інтернету.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: const Text('Повторити')),
            ],
          ),
        ),
      );
    }
    if (!_loading && entries.isEmpty) {
      return Center(
        child: Text(
          _favoritesOnly ? 'Обраних дописів немає' : 'Список порожній',
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) => switch (entries[index]) {
          UserEntry(:final user, :final postCount) => UserHeaderTile(
            user: user,
            postCount: postCount,
          ),
          PostEntry(:final post) => PostTile(
            post: post,
            onFavoriteToggle: () => _toggleFavorite(post),
          ),
        },
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: scheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 18, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Text(
            'Немає інтернету, показано збережені дані',
            style: TextStyle(color: scheme.onErrorContainer),
          ),
        ],
      ),
    );
  }
}

class UserHeaderTile extends StatelessWidget {
  const UserHeaderTile({
    super.key,
    required this.user,
    required this.postCount,
  });

  final User user;
  final int postCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceContainerHighest,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          child: Text(user.initials),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '@${user.username} · ${user.companyName}\n${user.email}',
        ),
        isThreeLine: true,
        trailing: Chip(label: Text('$postCount')),
      ),
    );
  }
}

class PostTile extends StatelessWidget {
  const PostTile({
    super.key,
    required this.post,
    required this.onFavoriteToggle,
  });

  final Post post;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: IconButton(
        tooltip: post.isFavorite ? 'Прибрати з обраних' : 'В обрані',
        icon: Icon(
          post.isFavorite ? Icons.star : Icons.star_border,
          color: post.isFavorite ? Colors.amber : null,
        ),
        onPressed: onFavoriteToggle,
      ),
    );
  }
}

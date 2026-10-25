class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.isFavorite = false,
  });

  final int id;
  final int userId;
  final String title;
  final String body;

  final bool isFavorite;

  Post copyWith({bool? isFavorite}) => Post(
    id: id,
    userId: userId,
    title: title,
    body: body,
    isFavorite: isFavorite ?? this.isFavorite,
  );

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'] as int,
    userId: json['userId'] as int,
    title: json['title'] as String,
    body: json['body'] as String,
  );

  Map<String, Object?> toDbMap() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'body': body,
    'favorite': isFavorite ? 1 : 0,
  };

  factory Post.fromDbMap(Map<String, Object?> row) => Post(
    id: row['id'] as int,
    userId: row['user_id'] as int,
    title: row['title'] as String,
    body: row['body'] as String,
    isFavorite: row['favorite'] == 1,
  );
}

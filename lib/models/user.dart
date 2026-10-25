class User {
  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.companyName,
  });

  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;
  final String companyName;

  String get initials {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int,
    name: json['name'] as String,
    username: json['username'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String? ?? '',
    website: json['website'] as String? ?? '',
    companyName:
        (json['company'] as Map<String, dynamic>?)?['name'] as String? ?? '',
  );

  Map<String, Object?> toDbMap() => {
    'id': id,
    'name': name,
    'username': username,
    'email': email,
    'phone': phone,
    'website': website,
    'company': companyName,
  };

  factory User.fromDbMap(Map<String, Object?> row) => User(
    id: row['id'] as int,
    name: row['name'] as String,
    username: row['username'] as String,
    email: row['email'] as String,
    phone: row['phone'] as String,
    website: row['website'] as String,
    companyName: row['company'] as String,
  );
}

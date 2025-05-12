/// Model to represent a saved credential
class Credential {
  final int id;
  final String title;
  final String username;
  final String password;

  Credential({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
  });

  // Convert from a Map (e.g. from DB)
  factory Credential.fromMap(Map<String, dynamic> map) {
    return Credential(
      id: map['id'] as int,
      title: map['title'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
    );
  }

  // Convert to Map (e.g. for storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
    };
  }
}
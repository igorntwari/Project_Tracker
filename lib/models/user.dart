class User {
  final int? id;
  final String name;
  final String role;
  final String initials;

  User({
    this.id,
    required this.name,
    required this.role,
    required this.initials,
  });

  // Convert a User into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'initials': initials,
    };
  }

  // A method to create a User from a Map, useful for reading from SQLite
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      role: map['role'],
      initials: map['initials'],
    );
  }
}

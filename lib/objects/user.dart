class User {
  int id;
  String name;
  String email;
  String phonenumber;
  String role;


  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phonenumber,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'] is int
          ? json['user_id']
          : int.parse(json['user_id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phonenumber: json['phonenumber'] ?? '',
      role: json['role'] ?? 'student',
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, role: $role}';
  }
}
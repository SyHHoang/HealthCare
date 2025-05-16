class User {
  final String id;
  final String fullname;
  final String email;
  final int? age;
  final String? gender;
  final String? phone;
  final String? avatar;
  final String? imageId;

  User({
    required this.id,
    required this.fullname,
    required this.email,
    this.age,
    this.gender,
    this.phone,
    this.avatar,
    this.imageId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      fullname: json['fullname'] ?? '',
      email: json['email'] ?? '',
      age: json['age'],
      gender: json['gender'],
      phone: json['phone'],
      avatar: json['avatar'],
      imageId: json['imageId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'age': age,
      'gender': gender,
      'phone': phone,
      'avatar': avatar,
      'imageId': imageId,
    };
  }
} 
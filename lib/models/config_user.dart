class ConfigUser {
  final int id;
  final String name;

  ConfigUser({
    required this.id,
    required this.name,
  });

  factory ConfigUser.fromJson(Map<String, dynamic> json) {
    return ConfigUser(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

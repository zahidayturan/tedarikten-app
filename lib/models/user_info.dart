class UserInfo {
  String? id;
  String? name;
  String? surname;

  UserInfo({
    this.id = "",
    required this.name,
    required this.surname,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "surname": surname,
  };

  static UserInfo fromJson(Map<String, dynamic> json) => UserInfo(
    id: json["id"],
    name: json["name"],
    surname: json["surname"],
  );
}

  /*
    String? id;
  String? name;
  String? surname;
  String? email;
  String? city;
  String? country;
  String? profession;
  bool? isVerified;
  List? followList;
  List? followersList;
  List? advertList;
  List? companyList;
   */

class TUserInfo {
  String id;
  String name;
  String surname;

  TUserInfo({
    required this.id,
    required this.name,
    required this.surname,
  });

  factory TUserInfo.fromJson(Map<String, dynamic> json) {
    return TUserInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
    );
  }
}

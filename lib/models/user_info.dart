class TUserInfo {
  String id;
  String name;
  String surname;
  String email;
  String profession;
  String city;
  String country;
  bool? isVerified;
  List? followList;
  List? followerList;
  List? advertList;
  List? companyList;
  List? registeredList;
  List? appliedList;

  TUserInfo({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.profession,
    required this.city,
    required this.country,
    this.followList,
    this.followerList,
    this.advertList,
    this.companyList,
    this.registeredList,
    this.appliedList
  });

  factory TUserInfo.fromJson(Map<String, dynamic> json) {
    return TUserInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      email: json['email'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      profession: json['profession'] ?? '',
      followList: json['followList'] ?? '',
      followerList: json['followerList'] ?? '',
      advertList: json['advertList'] ?? '',
      companyList: json['companyList'] ?? '',
      registeredList: json['registeredList'] ?? '',
      appliedList: json['appliedList'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'email': email,
      'city': city,
      'country': country,
      'profession': profession,
      'followList': followList,
      'followerList': followerList,
      'advertList': advertList,
      'companyList': companyList,
      'registeredList': registeredList,
      'appliedList': appliedList,
    };
  }
}

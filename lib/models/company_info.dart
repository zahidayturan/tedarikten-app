class CompanyInfo {
  String? id;
  String name;
  String location;
  int year;
  String phone;
  String address;
  String personNameSurname;
  String personEmail;
  String userId;


  CompanyInfo({
    this.id,
    required this.name,
    required this.location,
    required this.year,
    required this.phone,
    required this.address,
    required this.personNameSurname,
    required this.personEmail,
    required this.userId,
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      year: json['year'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      personNameSurname: json['personNameSurname'] ?? '',
      personEmail: json['personEmail'] ?? '',
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'year': year,
      'phone': phone,
      'address': address,
      'personNameSurname': personNameSurname,
      'personEmail': personEmail,
      'userId': userId,
    };
  }
}
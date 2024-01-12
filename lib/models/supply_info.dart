class AdvertInfo {
  String id;
  String name;
  String type;

  AdvertInfo({
    required this.id,
    required this.name,
    required this.type,
  });

  factory AdvertInfo.fromJson(Map<String, dynamic> json) {
    return AdvertInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['surname'] ?? '',
    );
  }
}
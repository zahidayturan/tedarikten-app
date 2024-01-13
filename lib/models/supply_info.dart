class SupplyInfo {
  String? id;
  String type;
  String name;
  String description;
  String dateFirst;
  String dateLast;
  int amount;
  int minTime;
  String location;
  String status;
  String sharingDate;
  String editingDate;
  String companyId;
  String documentId;
  List sharersIdList;
  List registrantsIdList;
  List applicantsIdList;
  String userId;


  SupplyInfo({
    this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.dateFirst,
    required this.dateLast,
    required this.amount,
    required this.minTime,
    required this.location,
    required this.status,
    required this.sharingDate,
    required this.editingDate,
    required this.companyId,
    required this.documentId,
    required this.sharersIdList,
    required this.registrantsIdList,
    required this.applicantsIdList,
    required this.userId,
  });

  factory SupplyInfo.fromJson(Map<String, dynamic> json) {
    return SupplyInfo(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      dateFirst: json['dateFirst'] ?? '',
      dateLast: json['dateLast'] ?? '',
      amount: json['amount'] ?? '',
      minTime: json['minTime'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? '',
      sharingDate: json['sharingDate'] ?? '',
      editingDate: json['editingDate'] ?? '',
      companyId: json['companyId'] ?? '',
      documentId: json['documentId'] ?? '',
      sharersIdList: json['sharersIdList'] ?? '',
      registrantsIdList: json['registrantsIdList'] ?? '',
      applicantsIdList: json['applicantsIdList'] ?? '',
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'description': description,
      'dateFirst': dateFirst,
      'dateLast': dateLast,
      'amount': amount,
      'minTime': minTime,
      'location': location,
      'status': status,
      'sharingDate': sharingDate,
      'editingDate': editingDate,
      'companyId': companyId,
      'documentId': documentId,
      'sharersIdList': sharersIdList,
      'registrantsIdList': registrantsIdList,
      'applicantsIdList': applicantsIdList,
      'userId': userId,
    };
  }
}
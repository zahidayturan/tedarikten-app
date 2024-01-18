import 'package:tedarikten/models/company_info.dart';
import 'package:tedarikten/models/supply_info.dart';
import 'package:tedarikten/models/user_info.dart';

class ApplicationSupplyInfo {
  String? id;
  String applicantUserId;
  String supplyId;
  String message;
  String date;
  String response;

  ApplicationSupplyInfo({
    this.id,
    required this.applicantUserId,
    required this.supplyId,
    required this.message,
    required this.date,
    required this.response,
  });

  factory ApplicationSupplyInfo.fromJson(Map<String, dynamic> json) {
    return ApplicationSupplyInfo(
      id: json['id'] ?? '',
      applicantUserId: json['applicantUserId'] ?? '',
      supplyId: json['supplyId'] ?? '',
      message: json['message'] ?? '',
      date: json['date'] ?? '',
      response: json['response'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'applicantUserId': applicantUserId,
      'supplyId': supplyId,
      'message': message,
      'date': date,
      'response': response,
    };
  }
}

class CombinedApplicationInfo {
  late SupplyInfo supplyInfo;
  late ApplicationSupplyInfo applicationInfo;
  late CompanyInfo companyInfo;
  late TUserInfo userInfo;

  CombinedApplicationInfo({required this.supplyInfo, required this.applicationInfo,required this.companyInfo,required this.userInfo});

  factory CombinedApplicationInfo.fromFirestore(
      Map<String, dynamic> supplyData, Map<String, dynamic> applicationData, Map<String, dynamic> companyData,Map<String, dynamic> userInfo) {
    return CombinedApplicationInfo(
        supplyInfo: SupplyInfo.fromJson(supplyData),
        applicationInfo: ApplicationSupplyInfo.fromJson(applicationData),
        companyInfo: CompanyInfo.fromJson(companyData),
        userInfo: TUserInfo.fromJson(userInfo)
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:tedarikten/models/company_info.dart';
import 'package:tedarikten/models/supply_info.dart';
import 'package:tedarikten/models/user_info.dart';

class CombinedInfo {
  late SupplyInfo supplyInfo;
  late CompanyInfo companyInfo;
  late TUserInfo userInfo;

  CombinedInfo({required this.supplyInfo, required this.companyInfo,required this.userInfo});

  factory CombinedInfo.fromFirestore(
      Map<String, dynamic> supplyData, Map<String, dynamic> companyData, Map<String, dynamic> userInfo) {
    return CombinedInfo(
      supplyInfo: SupplyInfo.fromJson(supplyData),
      companyInfo: CompanyInfo.fromJson(companyData),
      userInfo: TUserInfo.fromJson(userInfo)
    );
  }
}
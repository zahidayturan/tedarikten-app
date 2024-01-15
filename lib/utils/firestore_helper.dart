import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tedarikten/models/company_info.dart';
import 'package:tedarikten/models/supply_info.dart';
import 'package:tedarikten/models/user_info.dart';
import 'package:tedarikten/models/combined_info.dart';

class FirestoreService {

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<TUserInfo?> getUserInfo(String uid) async {
    try {
      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('id', isEqualTo: uid)
          .get();

      if (userSnapshot.size > 0) {
        Map<String, dynamic>? userData = userSnapshot.docs.first.data() as Map<String, dynamic>?;
        return userData != null ? TUserInfo.fromJson(userData) : null;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  Future<String> addCompanyToFirestore(CompanyInfo company) async {
    try {
      Map<String, dynamic> companyData = company.toJson();
      DocumentReference documentReference = await FirebaseFirestore.instance.collection('companies').add(companyData);
      String documentId = documentReference.id;
      await documentReference.update({'id': documentId});
      return documentId;
    } catch (e) {
      print('Kayıt hatası: $e');
      return "Hata";
    }
  }



  Future<void> addAdvertToFirestore(SupplyInfo supply) async {
    try {
      Map<String, dynamic> supplyData = supply.toJson();
      DocumentReference supplyRef = await FirebaseFirestore.instance.collection('supplies').add(supplyData);
      String supplyId = supplyRef.id;
      await supplyRef.update({'id': supplyId});


      QuerySnapshot userQuery = await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: supply.userId).get();
      if (userQuery.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userQuery.docs.first;
        DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userDoc.id);
        await userRef.update({
          'advertList': FieldValue.arrayUnion([supplyId]),
        });
      } else {
        print('Kullanıcı bulunamadı');
      }

    } catch (e) {
      print('Kayıt hatası: $e');
    }
  }

  Future<List<CombinedInfo>> getSupplyDataFromFirestore(String userId) async {
    late List<CombinedInfo> userDataList = [];
    try {

      var userQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: userId)
          .get();

        var advertList = userQuerySnapshot.docs[0]['advertList'];


        var suppliesQuerySnapshot = await FirebaseFirestore.instance
            .collection('supplies')
            .where(FieldPath.documentId, whereIn: advertList)
            .get();

        for (var document in suppliesQuerySnapshot.docs) {
          print(document.data());
        }

      var querySnapshotForSupplies = await FirebaseFirestore.instance
          .collection('supplies')
          .where(FieldPath.documentId, whereIn: advertList)
          .get();


      //var advertList = querySnapshotForAdvertList.docs[0]['advertList'];
      /*var querySnapshotForSupplies = await FirebaseFirestore.instance
          .collection('supplies')
          .where('id', isEqualTo: advertList)
          .get();*/

      if (querySnapshotForSupplies.docs.isNotEmpty) {
        List<DocumentSnapshot> documents = querySnapshotForSupplies.docs;
        userDataList = await Future.wait(documents.map((doc) async {
          Map<String, dynamic> supplyData = doc.data() as Map<String, dynamic>;

          String companyId = supplyData['companyId'];
          String userIdFromSupply = supplyData['userId'];

          Map<String, dynamic> companyData = {};
          if (companyId != "0") {
            DocumentSnapshot companyDoc = await FirebaseFirestore.instance
                .collection('companies')
                .doc(companyId)
                .get();
            companyData = companyDoc.data() as Map<String, dynamic>;
          }else{
            CompanyInfo myDataInstance = CompanyInfo(
              name: "",
              location: "",
              year: 11111,
              phone: "",
              address: "",
              personNameSurname: "",
              personEmail: "",
              userId: "",
            );
             companyData = myDataInstance.toJson();
          }

          QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where("id", isEqualTo: userIdFromSupply)
              .get();

          Map<String, dynamic> userData = userQuerySnapshot.docs.first.data() as Map<String, dynamic>;

          return CombinedInfo.fromFirestore(supplyData, companyData, userData);
        }).toList());

        print('Gelen CombinedInfo Listesi: $userDataList');
        return userDataList;
      } else {
        print('Belge bulunamadı.');
        return [];
      }
    } catch (e) {
      print('Veri çekme hatası: $e');
    }
    return [];
  }

  Future<List<CombinedInfo>> getActiveSupplyDataFromFirestoreAllUser(String userId) async {
    late List<CombinedInfo> userDataList = [];
    try {
      var querySnapshotForSupplies = await FirebaseFirestore.instance
          .collection('supplies')
          .where('userId', isNotEqualTo: userId)
          .get();

      if (querySnapshotForSupplies.docs.isNotEmpty) {
        List<DocumentSnapshot> documents = querySnapshotForSupplies.docs;
        userDataList = await Future.wait(documents.map((doc) async {
          Map<String, dynamic> supplyData = doc.data() as Map<String, dynamic>;

          String companyId = supplyData['companyId'];
          String userIdFromSupply = supplyData['userId'];

          Map<String, dynamic> companyData = {};
          if (companyId != "0") {
            DocumentSnapshot companyDoc = await FirebaseFirestore.instance
                .collection('companies')
                .doc(companyId)
                .get();
            companyData = companyDoc.data() as Map<String, dynamic>;
          }else{
            CompanyInfo myDataInstance = CompanyInfo(
              name: "",
              location: "",
              year: 11111,
              phone: "",
              address: "",
              personNameSurname: "",
              personEmail: "",
              userId: "",
            );
            companyData = myDataInstance.toJson();
          }

          QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where("id", isEqualTo: userIdFromSupply)
              .get();

          Map<String, dynamic> userData = userQuerySnapshot.docs.first.data() as Map<String, dynamic>;

          return CombinedInfo.fromFirestore(supplyData, companyData, userData);
        }).toList());

        print('Gelen CombinedInfo Listesi: $userDataList');
        return userDataList;
      } else {
        print('Belge bulunamadı.');
        return [];
      }
    } catch (e) {
      print('Veri çekme hatası: $e');
    }
    return [];
  }


}
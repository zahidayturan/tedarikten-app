import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tedarikten/models/company_info.dart';
import 'package:tedarikten/models/notification_info.dart';
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

  Future<void> addNotificationToFirestore(NotificationInfo data) async {
    try {
      DocumentReference documentReference = await FirebaseFirestore.instance.collection('notifications').add(data.toJson());
      String documentId = documentReference.id;
      await documentReference.update({'id': documentId});
    } catch (e) {
      print('Kayıt hatası: $e');
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

  Future<String> deleteSupply(String documentId, String uid, String otherUserId) async {
    try {
      QuerySnapshot userQuerySnapshot = await _firestore
          .collection('users')
          .where('id', isEqualTo: uid)
          .get();

      var userDoc = userQuerySnapshot.docs[0];
      var advertList = userDoc['advertList'];
      advertList.remove(documentId);

      await userDoc.reference.update({
        'advertList': advertList,
      });

      if (uid == otherUserId) {
        await _firestore.collection('supplies').doc(documentId).delete();
      }else if(uid != otherUserId){

        QuerySnapshot suppliesQuerySnapshot = await _firestore
            .collection('supplies')
            .where('id', isEqualTo: documentId)
            .get();

        var suppliesDoc = suppliesQuerySnapshot.docs[0];
        var supplyShareList = suppliesDoc['sharersIdList'];
        supplyShareList.remove(uid);
        print(uid);

        await suppliesDoc.reference.update({
          'sharersIdList': supplyShareList,
        });
      }else{

      }

      print('Belge başarıyla silindi.');
      return "Ok";
    } catch (e) {
      print('Belge silinirken bir hata oluştu: $e');
      return "Error";
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

      var querySnapshotForSupplies = await FirebaseFirestore.instance
          .collection('supplies')
          .where(FieldPath.documentId, whereIn: advertList)
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


  Future<String> advertShare(SupplyInfo supply) async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      TUserInfo? userCurrent = await FirestoreService().getUserInfo(user!.uid);
      QuerySnapshot userQuery =
      await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: userCurrent!.id).get();

      if (userQuery.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userQuery.docs.first;
        DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userDoc.id);

        await userRef.update({
          'advertList': FieldValue.arrayUnion([supply.id]),
        });
        await addNotificationToFirestore(NotificationInfo(title: "ilanını paylaştı",date: DateTime.now().toString(),isRead: false,senderId: user!.uid,userId: supply.userId));
      } else {
        print('Kullanıcı bulunamadı');
      }
    } catch (e) {
      return 'Error';
    }

    try {
      await FirebaseFirestore.instance.collection('supplies').doc(supply.id).update({
        'sharersIdList': FieldValue.arrayUnion([user!.uid]),
      });
      return "Ok";
    } catch (e) {
      return 'Error';
    }
  }

  Future<String> advertSave(SupplyInfo supply) async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      TUserInfo? userCurrent = await FirestoreService().getUserInfo(user!.uid);
      QuerySnapshot userQuery =
      await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: userCurrent!.id).get();

      if (userQuery.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userQuery.docs.first;
        DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userDoc.id);

        await userRef.update({
          'registeredList': FieldValue.arrayUnion([supply.id]),
        });

        //registrantsIdList
      } else {
        print('Kullanıcı bulunamadı');
      }
    } catch (e) {
      return 'Error';
    }

    try {
      await FirebaseFirestore.instance.collection('supplies').doc(supply.id).update({
        'registrantsIdList': FieldValue.arrayUnion([user!.uid]),
      });
      return "Ok";
    } catch (e) {
      return 'Error';
    }
  }

  Future<String> advertApply(SupplyInfo supply) async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      TUserInfo? userCurrent = await FirestoreService().getUserInfo(user!.uid);
      QuerySnapshot userQuery =
      await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: userCurrent!.id).get();

      if (userQuery.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userQuery.docs.first;
        DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userDoc.id);

        await userRef.update({
          'appliedList': FieldValue.arrayUnion([supply.id]),
        });

      } else {
        print('Kullanıcı bulunamadı');
      }
    } catch (e) {
      return 'Error';
    }

    try {
      await FirebaseFirestore.instance.collection('supplies').doc(supply.id).update({
        'applicantsIdList': FieldValue.arrayUnion([user!.uid]),
      });
      return "Ok";
    } catch (e) {
      return 'Error';
    }
  }

  Future<List<NotificationInfo>> getNotificationsByUserId(String userId) async {
    final CollectionReference notifications = FirebaseFirestore.instance.collection('notifications');
    QuerySnapshot querySnapshot =
    await notifications.where('userId', isEqualTo: userId).get();

    List<NotificationInfo> notificationsList = querySnapshot.docs
        .map((doc) => NotificationInfo.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    return notificationsList;
  }

}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tedarikten/models/application_supply_info.dart';
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

  Future<List<CombinedInfo>> getActiveSupplyDataFromFirestore(String userId) async {
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
        List<CombinedInfo?> userDataList = await Future.wait(documents.map((doc) async {
          Map<String, dynamic> supplyData = doc.data()! as Map<String, dynamic>;

          DateTime dateLast = DateTime.parse(supplyData['dateLast']);
          String userIdFromSupply = supplyData['userId'];

          DateTime today = DateTime.now();

          if (dateLast.isAfter(today) && userIdFromSupply == userId) {
            String companyId = supplyData['companyId'];

            Map<String, dynamic> companyData = {};
            if (companyId != "0") {
              DocumentSnapshot companyDoc = await FirebaseFirestore.instance
                  .collection('companies')
                  .doc(companyId)
                  .get();
              companyData = companyDoc.data()! as Map<String, dynamic>;
            } else {
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

            Map<String, dynamic> userData = userQuerySnapshot.docs.first.data()! as Map<String, dynamic>;

            return CombinedInfo.fromFirestore(supplyData, companyData, userData);
          } else {
            return null; // Eğer dateLast şartı sağlanmıyorsa null dönmeli
          }
        }).toList());

        // Null'ları filtrele ve geri dön
        return userDataList.where((element) => element != null).cast<CombinedInfo>().toList();
      } else {
        print('Belge bulunamadı.');
        return [];
      }
    } catch (e, stackTrace) {
      print('Veri çekme hatası: $e\n$stackTrace');
      return [];
    }
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

  Future<String> advertApply(ApplicationSupplyInfo application) async {

    //applyInfo oluştur
    //başvuran kişinin listesine id yi ekle
    //ilanın listesine id yi ekle
    User? user = FirebaseAuth.instance.currentUser;
    String documentId = "";

    try {
      DocumentReference documentReference = await FirebaseFirestore.instance.collection('applications').add(application.toJson());
      documentId = documentReference.id;
      await documentReference.update({'id': documentId});
    } catch (e) {
      print('Kayıt hatası: $e');
    }

    try {
      TUserInfo? userCurrent = await FirestoreService().getUserInfo(user!.uid);
      QuerySnapshot userQuery =
      await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: userCurrent!.id).get();

      if (userQuery.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userQuery.docs.first;
        DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userDoc.id);

        await userRef.update({
          'appliedList': FieldValue.arrayUnion([documentId]),
        });

      } else {
        print('Kullanıcı bulunamadı');
      }
    } catch (e) {
      return 'Error';
    }


    try {
      await FirebaseFirestore.instance.collection('supplies').doc(application.supplyId).update({
        'applicantsIdList': FieldValue.arrayUnion([documentId]),
      });
      return "Ok";
    } catch (e) {
      return 'Error';
    }
  }

  Future<String> deleteApply(String supplyId, String userId, String applicationId) async {
    try {
      // Kullanıcı dokümanındaki appliedList güncelleme
      QuerySnapshot userQuerySnapshot = await _firestore
          .collection('users')
          .where('id', isEqualTo: userId)
          .get();

      var userDoc = userQuerySnapshot.docs[0];
      print(userDoc.data());
      var appliedList = List<String>.from(userDoc['appliedList']);
      appliedList.remove(applicationId);

      await userDoc.reference.update({
        'appliedList': appliedList,
      });

      // Tedarik dokümanındaki applicantsIdList güncelleme
      QuerySnapshot suppliesQuerySnapshot = await _firestore
          .collection('supplies')
          .where('id', isEqualTo: supplyId)
          .get();

      var suppliesDoc = suppliesQuerySnapshot.docs[0];
      var applicantsIdList = List<String>.from(suppliesDoc['applicantsIdList']);
      applicantsIdList.remove(applicationId);

      await suppliesDoc.reference.update({
        'applicantsIdList': applicantsIdList,
      });

      // Başvuru dokümanını silme
      await FirebaseFirestore.instance.collection('applications').doc(applicationId).delete();

      return "Ok";
    } catch (e) {
      print('Belge silinirken bir hata oluştu: $e');
      return "Error";
    }
  }

  Future<String> updateApply(String newResponse, String newMessage, String applicationId) async {
    try {
      await FirebaseFirestore.instance.collection('applications').doc(applicationId).update({
        'response': newResponse,
        'message': newMessage,
      });

      return "Ok";
    } catch (e) {
      print('Belge güncellenirken bir hata oluştu: $e');
      return "Error";
    }
  }



  Future<List<CombinedApplicationInfo>> getMyApplications() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      var userQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: user!.uid)
          .get();

      var appliedList = userQuerySnapshot.docs[0]['appliedList'];

      if (appliedList == null || appliedList.isEmpty || appliedList is! Iterable) {
        return [];
      }

      var querySnapshotForApplies = await FirebaseFirestore.instance
          .collection('applications')
          .where(FieldPath.documentId, whereIn: List.from(appliedList))
          .get();

      List<CombinedApplicationInfo> combinedApplications = [];

      for (var doc in querySnapshotForApplies.docs) {
        var supplyId = doc['supplyId'];

        var querySnapshotForSupplies = await FirebaseFirestore.instance
            .collection('supplies')
            .where(FieldPath.documentId, whereIn: [supplyId])
            .get();

        var supplyData = querySnapshotForSupplies.docs[0].data();

        String companyId = supplyData['companyId'];

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

        var applicationData = doc.data();

        var userQuerySnapshotForOwner = await FirebaseFirestore.instance
            .collection('users')
            .where('id', isEqualTo: supplyData['userId'])
            .get();

        Map<String, dynamic> userData = userQuerySnapshotForOwner.docs.first.data();

        var combinedInfo = CombinedApplicationInfo.fromFirestore(
          supplyData,
          applicationData,
          companyData,
          userData,
        );

        combinedApplications.add(combinedInfo);
      }
      return combinedApplications;
    } catch (e) {
      print("Hata oluştu: $e");
      return [];
    }
  }

  Future<List<CombinedApplicationInfo>> getApplicantsIdList() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      var userQuerySnapshot = await FirebaseFirestore.instance
          .collection('supplies')
          .where('userId', isEqualTo: user!.uid)
          .get();

      List<String> applicantsIdList = [];

      for (var doc in userQuerySnapshot.docs) {
        var supplyData = doc.data();
        var currentApplicantsIdList = List<String>.from(supplyData['applicantsIdList']);
        applicantsIdList.addAll(currentApplicantsIdList);
      }

      if (applicantsIdList.isEmpty) {
        // applicantsIdList boşsa boş bir liste döndür
        return [];
      }

      List<CombinedApplicationInfo> combinedApplications = [];

      for (var applicantId in applicantsIdList) {
        var applicationQuerySnapshot = await FirebaseFirestore.instance
            .collection('applications')
            .doc(applicantId)
            .get();

        var applicationData = applicationQuerySnapshot.data();
        if (applicationData == null) {
          // Başvuru verisi bulunamazsa atla
          continue;
        }

        var supplyId = applicationData['supplyId'];
        var supplyQuerySnapshot = await FirebaseFirestore.instance
            .collection('supplies')
            .doc(supplyId)
            .get();

        var supplyData = supplyQuerySnapshot.data();
        if (supplyData == null) {
          // Tedarik verisi bulunamazsa atla
          continue;
        }

        String companyId = supplyData['companyId'];
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

        var applicantUserId = applicationData['applicantUserId'];
        var userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('id', isEqualTo: applicantUserId)
            .get();

        var userData = userQuerySnapshot.docs.first.data();

        var combinedInfo = CombinedApplicationInfo.fromFirestore(
          supplyData,
          applicationData,
          companyData,
          userData,
        );
        combinedApplications.add(combinedInfo);
      }

      return combinedApplications;
    } catch (e) {
      print("Hata oluştu: $e");
      return [];
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

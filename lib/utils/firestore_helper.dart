import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tedarikten/models/user_info.dart';

class FirestoreService {

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<TUserInfo?> getUserInfo(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
      await _firestore.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        return TUserInfo.fromJson(userData);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  Future<void> addAdvertToFirestore(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('supplies').doc().set({
        'userId' : uid,
        'typeSupply': "Ürün Tedariği",
        'nameSupply': "Çelik Malzeme",
      });
    } catch (e) {
      print('Kayıt hatası: $e');
    }
  }


}
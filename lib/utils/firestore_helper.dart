import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tedarikten/models/user_info.dart';

class FirestoreService {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  Future<void> addUser(UserInfo user) async {
    try {
      await usersCollection.add(user.toJson());
    } catch (e) {
      print("Hata: $e");
    }
  }
}
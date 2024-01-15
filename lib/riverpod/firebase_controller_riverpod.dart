import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tedarikten/models/user_info.dart';


class FirebaseControllerRiverpod extends ChangeNotifier {
  bool isuseSet = false;
  User? user = FirebaseAuth.instance.currentUser;
  TUserInfo? userInfo;

  void fetchUser(TUserInfo? user){
    userInfo = user;
    notifyListeners();
  }
  TUserInfo? getUser(){
    return userInfo;
  }

  void setisuseinsert(){
    isuseSet = !isuseSet;
    notifyListeners();
  }

}
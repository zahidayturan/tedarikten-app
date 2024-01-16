import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tedarikten/models/combined_info.dart';


class SuppliesPageRiverpod extends ChangeNotifier {
  int switchCurrentIndex = 0 ;

  void setswitchCurrentIndex(int index) {
    switchCurrentIndex = index ;
    notifyListeners();
  }

}
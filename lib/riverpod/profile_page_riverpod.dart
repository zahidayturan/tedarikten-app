import 'package:flutter/material.dart';


class ProfilePageRiverpod extends ChangeNotifier {
  int switchCurrentIndex = 0 ;

  void setswitchCurrentIndex(int index) {
    switchCurrentIndex = index ;
    notifyListeners();
  }

}
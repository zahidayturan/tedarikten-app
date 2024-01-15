import 'package:flutter/material.dart';


class AddAdvertPageRiverpod extends ChangeNotifier {
  int switchCurrentIndex = 0 ;

  void setswitchCurrentIndex(int index) {
    switchCurrentIndex = index ;
    notifyListeners();
  }

}
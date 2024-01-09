
import 'package:flutter/material.dart';
import 'package:tedarikten/pages/home_page.dart';

class CustomBottomNavBarRiverpod extends ChangeNotifier { //statelesswidget
  int currentIndex = 0 ;

  void setCurrentIndex(int index) {
    currentIndex = index ;
    notifyListeners();
  }

  Widget body(){
    switch(currentIndex) {
      case 0 :
        return const HomePage();
      default :
        return const HomePage();
    }
  }
}
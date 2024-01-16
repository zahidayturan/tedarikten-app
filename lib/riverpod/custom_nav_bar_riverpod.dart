
import 'package:flutter/material.dart';
import 'package:tedarikten/pages/addAdvertPage/add_advert_page.dart';
import 'package:tedarikten/pages/homePage/home_page.dart';
import 'package:tedarikten/pages/suppliesPage/supplies_page.dart';

class CustomBottomNavBarRiverpod extends ChangeNotifier { //statelesswidget
  int currentIndex = 0 ;

  void setCurrentIndex(int index) {
    currentIndex = index ;
    notifyListeners();
  }

  Widget body(){
    print(currentIndex);
    switch(currentIndex) {
      case 0 :
        return const HomePage();
      case 2 :
        return const AddAdvertPage();
      case 3:
        return const SuppliesPage();
      default :
        return const HomePage();
    }
  }
}
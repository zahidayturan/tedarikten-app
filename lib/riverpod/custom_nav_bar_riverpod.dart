
import 'package:flutter/material.dart';
import 'package:tedarikten/pages/addAdvertPage/add_advert_page.dart';
import 'package:tedarikten/pages/homePage/home_page.dart';
import 'package:tedarikten/pages/other_page.dart';
import 'package:tedarikten/pages/social_page.dart';
import 'package:tedarikten/pages/suppliesPage/supplies_page.dart';

class CustomBottomNavBarRiverpod extends ChangeNotifier {
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
      case 1 :
        return SocialPage();
      case 2 :
        return const AddAdvertPage();
      case 3:
        return const SuppliesPage();
      case 4:
        return OtherPage();
      default :
        return const HomePage();
    }
  }
}
import 'package:flutter/material.dart';

class HomePageRiverpod extends ChangeNotifier {

  bool searchModeActivate = false;

  void setSearchMode(bool mode) {
    searchModeActivate = mode ;
    notifyListeners();
  }

  String searchText = "";

  void setSearchText(String text) {
    searchText = text;
    notifyListeners();
  }

  bool setState = false;

  void setHomePage() {
    setState = !setState;
    notifyListeners();
  }

}
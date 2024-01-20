import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tedarikten/models/combined_info.dart';


class ProfilePageRiverpod extends ChangeNotifier {
  int switchCurrentIndex = 0 ;

  void setswitchCurrentIndex(int index) {
    switchCurrentIndex = index ;
    notifyListeners();
  }

  late CombinedInfo combinedInfo;

  void setSupplyDetailsId(CombinedInfo id) {
    combinedInfo = id ;
    notifyListeners();
  }

  CombinedInfo getCombinedInfo(){
    return combinedInfo;
  }

  bool editingMode = false;
  void setEditingMode(bool mode) {
    editingMode = mode ;
    notifyListeners();
  }

  String? type;
  String? description;
  String? name;
  void setType(String text) {
    type = text ;
    notifyListeners();
  }
  void setName(String text) {
    name = text ;
    notifyListeners();
  }
  void setDescription(String text) {
    description = text ;
    notifyListeners();
  }
  void clear(){
    type = null;
    description = null;
    name = null;
    notifyListeners();
  }

  int pushCounter = 0;
  void setPushCounter(int counter) {
    pushCounter = counter ;
    notifyListeners();
  }

}
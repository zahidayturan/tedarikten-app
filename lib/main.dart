import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tedarikten/app/my_app.dart';
import 'package:tedarikten/constants/app_colors.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final appColors = AppColors();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: appColors.blackLight, // navigation bar color
    statusBarColor: appColors.blackLight, // status bar color
  ));

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool showApp = prefs.getBool("showApp") ?? false;
  final bool darkMode = prefs.getBool("darkMode") ?? false;
  runApp(ProviderScope(child: MyAppBase(showApp: showApp!)));
}

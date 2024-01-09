import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tedarikten/app/my_app.dart';
import 'package:tedarikten/constants/app_colors.dart';

void main() {
  final appColors = AppColors();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: appColors.blackLight, // navigation bar color
    statusBarColor: appColors.blackLight, // status bar color
  ));
  runApp(const ProviderScope(child: MyApp()));
}

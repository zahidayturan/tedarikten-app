import 'package:flutter/material.dart';
import 'package:tedarikten/pages/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tedarikten',
      theme: ThemeData(
        useMaterial3: false,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0XFFF2F2F2),
        primaryColor: Color(0xFFE9E9E9),
        canvasColor: Color(0xFF0D1C26),
        fontFamily: "FontNormal"
      ),
      darkTheme: ThemeData(
        useMaterial3: false,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0XFF292D34),
        primaryColor: Color(0xFF0D1C26),
        canvasColor: Color(0xffF2F2F2),
        fontFamily: "FontNormal"
      ),
      themeMode: ThemeMode.dark,
      home: const HomePage(),
    );
  }
}

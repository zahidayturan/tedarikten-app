import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tedarikten/pages/home_page.dart';
import 'package:tedarikten/pages/introductions_page.dart';
import 'package:tedarikten/riverpod_management.dart';
import 'package:tedarikten/utils/firestore_helper.dart';


class MyAppBase extends ConsumerStatefulWidget {
  final bool? showApp;
  const MyAppBase({Key ? key,required this.showApp}) :super(key :key);

  @override
  ConsumerState<MyAppBase> createState() => _MyAppBase();
}

class _MyAppBase extends ConsumerState<MyAppBase> {

  void loadData()  async {
    User? user = FirebaseAuth.instance.currentUser;
    if(user != null){
      await FirestoreService().getUserInfo(user!.uid).then((value) {
        ref.read(firebaseControllerRiverpod).fetchUser(value!);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    var watch = ref.watch(customNavBarRiverpod);
    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: MaterialApp(
        title: 'Tedarikten',
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
        themeMode: ThemeMode.light,
        home: widget.showApp == true ? watch.body() : IntroductionPage(),
      ),
    );
  }
}

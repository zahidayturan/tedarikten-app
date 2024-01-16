import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/models/user_info.dart';
import 'package:tedarikten/pages/login_page.dart';
import 'package:tedarikten/pages/profileInfoPage/my_active_posts.dart';
import 'package:tedarikten/pages/profileInfoPage/my_posts.dart';
import 'package:tedarikten/riverpod_management.dart';
import 'package:tedarikten/utils/firestore_helper.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);
  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPage();
}

class _NotificationsPage extends ConsumerState<NotificationsPage> {
  User? user = FirebaseAuth.instance.currentUser;
  FirestoreService firestoreService = FirestoreService();
  late TUserInfo? userData;
  @override
  void initState(){
    super.initState();
    if(user != null){
      getUser();
    }
  }

  void getUser() async {
    userData = ref.read(firebaseControllerRiverpod).getUser();
    if (userData != null) {
      print('User Info - ID: ${userData!.id}, Name: ${userData!.name}, Surname: ${userData!.surname}');
    } else {
      print('User not found');
    }
  }



  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    var read = ref.read(profilePageRiverpod);
    int switchIndex = read.switchCurrentIndex;
    var size = MediaQuery.of(context).size;
    if(user != null){
      getUser();
    }
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            topWidget(user),
          ],
        ),
      ),
    );
  }

  Widget topWidget(User? user){
    final appColors = AppColors();
    return Container(
      height: 200,
      child: Stack(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
                color: appColors.blueDark,
            ),
          ),
          Positioned(
              right: -60,
              top: -20,
              child: Icon(Icons.notifications_rounded,color: appColors.blueLight.withOpacity(0.2),size: 176,)),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                pageTopController(),
                Padding(
                  padding: const EdgeInsets.only(top: 36,left: 36),
                  child: getText("Okunmamış\nBildiriminiz Var","1 Adet\n", 18, appColors.white),
                )
                
              ],
            ),
          ),

        ],
      ),);
  }
  Widget pageTopController(){
    final appColors = AppColors();
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: appColors.blueDark,
                borderRadius: BorderRadius.all(Radius.circular(5))
            ),
            child: Image(
              color: appColors.white,
              image: AssetImage(
                  "assets/icons/arrow.png"
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text("Bildirimler",style: TextStyle(color: appColors.white,fontSize: 18,fontFamily: "FontNormal"),),
        ),
      ],
    );
  }


  Widget getText(String textNormal, String textBold,double fontSize, Color color){
    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(text: textBold,style: TextStyle(fontFamily: "FontBold",fontSize: fontSize,color: color)),
          TextSpan(text: textNormal, style: TextStyle(fontFamily: "FontNormal",fontSize: fontSize,color: color)),
        ],
      ),
    );
  }


}


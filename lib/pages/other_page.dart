import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/riverpod_management.dart';
import 'package:tedarikten/utils/firestore_helper.dart';

class OtherPage extends ConsumerStatefulWidget {

  OtherPage({Key? key}) : super(key: key);
  @override
  ConsumerState<OtherPage> createState() => _OtherPage();
}

class _OtherPage extends ConsumerState<OtherPage> {

  User? user = FirebaseAuth.instance.currentUser;
  FirestoreService firestoreService = FirestoreService();
  @override
  void initState(){
    super.initState();
  }

  final appColors = AppColors();



  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    var read = ref.read(profilePageRiverpod);
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            topWidget(user),
            Container(
              height: size.height-300,
              width: size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Center(
                    child: Text("Tedarikten\nkulandığınız için\nteşekkür ederiz",style: TextStyle(
                      color: appColors.blueDark,
                      fontSize: 18,
                      fontFamily: "FontNormal"
                    ),textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 120,
                    child: Image(
                      //color: appColors.orange,
                      image: AssetImage(
                          "assets/logo/splash.png"
                      ),
                    ),
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget topWidget(User? user){

    return Container(
      height: 230,
      child: Stack(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
                color: appColors.blueLight
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                pageTopController(),
            Container(
              width: 200,
              child: Image(
                //color: appColors.orange,
                image: AssetImage(
                    "assets/logo/logo_text.png"
                ),
              ),
            ),
                SizedBox(height: 50,)
              ],
            ),
          ),

        ],
      ),);
  }
  Widget pageTopController(){
    final appColors = AppColors();
    var readNavBar = ref.read(customNavBarRiverpod);
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            readNavBar.setCurrentIndex(0);
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
          child: Text("",style: TextStyle(color: appColors.white,fontSize: 18,fontFamily: "FontNormal"),),
        ),
        Spacer(),
        GestureDetector(
          onTap: () {
            showQuesitonDialog();
          },
          child: Container(
            width: 30,
            height: 30,
            padding: EdgeInsets.all(4),
            child: Image(
              color: appColors.white,
              image: AssetImage(
                  "assets/icons/question.png"
              ),
            ),),
        )
      ],
    );
  }

  void showQuesitonDialog(){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          backgroundColor: appColors.blueDark,
          duration: const Duration(seconds: 3),
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          content: const Center(
            child: Text(
              "FezaiTech",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'FontNormal',
                height: 1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)))
      ),
    );
  }


}


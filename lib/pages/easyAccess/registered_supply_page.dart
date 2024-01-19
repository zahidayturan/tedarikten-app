import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/riverpod_management.dart';
import 'package:tedarikten/utils/firestore_helper.dart';

class RegisteredSupplyPage extends ConsumerStatefulWidget {

  RegisteredSupplyPage({Key? key}) : super(key: key);
  @override
  ConsumerState<RegisteredSupplyPage> createState() => _RegisteredSupplyPage();
}

class _RegisteredSupplyPage extends ConsumerState<RegisteredSupplyPage> {

  User? user = FirebaseAuth.instance.currentUser;
  FirestoreService firestoreService = FirestoreService();
  final appColors = AppColors();
  @override



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
              child: SizedBox(),
            ),
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
                color: appColors.blue
            ),
          ),
          pageInfo(),

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
            Navigator.pop(context);
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
          child: Text("Kayıtlı İşlemler",style: TextStyle(color: appColors.white,fontSize: 18,fontFamily: "FontNormal"),),
        ),
        Spacer(),
        Container(
          width: 30,
          height: 30,
          padding: EdgeInsets.all(4),
          child: Image(
            color: appColors.white,
            image: AssetImage(
                "assets/icons/question.png"
            ),
          ),)
      ],
    );
  }

  Widget pageInfo(){

    return Stack(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
              color: appColors.blue
          ),
        ),
        Positioned(
          right: 10,
          top: -20,
          child: SizedBox(
            width: 150,
            height: 150,
            child: Image(
              color: appColors.blueDark.withOpacity(0.8),
              image: AssetImage(
                  "assets/icons/bookmark.png"
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              pageTopController(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 36),
                    child: getItemCount()
                  ),
                ],
              ),
              SizedBox()
            ],
          ),
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
  
  Widget getItemCount(){
    return FutureBuilder<String>(
      future: FirestoreService().getRegisteredCountFromFirestore(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('?');
        } else {
          String registeredCount = snapshot.data ?? "0";
          return registeredCount != "0" ? Center(
            child:getText("Kayıtlı İşleminiz\nBulunmakta","$registeredCount Adet\n", 18, appColors.white),
          ) : Center(
            child:getText("Kayıtlı İşleminiz\n","Bulunmamakta", 18, appColors.white),
          ) ;
        }
      },
    );
  }


}


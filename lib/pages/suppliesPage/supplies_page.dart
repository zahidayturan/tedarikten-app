import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/models/user_info.dart';
import 'package:tedarikten/pages/login_page.dart';
import 'package:tedarikten/pages/profileInfoPage/my_active_posts.dart';
import 'package:tedarikten/pages/profileInfoPage/my_posts.dart';
import 'package:tedarikten/riverpod_management.dart';
import 'package:tedarikten/utils/firestore_helper.dart';

class SuppliesPage extends ConsumerStatefulWidget {
  const SuppliesPage({Key? key}) : super(key: key);
  @override
  ConsumerState<SuppliesPage> createState() => _SuppliesPage();
}

class _SuppliesPage extends ConsumerState<SuppliesPage> {
  late PageController _pageViewController;
  User? user = FirebaseAuth.instance.currentUser;
  FirestoreService firestoreService = FirestoreService();
  @override
  void initState(){
    super.initState();
    _pageViewController = PageController(initialPage: ref.read(profilePageRiverpod).switchCurrentIndex);
  }




  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    var read = ref.read(profilePageRiverpod);
    int switchIndex = read.switchCurrentIndex;
    var size = MediaQuery.of(context).size;
    if(user != null){

    }
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            topWidget(user),
            Container(
              height: size.height-300,
              width: size.width,
              child: PageView(
                  physics: BouncingScrollPhysics(),
                  controller: _pageViewController,
                  onPageChanged: (value) {
                    read.setswitchCurrentIndex(value);
                    setState(() {
                    });
                  },
                  children: [

                  ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget topWidget(User? user){
    final appColors = AppColors();
    return Container(
      height: 230,
      child: Stack(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
                color: appColors.blackLight
            ),
          ),
          Positioned(
            right: -20,
            top: -20,
            child: SizedBox(
              width: 180,
              height: 180,
              child: Image(
                color: appColors.orange.withOpacity(0.6),
                image: AssetImage(
                    "assets/logo/icon.png"
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
                      child: getText("Bekleyen\nBaşvurunuz\nBulunmakta","0 Adet\n", 18, appColors.white),
                    ),
                  ],
                ),
                changeMenuButton()],
            ),
          ),

        ],
      ),);
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
                color: appColors.white,
                borderRadius: BorderRadius.all(Radius.circular(5))
            ),
            child: Image(
              color: appColors.blackLight,
              image: AssetImage(
                  "assets/icons/arrow.png"
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text("Tedarikler",style: TextStyle(color: appColors.white,fontSize: 18,fontFamily: "FontNormal"),),
        ),

      ],
    );
  }

  Widget userInfo(User? user){
    final appColors = AppColors();
    if(user == null) {
      return Column(
        children: [
          Text("Henüz giriş yapmadınız",
            style: TextStyle(color: appColors.white, fontSize: 16),),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                ).then((value) => setState(() {}));
              },
              child: Container(
                height: 30,
                width: 80,
                decoration: BoxDecoration(
                    color: appColors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5))
                ),
                child: Center(child: Text(
                  "Giriş Yap", style: TextStyle(color: appColors.blue),)),),
            ),
          )
        ],
      );
    }/*
    else if(userData == null){
      return Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
                fontSize: 15,
                height: 1,
                color: appColors.white
            ),
            children: <TextSpan>[
              TextSpan(text: 'Profil bilgileri', style: TextStyle(fontFamily: "FontNormal")),
              TextSpan(text: ' yükleniyor ',style: TextStyle(fontFamily: "FontBold")),
            ],
          ),
        ),
      );
    }
    else if(user != null){
      return SizedBox(
        height: 96,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                  color: appColors.white,
                  shape: BoxShape.circle
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${userData!.name} ${userData!.surname}",style: TextStyle(color: appColors.white,fontFamily: "FontBold",fontSize: 16),),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(userData!.profession,style: TextStyle(color: appColors.white,fontSize: 15),),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text("${userData!.city} / ${userData!.country}",style: TextStyle(color: appColors.white,fontSize: 14),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: GestureDetector(
                      onTap: () async{
                      },
                      child: getUserPanelButton("Profili Düzenle"),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () async{
                    },
                    child: getUserPanelButton("${userData!.followList?.length} Takip"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () async{
                    },
                    child: getUserPanelButton("${userData!.followerList?.length} Takipçi"),
                  ),
                ),
                GestureDetector(
                  onTap: () async{
                  },
                  child: getUserPanelButton("${userData!.advertList?.length} İlan"),
                ),
              ],)
          ],
        ),
      );
    }*/
    else{
      return Center(child: Text("Bir sorun oluştu",style:  TextStyle(color: appColors.white),));
    }
  }

  Widget getUserPanelButton(String text){
    final appColors = AppColors();
    return Container(
      decoration:BoxDecoration(
          color: appColors.blueDark,
          borderRadius: BorderRadius.all(Radius.circular(5))
      ),child: Center(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Text(text,style: TextStyle(color: appColors.white) ,),
    )),);
  }

  Widget changeMenuButton(){
    var read = ref.read(suppliesPageRiverpod);
    int switchIndex = read.switchCurrentIndex;
    var size = MediaQuery.of(context).size;
    final appColors = AppColors();
    return Container(
        width: size.width-72,
        height: 40,
        decoration: BoxDecoration(
            color: appColors.white,
            borderRadius: BorderRadius.all(Radius.circular(5))
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Stack(
            children: [
              AnimatedPadding(
                curve: Curves.linearToEaseOut,
                duration: Duration(milliseconds: 800),
                padding: EdgeInsets.only(left: switchIndex == 1 ? (size.width-84)/2: 0,right: switchIndex == 0 ? (size.width-84)/2 : 0),
                child: Container(
                  decoration: BoxDecoration(
                      color: appColors.blackLight,
                      borderRadius: BorderRadius.all(Radius.circular(2))
                  ),),
              ),
              SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            read.setswitchCurrentIndex(0);
                            _pageViewController.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                          });
                        },
                        child: Text(
                          "Başvurularım",style: TextStyle(
                            color: switchIndex == 0 ? appColors.white : appColors.blackLight
                        ),

                        )),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            read.setswitchCurrentIndex(1);
                            _pageViewController.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                          });
                        },
                        child: Text("Başvuranlar",style: TextStyle(
                            color: switchIndex == 1 ? appColors.white : appColors.blackLight
                        ),))
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }
}


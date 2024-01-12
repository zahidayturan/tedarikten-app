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

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);
  @override
  ConsumerState<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends ConsumerState<ProfilePage> {
  final PageController _pageViewController = PageController();
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


    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            topWidget(user),
            Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                height: size.height-320,
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
                      MyPosts(),
                      MyActivePosts()
                    ]),
              ),
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
                color: appColors.blue
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                pageTopController(),
                userInfo(user),
                changeMenuButton()],
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
          child: Text("Profil",style: TextStyle(color: appColors.white,fontSize: 18,fontFamily: "FontNormal"),),
        ),
        Spacer(),
        Container(
            width: 30,
            height: 30,
            child: Image(
          color: appColors.white,
          image: AssetImage(
              "assets/icons/settings.png"
          ),
        ),)
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
    }
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
                    child: Text("Ürün Tedarikçisi",style: TextStyle(color: appColors.white,fontSize: 15),),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text("Ankara/Türkiye",style: TextStyle(color: appColors.white,fontSize: 14),),
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
                  child: getUserPanelButton("0 Takip"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () async{
                  },
                  child: getUserPanelButton("0 Takipçi"),
                ),
              ),
              GestureDetector(
                onTap: () async{
                },
                child: getUserPanelButton("0 İlan"),
              ),
            ],)
          ],
        ),
      );
    }
    else{
      return Center(child: Text("Bir sorun oluştu",style:  TextStyle(color: appColors.blueDark),));
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
    var read = ref.read(profilePageRiverpod);
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
                    color: appColors.blue,
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
                          "Paylaşımlarım",style: TextStyle(
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
                      child: Text("Aktif İlanlarım",style: TextStyle(
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


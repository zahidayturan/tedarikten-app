import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/models/user_info.dart';
import 'package:tedarikten/pages/addAdvertPage/be_supplier.dart';
import 'package:tedarikten/pages/addAdvertPage/find_supply.dart';
import 'package:tedarikten/pages/login_page.dart';
import 'package:tedarikten/riverpod_management.dart';
import 'package:tedarikten/utils/firestore_helper.dart';

class AddAdvertPage extends ConsumerStatefulWidget {
  const AddAdvertPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AddAdvertPage> createState() => _AddAdvertPageState();
}

class _AddAdvertPageState extends ConsumerState<AddAdvertPage> {
  User? user = FirebaseAuth.instance.currentUser;
  FirestoreService firestoreService = FirestoreService();
  late TUserInfo? userData;
  late PageController _pageViewController;
  @override
  void initState(){
    super.initState();
    _pageViewController = PageController(initialPage: ref.read(addAdvertPageRiverpod).switchCurrentIndex);
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
    var readNavBar = ref.read(customNavBarRiverpod);
    var read = ref.read(addAdvertPageRiverpod);
    int switchIndex = read.switchCurrentIndex;
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        readNavBar.setCurrentIndex(0);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                topWidget(user),
                Container(
                  height: size.height-310,
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: FindSupply(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: BeSupplier(),
                        )
                      ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget topWidget(User? user){
    final appColors = AppColors();
    return SizedBox(
      height: 230,
      child: Stack(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
                color: appColors.orange
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                pageTopController(),
                userInfo(user),
                changeMenuButton(),
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
                color: appColors.white,
                borderRadius: BorderRadius.all(Radius.circular(5))
            ),
            child: Image(
              color: appColors.orange,
              image: AssetImage(
                  "assets/icons/arrow.png"
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text("İlan Oluştur",style: TextStyle(color: appColors.white,fontSize: 18,fontFamily: "FontNormal"),),
        ),
        Spacer(),
        Container(
          width: 30,
          height: 30,
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: appColors.white,
            shape: BoxShape.circle
          ),
          child: Image(
            color: appColors.orange,
            image: AssetImage(
                "assets/icons/question.png"
            ),
          ),)
      ],
    );
  }

  Widget userInfo(User? user){
    final appColors = AppColors();
    var size = MediaQuery.of(context).size;
    if(user == null){
      return Column(
        children: [
          Text("Henüz giriş yapmadınız",style: TextStyle(color: appColors.white,fontSize: 16),),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                ).then((value) => setState((){}));
              },
              child: Container(
                height: 30,
                width:80,
                decoration:BoxDecoration(
                    color: appColors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5))
                ),child: Center(child: Text("Giriş Yap",style: TextStyle(color: appColors.blue) ,)),),
            ),
          )
        ],
      );
    }
    else if(userData == null){
      return Container(
        height: 110,
        width: size.width,
        decoration: BoxDecoration(
            color: appColors.white,
            borderRadius: BorderRadius.all(Radius.circular(5))
        ),
        child: Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                  fontSize: 15,
                  height: 1,
                  color: appColors.blackLight
              ),
              children: <TextSpan>[
                TextSpan(text: 'Profil bilgileri', style: TextStyle(fontFamily: "FontNormal")),
                TextSpan(text: ' yükleniyor ',style: TextStyle(fontFamily: "FontBold")),
              ],
            ),
          ),
        ),
      );
    }else if(user != null){
      return Container(
        height: 110,
        width: size.width,
        decoration: BoxDecoration(
            color: appColors.white,
            borderRadius: BorderRadius.all(Radius.circular(5))
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    color: appColors.blackLight,
                    shape: BoxShape.circle
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${userData!.name} ${userData!.surname}",style: TextStyle(color: appColors.blackLight,fontFamily: "FontBold"),),
                    Text("${user!.email}",style: TextStyle(color: appColors.blackLight),),
                  ],
                ),
              ),
              Spacer(),
              RotatedBox(
                  quarterTurns: 3,
                  child: Text("Seçil Profil",style: TextStyle(color: appColors.orange),))
            ],
          ),
        ),
      );
    }
    else{
      return Center(child: Text("Bir sorun oluştu",style:  TextStyle(color: appColors.blueDark),));
    }
  }

  Widget changeMenuButton(){
    var read = ref.read(addAdvertPageRiverpod);
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
                      color: appColors.orange,
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
                            _pageViewController.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.linearToEaseOut,);
                          });
                        },
                        child: Text(
                          "Tedarik Bul",style: TextStyle(
                            color: switchIndex == 0 ? appColors.white : appColors.blackLight
                        ),

                        )),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            read.setswitchCurrentIndex(1);
                            _pageViewController.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.linearToEaseOut,);
                          });
                        },
                        child: Text("Tedarikçi Ol",style: TextStyle(
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
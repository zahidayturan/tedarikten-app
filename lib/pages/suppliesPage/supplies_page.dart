import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/pages/login_page.dart';
import 'package:tedarikten/pages/suppliesPage/my_application_supplies.dart';
import 'package:tedarikten/pages/suppliesPage/other_applications._supplies.dart';
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
  final appColors = AppColors();
  @override
  void initState(){
    super.initState();
    _pageViewController = PageController(initialPage: ref.read(suppliesPageRiverpod).switchCurrentIndex);
  }


  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    var read = ref.read(suppliesPageRiverpod);
    int switchIndex = read.switchCurrentIndex;
    var size = MediaQuery.of(context).size;
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: MyApplicationsSupply(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: OtherApplicationsSupply(),
                    )

                  ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget topWidget(User? user){
    var read = ref.read(suppliesPageRiverpod);
    int switchIndex = read.switchCurrentIndex;
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
                    user != null ?
                    Padding(
                      padding: const EdgeInsets.only(left: 36),
                      child: switchIndex == 0 ? getItemCountForMy() : getItemCountForOther(),
                    ) :
                    Padding(
                      padding: const EdgeInsets.only(left: 36),
                      child: Text("Henüz\ngiriş\nyapmadınız",style: TextStyle(color: appColors.white),),
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
    }
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

  Widget getItemCountForMy(){
    return FutureBuilder<String>(
      future: FirestoreService().getApplyActiveCountFromFirestore(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(color: appColors.orange,);
        } else if (snapshot.hasError) {
          return const Text('?');
        } else {
          String count = snapshot.data ?? "0";
          return Center(
            child: count != "0" ?
            getText("Bekleyen\nBaşvurunuz\nBulunmakta","$count Adet\n", 18, appColors.white)
            : getText("Bulunmamakta","Bekleyen\nBaşvurunuz\n", 18, appColors.white),
          );
        }
      },
    );
  }

  Widget getItemCountForOther(){
    return FutureBuilder<String>(
      future: FirestoreService().getOtherApplyActiveCountFromFirestore(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(color: appColors.orange,);
        } else if (snapshot.hasError) {
          return const Text('?');
        } else {
          String count = snapshot.data ?? "0";
          return Center(
            child:count != "0" ?
            getText("Tarafınıza Gelen\nBaşvuru\nBulunmakta","$count Adet\n", 18, appColors.white)
            : getText("Gelen\nBaşvuru\n","Bulunmamakta", 18, appColors.white)
          );
        }
      },
    );
  }
}


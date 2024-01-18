import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/models/user_info.dart';
import 'package:tedarikten/pages/homePage/active_adverts.dart';
import 'package:tedarikten/pages/homePage/my_active_adverts.dart';
import 'package:tedarikten/pages/login_page.dart';
import 'package:tedarikten/pages/search_page.dart';
import 'package:tedarikten/riverpod_management.dart';
import 'package:tedarikten/ui/home_app_bar.dart';
import 'package:tedarikten/ui/navigation_bar.dart';
import 'package:tedarikten/utils/firestore_helper.dart';


class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<HomePage> {
  FirestoreService firestoreService = FirestoreService();
  @override
  Widget build(BuildContext context) {
    final appColors = AppColors();
    var read = ref.read(homePageRiverpod);
    ref.watch(homePageRiverpod).searchModeActivate;
    return SafeArea(
      child: Scaffold(
        backgroundColor: appColors.whiteDark,
        appBar: HomeAppBar(),
        bottomNavigationBar: const CustomBottomNavigationBar(),
        drawer: getDrawer(),
        drawerEnableOpenDragGesture: true,
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: read.searchModeActivate == false ?
          Column(children: [
            easyAccessContainer(),
            SizedBox(height: 16,),
            MyActiveAdverts(),
            SizedBox(height: 10,),
            Expanded(child: ActiveAdverts()),
          ],) :
          SearchPage(),
        )
      ),
    );
  }



  Widget easyAccessContainer (){
    final appColors = AppColors();
    return SizedBox(
      height: 114,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            getContainerForEasyAccess(appColors.pink,const Color(0XFFB82F43),"Acil\n","Olan\nİlanları\nGörüntüle","assets/icons/sandWatch.png"),
            const SizedBox(width: 10,),
            getContainerForEasyAccess(appColors.orange,const Color(0XFFF99000),"Son\n48 Saat\n","İlanlarını\nGörüntüle","assets/icons/clock.png"),
            const SizedBox(width: 10,),
            getContainerForEasyAccess(appColors.blue,const Color(0XFF8FA9B1),"Yakınında\n","Olan\nİlanları\nGörüntüle","assets/icons/location.png"),
            const SizedBox(width: 10,),
            getContainerForEasyAccess(appColors.blueDark,const Color(0XFF16697A),"Kayıtlı\n","İlanları\nGörüntüle","assets/icons/bookmark.png"),
          ],
        ),
      ),
    );
  }

  Widget getDrawer(){
    User? user = FirebaseAuth.instance.currentUser;
    final appColors = AppColors();
    var size = MediaQuery.of(context).size;
    return Drawer(
      backgroundColor: appColors.whiteDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          userInfo(),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: GestureDetector(
                    onTap: () async{
                      final SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setBool("showApp", false);
                      await FirebaseAuth.instance.signOut();
                      //ref.read(customNavBarRiverpod).setCurrentIndex(0);
                      setState(() {
                      });
                    },
                    child: getDrawerButtonElement("App sıfırla *debug tekrar aç")),
              ),
              Visibility(
                visible: user != null,
                child: GestureDetector(
                  onTap: () async{
                    await FirebaseAuth.instance.signOut();
                    //ref.read(customNavBarRiverpod).setCurrentIndex(0);

                    setState(() {
                    });
                  },
                    child: getDrawerButtonElement("Çıkış Yap")),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  width: size.width/3,
                  child: Image(
                      color: appColors.blueDark,
                      image: AssetImage(
                          "assets/logo/logo_text.png")),
                ),
              ),
              Text("FezaiTech"),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text("Version 0.0.0"),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget getDrawerButtonElement(String text){
    final appColors = AppColors();
    return Container(
      decoration: BoxDecoration(
        color: appColors.blueDark,
        borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 32),
        child: Text(text,style: TextStyle(
          color: appColors.white
        ),),
      ),
    );
  }

  Widget userInfo(){
    User? user = FirebaseAuth.instance.currentUser;
    final appColors = AppColors();

    return user != null ? FutureBuilder(
      future: firestoreService.getUserInfo(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Hata: ${snapshot.error}");
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text("Kullanıcı bulunamadı"),
          );
        } else {
          TUserInfo userData = snapshot.data!;

          String name = userData.name;
          String surname = userData.surname;
          return Padding(
            padding: const EdgeInsets.only(left: 16,top: 16),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      color: appColors.white,
                      shape: BoxShape.circle
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: RichText(
                      text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: 'Merhaba ', style: TextStyle(color: appColors.black,fontFamily: "FontNormal",fontSize: 15)),
                            TextSpan(text: '${name}',style: TextStyle(color: appColors.black,fontFamily: "FontBold",fontSize: 15)),
                        ],
                    ))
                ),
                Container()
              ],
            ),
          );
        }
      },
    ) : Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8,top: 16),
          child: Text("Henüz giriş yapmadınız",style: TextStyle(color: appColors.blackLight,fontSize: 16),),
        ),
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
                  color: appColors.orange,
                  borderRadius: BorderRadius.all(Radius.circular(5))
              ),child: Center(child: Text("Giriş Yap",style: TextStyle(color: appColors.white) ,)),),
          ),
        )
      ],
    );
  }
  
  Widget getContainerForEasyAccess(Color color,Color colorGradient,String textBold, String textNormal, String icon){
    final appColors = AppColors();
    return Container(
      height: 110,
      width: 110,
      decoration: BoxDecoration(
        color: color,
        gradient: LinearGradient(
          transform: const GradientRotation(140),
            colors: [
          color,
          colorGradient
        ]),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
        BoxShadow(
          color: appColors.blackLight.withOpacity(0.6),
          blurRadius: 1,
          offset: const Offset(0,1),
        )
        ]
      ),
      child: Stack(
        fit: StackFit.loose,
        children: [
          Positioned(
            right: 6,
            top: 6,
            child: RichText(
              textDirection: TextDirection.rtl,
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: textBold, style: const TextStyle(fontFamily: "FontBold",fontSize: 16)),
                  TextSpan(text: textNormal,style: const TextStyle(fontFamily: "FontNormal",fontSize: 16)),
                ],
              ),
            ),
          ),
          Positioned(
            left: 4,
            bottom: 10,
            child: SizedBox(
              width: 80,
              height: 80,
              child: Image(
                color: appColors.white.withOpacity(0.2),
                image: AssetImage(
                  icon,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
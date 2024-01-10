import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/pages/addAdvertPage/be_supplier.dart';
import 'package:tedarikten/pages/addAdvertPage/find_supply.dart';
import 'package:tedarikten/pages/login_page.dart';
import 'package:tedarikten/riverpod_management.dart';

class AddAdvertPage extends ConsumerStatefulWidget {
  const AddAdvertPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AddAdvertPage> createState() => _AddAdvertPageState();
}

class _AddAdvertPageState extends ConsumerState<AddAdvertPage> {

  @override
  void initState() {
    super.initState();
  }
  User? user = FirebaseAuth.instance.currentUser;

  Widget build(BuildContext context) {
    var readNavBar = ref.read(customNavBarRiverpod);
    return WillPopScope(
      onWillPop: () async {
        readNavBar.setCurrentIndex(0);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              topWidget(user)
            ],
          ),
        ),
      ),
    );
  }

  PageController _pageViewController = PageController();

  Widget topWidget(User? user){
    final appColors = AppColors();
    var read = ref.read(addAdvertPageRiverpod);
    int switchIndex = read.switchCurrentIndex;
    var size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(
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
          ),),
        Padding(
          padding: EdgeInsets.all(10),
          child: SizedBox(
            height: size.height-400,
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
                FindSupply(),
                BeSupplier()
            ]),
          ),
        ),
      ],
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
    return Container(
      height: 110,
      width: size.width,
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      child: user != null ?
      FutureBuilder(
        future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("Hata: ${snapshot.error}");
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Text("Kullanıcı bulunamadı");
          }else {
            Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;

            String name = userData['name'];
            String surname = userData['surname'];
            return Padding(
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
                        Text("${name} ${surname}",style: TextStyle(color: appColors.blackLight,fontFamily: "FontBold"),),
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
            );
          }
        },
      ) :
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Henüz giriş yapmadınız.\nİlan oluşturmak için giriş yapın",style: TextStyle(color: appColors.blackLight,height: 1,fontSize: 16),textAlign: TextAlign.center,),
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
          ),
        ],
      ),
    );
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
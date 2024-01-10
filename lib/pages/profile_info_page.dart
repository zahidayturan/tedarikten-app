import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/pages/login_page.dart';
import 'package:tedarikten/riverpod_management.dart';
import 'package:tedarikten/utils/firestore_helper.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);
  @override
  ConsumerState<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            topWidget(user)
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
    return user != null ? FutureBuilder(
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
            return Row(
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
                    children: [
                      Text("${name} ${surname}",style: TextStyle(color: appColors.white),),
                      Text("${user!.email}",style: TextStyle(color: appColors.white),),
                      GestureDetector(
                        onTap: () async{
                        },
                        child: Container(
                          decoration:BoxDecoration(
                              color: appColors.blueDark,
                              borderRadius: BorderRadius.all(Radius.circular(5))
                          ),child: Center(child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text("Profili Düzenle",style: TextStyle(color: appColors.white) ,),
                          )),),
                      ),
                    ],
                  ),
                ),
                Container()
              ],
            );
          }
         },
    ) : Column(
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addUserData() async {
    String id = "122";
    String name = "Abuzer";
    String surname = "Kömürcü";

    if (id.isNotEmpty && name.isNotEmpty && surname.isNotEmpty) {
      try {
        await _firestore.collection('users').doc(id).set({
          'name': name,
          'surname': surname,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veri başarıyla eklendi'),
          ),
        );
      } catch (e) {
        print('Hata: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veri eklenirken bir hata oluştu'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen tüm alanları doldurun'),
        ),
      );
    }
  }


}


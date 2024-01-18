import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/pages/notifications_page.dart';
import 'package:tedarikten/pages/profileInfoPage/profile_info_page.dart';
import 'package:tedarikten/pages/search_page.dart';
import 'package:tedarikten/utils/firestore_helper.dart';
import '../riverpod_management.dart';

class HomeAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  HomeAppBar({Key? key}) : super(key: key);

  @override
  _HomeAppBarState createState() => _HomeAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(64.0); // AppBar'ın tercih edilen boyutunu ayarlayabilirsiniz.
}

class _HomeAppBarState extends ConsumerState<HomeAppBar> {

  final TextEditingController textController = TextEditingController();
  Size get preferredSize => const Size.fromHeight(64);

  Widget build(BuildContext context){
    final appColors = AppColors();
    var read = ref.read(homePageRiverpod);
    var size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, //horizantal
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 4),
              child: GestureDetector(
                onTap: () {
                  if(read.searchModeActivate == false){
                    Scaffold.of(context).openDrawer();
                  }else if(read.searchModeActivate == true){
                    read.setSearchMode(false);
                    setState(() {

                    });
                  }
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.linear,
                  width: 38,
                  height: 38,

                  decoration: BoxDecoration(
                      color:  read.searchModeActivate == false ? appColors.blue : appColors.orange,
                      borderRadius: BorderRadius.all(Radius.circular(read.searchModeActivate == false ? 5 : 50))
                  ),
                  child: AnimatedRotation(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.linear,
                    turns: read.searchModeActivate == false ? 0.5 : 1,
                    child: Icon(
                      read.searchModeActivate == false ?
                      Icons.menu_rounded :
                      Icons.close_rounded,
                      color: appColors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if(read.searchModeActivate == false){
                    read.setSearchMode(true);
                  }
                  setState(() {

                  });
                },
                child: AnimatedPadding(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.linear,
                  padding:  EdgeInsets.only(left: 4,right: read.searchModeActivate == false ? 4 : 12),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.linear,
                    height: 44,
                    decoration: BoxDecoration(
                        color: read.searchModeActivate == false ? appColors.blue : appColors.orange,
                        borderRadius: BorderRadius.all(Radius.circular(5))
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 4,right: 4),
                            child: read.searchModeActivate == false ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(text: 'Tedarik veya tedarikçi ', style: TextStyle(fontFamily: "FontNormal",fontSize: 12)),
                                      TextSpan(text: 'arayın',style: TextStyle(fontFamily: "FontBold",fontSize: 12)),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(text: 'örn: ', style: TextStyle(fontFamily: "FontBold",fontSize: 9)),
                                      TextSpan(text: 'metal sanayi, hizmet tedariği',style: TextStyle(fontFamily: "FontNormal",fontSize: 9)),
                                    ],
                                  ),
                                ),
                              ],
                            ) :
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: appColors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5)
                                )),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: textController,
                                  style: TextStyle(
                                    color: appColors.black,
                                    height: 1,
                                    fontSize: 14
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Aramak istediğiniz tedarik adını yazın",
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                      fontSize: 13
                                    )
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if(read.searchModeActivate == true){
                              read.setSearchText(textController.text);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Icons.search_rounded,size: 26,color: appColors.white,),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: read.searchModeActivate == false,
              child: Padding(
                padding: const EdgeInsets.only(left: 4,right: 4),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotificationsPage()),
                    );
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    child: Icon(
                      Icons.notifications_rounded,
                      color: appColors.blue,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: read.searchModeActivate == false,
              child: Padding(
                padding: const EdgeInsets.only(left: 4,right: 10),
                child: GestureDetector(
                  onTap: () async{
                    User? user = FirebaseAuth.instance.currentUser;
                    if(user != null){
                      await FirestoreService().getUserInfo(user!.uid).then((value) {
                        ref.read(firebaseControllerRiverpod).fetchUser(value!);
                      });
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage(mode: 0)),
                    );
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                        color: appColors.orange,
                        borderRadius: BorderRadius.all(Radius.circular(5))
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: appColors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


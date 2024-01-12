import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/pages/profileInfoPage/profile_info_page.dart';
import 'package:tedarikten/pages/sign_up_page.dart';

class HomeAppBar extends StatelessWidget implements  PreferredSizeWidget{

  Size get preferredSize => const Size.fromHeight(64);

  Widget build(BuildContext context){
    final appColors = AppColors();
    var size = MediaQuery.of(context).size;
    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, //horizantal
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10,right: 4),
            child: GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: appColors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(5))
                ),
                child: Icon(
                  Icons.menu_rounded,
                  color: appColors.white,
                  size: 32,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                    color: appColors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(5))
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 8,right: 4),
                        child: Column(
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
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.search_rounded,size: 26,color: appColors.white,),
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4,right: 4),
            child: GestureDetector(
              onTap: () {

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
          Padding(
            padding: const EdgeInsets.only(left: 4,right: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
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
        ],
      ),
    );
  }

}


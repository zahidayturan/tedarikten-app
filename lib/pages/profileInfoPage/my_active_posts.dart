
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tedarikten/constants/app_colors.dart';


class MyActivePosts extends ConsumerStatefulWidget {
  const MyActivePosts({Key? key}) : super(key: key);

  @override
  ConsumerState<MyActivePosts> createState() => _MyActivePostsState();
}

class _MyActivePostsState extends ConsumerState<MyActivePosts> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
  }

    Widget build(BuildContext context) {
      final appColors = AppColors();
      return user != null ? SizedBox() : Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: 'Aktif ilanlarınızı görmek için\n', style: TextStyle(fontFamily: "FontNormal",color: appColors.black,fontSize: 15)),
              TextSpan(text: 'giriş yapmalısınız',style: TextStyle(fontFamily: "FontBold",color: appColors.blueDark,fontSize: 15)),
            ],
          ),
        ),
      );
    }
}
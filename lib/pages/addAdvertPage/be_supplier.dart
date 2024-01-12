
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tedarikten/constants/app_colors.dart';


class BeSupplier extends ConsumerStatefulWidget {
  const BeSupplier({Key? key}) : super(key: key);

  @override
  ConsumerState<BeSupplier> createState() => _BeSupplierState();
}

class _BeSupplierState extends ConsumerState<BeSupplier> {

  @override
  void initState() {
    super.initState();
  }
  User? user = FirebaseAuth.instance.currentUser;
  Widget build(BuildContext context){
    final appColors = AppColors();
    return user != null ? Container(child: Center(child: Text("Tedarikçi ol")),)
    : Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(text: 'İlan oluşturmak için\n', style: TextStyle(fontFamily: "FontNormal",color: appColors.black,fontSize: 15)),
            TextSpan(text: 'giriş yapmalısınız',style: TextStyle(fontFamily: "FontBold",color: appColors.orange,fontSize: 15)),
          ],
        ),
      ),
    );
  }

}
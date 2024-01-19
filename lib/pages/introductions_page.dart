import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tedarikten/app/my_app.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/pages/login_page.dart';
import 'package:tedarikten/pages/sign_up_page.dart';

class IntroductionPage extends ConsumerStatefulWidget {
  const IntroductionPage({Key? key}) : super(key: key);

  @override
  ConsumerState<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends ConsumerState<IntroductionPage> {

  @override
  void initState() {
    super.initState();
  }
  final appColors = AppColors();
  Widget build(BuildContext context){
    return SafeArea(child: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 64,
              child: Image(
              image: AssetImage(
                  "assets/logo/icon.png")),
            ),
            getText("Hoş Geldiniz", "",32, appColors.blueDark ),
            Column(
              children: [
                getText("Bir hesabınız var ise\n", "giriş yapın",18, appColors.blackLight),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                    child: getButton(appColors.orange,"Giriş Yap",appColors.white)),
              ],
            ),
            Column(
              children: [
                getText("Henüz hesabınız yok ise\n", "kayıt olun",18, appColors.blackLight),
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    child: getButton(appColors.blueLight,"Kayıt  Ol",appColors.white)),
              ],
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: () async{
                      showQuesitonDialog();
                    /*final SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setBool("showApp", true);
                    final bool showApp = prefs.getBool("showApp") ?? false;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyAppBase(showApp: showApp)),
                    );*/
                  },
                    child: getText("Hesap olmadan ", "göz at",16, appColors.blue)),
              ],
            ),
            SizedBox(
              height: 32,
              child: Image(
                color: appColors.blueDark,
                  image: const AssetImage(
                      "assets/logo/logo_text.png")),
            ),
          ],
        ),
      ),


    ));
  }

  Widget getText(String textNormal, String textBold,double fontSize, Color color){
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Center(
        child:RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: textNormal, style: TextStyle(fontFamily: "FontNormal",fontSize: fontSize,color: color)),
              TextSpan(text: textBold,style: TextStyle(fontFamily: "FontBold",fontSize: fontSize,color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget getButton(Color buttonColor,String text, Color textColor){
    return Container(
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32,vertical: 8),
        child: Text(
          text, style: TextStyle(color: textColor,fontSize: 16),
        ),
      ),
    );
  }

  void showQuesitonDialog(){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          backgroundColor: appColors.blueDark,
          duration: const Duration(seconds: 3),
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          content: const Center(
            child: Text(
              "Henüz yapamazsınız",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'FontNormal',
                height: 1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)))
      ),
    );
  }


}
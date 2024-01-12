// Kayıt ekranındaki StatelessWidget sınıfı
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tedarikten/app/my_app.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/pages/login_page.dart';

class SignUpPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final appColors = AppColors();
    return SafeArea(
      child: Scaffold(
        backgroundColor: appColors.whiteDark,
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 32.0),
                pageTopController(context),
                SizedBox(height: 64.0),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text("Kayıt Ol",
                    style: TextStyle(
                        fontSize: 28,
                        color: appColors.blueDark,
                        height: 1),),
                ),
                getTextField(context, nameController, "Ad"),
                SizedBox(height: 16.0),
                getTextField(context, surnameController, "Soyad"),
                SizedBox(height: 16.0),
                getTextField(context, emailController, "E-posta"),
                SizedBox(height: 16.0),
                getTextField(context, passwordController, "Şifre"),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async{
                        await signUpWithEmailAndPassword();
                        final SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setBool("showApp", true);
                        final bool showApp = prefs.getBool("showApp") ?? false;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyAppBase(showApp: showApp)),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: appColors.blueDark,
                          borderRadius: BorderRadius.all(Radius.circular(4))
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0,horizontal: 16),
                          child: Text('Kayıt Ol',style: TextStyle(
                            color: appColors.white,
                            height: 1,
                            fontSize: 16
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 64.0),
                SizedBox(
                  width: size.width/2,
                  child: Image(
                    color: appColors.blueDark,
                      image: AssetImage(
                          "assets/logo/logo_text.png")),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget pageTopController(BuildContext context){
    final appColors = AppColors();
    var size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            width: 32,
            height: 32,
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
        SizedBox(
          width: size.width/6,
          child: Image(

              image: AssetImage(
                  "assets/logo/icon.png")),
        ),
        Container(
          width: 28,
          height: 28,
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: appColors.blueDark,
              shape: BoxShape.circle,

          ),
          child: Image(
            fit: BoxFit.fitHeight,
            color: appColors.white,
            image: AssetImage(
                "assets/icons/question.png"
            ),
          ),)
      ],
    );
  }

  Widget getTextField(BuildContext context,TextEditingController? controller,String text){
    final appColors = AppColors();
    return TextField(
      controller: controller,
      decoration: InputDecoration(
          labelText: text,
          labelStyle: TextStyle(color: appColors.blueDark),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide(
                  width: 1,
                  color: appColors.blueDark
              )),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide(
                  width: 1,
                  color: appColors.blueDark))),
    );

  }

  Future<void> signUpWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'id' : userCredential!.user!.uid,
        'name':  nameController.text,
        'surname': surnameController.text,
      });

    } catch (e) {
      print('Kayıt hatası: $e');
    }
  }

}

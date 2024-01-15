import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tedarikten/app/my_app.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/pages/sign_up_page.dart';
import 'package:tedarikten/utils/firestore_helper.dart';

import '../riverpod_management.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors();
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              height: size.height-120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 32.0),
                  pageTopController(context),
                  SizedBox(height: 96.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Text("Giriş Yap",
                      style: TextStyle(
                          fontSize: 28,
                          color: appColors.blueDark,
                          height: 1),),
                  ),
                  getTextField(context, emailController, "E-posta",_emailKey),
                  SizedBox(height: 16.0),
                  getTextField(context, passwordController, "Şifre",_passwordKey),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () async{
                          if (_emailKey.currentState!.validate()&& _passwordKey.currentState!.validate()) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: appColors.blueLight,
                                  ),
                                );
                              },
                              barrierDismissible: false, // Kullanıcının dışarı tıklamasını engeller
                            );
                            await signInWithEmailAndPassword(context,ref);
                            Navigator.pop(context);
                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                            final bool tempBool = prefs.getBool("showApp") ?? false;
                            await prefs.setBool("showApp", true);
                            final bool showApp = prefs.getBool("showApp") ?? false;
                            print(tempBool);
                            if (tempBool == false) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MyAppBase(showApp: showApp)),
                              );
                            } else {
                              Navigator.pop(context);
                            }
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: appColors.blueDark,
                                    elevation: 0,
                                    content: Center(
                                      child: Text(
                                        "Eksik bilgi verdiniz",
                                        style: const TextStyle(fontSize: 16, height: 1),
                                      ),
                                    )));
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: appColors.blueDark,
                              borderRadius: BorderRadius.all(Radius.circular(4))
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0,horizontal: 16),
                            child: Text('Giriş Yap',style: TextStyle(
                                color: appColors.white,
                                height: 1,
                                fontSize: 16
                            )),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
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

  String? emailValidate(String? value) {
    if (value!.isEmpty) {
      return 'E-posta boş bırakılamaz';
    }
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null;
  }

  String? passwordValidate(String? value) {
    if (value!.isEmpty) {
      return 'Şifre boş bırakılamaz';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }
    return null;
  }

  Widget getTextField(BuildContext context,TextEditingController? controller,String text,Key key){
    final appColors = AppColors();
    return Form(
      key: key,
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if(text == "E-posta"){
            return emailValidate(value);
          } else{
            return passwordValidate(value);
          }
        },
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
      ),
    );

  }

  Future<void> signInWithEmailAndPassword(BuildContext context,WidgetRef ref) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      User? user = FirebaseAuth.instance.currentUser;

      await FirestoreService().getUserInfo(user!.uid).then((value) {
        ref.read(firebaseControllerRiverpod).fetchUser(value!);
      });

    } catch (e) {
      print('Giriş hatası: $e');
      showLoginErrorDialog(context, e.toString());
    }
  }

  void showLoginErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Giriş Hatası'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

}

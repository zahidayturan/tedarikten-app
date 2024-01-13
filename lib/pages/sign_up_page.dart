// Kayıt ekranındaki StatelessWidget sınıfı
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tedarikten/app/my_app.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/models/user_info.dart';
import 'package:tedarikten/pages/login_page.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}


class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _emailKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormState>();
  final _surnameKey = GlobalKey<FormState>();
  final _cityKey = GlobalKey<FormState>();
  final _countryKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
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
                getTextField(context, nameController, "Ad",_nameKey),
                SizedBox(height: 16.0),
                getTextField(context, surnameController, "Soyad",_surnameKey),
                SizedBox(height: 16.0),
                getTextField(context, emailController, "E-posta",_emailKey),
                SizedBox(height: 16.0),
                getTextField(context, cityController, "Şehir",_cityKey),
                SizedBox(height: 16.0),
                getTextField(context, countryController, "Ülke",_countryKey),
                SizedBox(height: 16.0),
                getTextField(context, passwordController, "Şifre",_passwordKey),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async{
                        if (_nameKey.currentState!.validate()
                            && _surnameKey.currentState!.validate()
                            && _emailKey.currentState!.validate()
                            && _cityKey.currentState!.validate()
                            && _countryKey.currentState!.validate()
                            && _passwordKey.currentState!.validate()
                        ) {
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
                          await signUpWithEmailAndPassword();
                          final SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setBool("showApp", true);
                          final bool showApp = prefs.getBool("showApp") ?? false;
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MyAppBase(showApp: showApp)),
                          );
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

  String? nameValidate(String? value) {
    if (value!.isEmpty) {
      return 'Ad boş bırakılamaz';
    }
    if (value.length < 2) {
      return 'Ad en az 2 karakter olmalıdır';
    }
    return null;
  }

  String? surnameValidate(String? value) {
    if (value!.isEmpty) {
      return 'Soyad boş bırakılamaz';
    }
    if (value.length < 2) {
      return 'Soyad en az 2 karakter olmalıdır';
    }
    return null;
  }

  String? cityValidate(String? value) {
    if (value!.isEmpty) {
      return 'Şehir boş bırakılamaz';
    }
    if (value.length < 3) {
      return 'Şehir en az 3 karakter olmalıdır';
    }
    return null;
  }

  String? countryValidate(String? value) {
    if (value!.isEmpty) {
      return 'Ülke boş bırakılamaz';
    }
    if (value.length < 2) {
      return 'Ülke en az 2 karakter olmalıdır';
    }else{
      return null;
    }
  }


  Widget getTextField(BuildContext context,TextEditingController controller,String text,Key key){
    final appColors = AppColors();
    return Form(
      key: key,
      child: TextFormField(
        controller: controller,
        //autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if(text == "E-posta"){
            return emailValidate(value);
          } else if(text == "Ad"){
            return nameValidate(value);
          }else if(text == "Soyad"){
            return surnameValidate(value);
          }else if(text == "Şehir"){
            return cityValidate(value);
          }else if(text == "Ülke"){
            return countryValidate(value);
          }else{
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
                    color: appColors.blueDark)),
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
                width: 1,
                color: appColors.blueDark)
        )),
      ),
    );

  }

  Future<void> signUpWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      await addTUserInfoToFirestore(userCredential.user!.uid, TUserInfo(id: userCredential.user!.uid, name: nameController.text, surname: surnameController.text, email: emailController.text, city: cityController.text, country: countryController.text,advertList: [],companyList: [],followerList: [],followList: []));
    } catch (e) {
      print('Kayıt hatası: $e');
    }
  }


  Future<void> addTUserInfoToFirestore(String uid, TUserInfo user) async {
    try {
      Map<String, dynamic> supplyData = user.toJson();
      await FirebaseFirestore.instance.collection('users').add(supplyData);
    } catch (e) {
      print('Kayıt hatası: $e');
    }
  }

}

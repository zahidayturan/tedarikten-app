import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/models/combined_info.dart';
import 'package:tedarikten/models/user_info.dart';
import 'package:tedarikten/riverpod_management.dart';
import 'package:tedarikten/utils/firestore_helper.dart';

class SupplyDetailsPage extends ConsumerStatefulWidget {
  const SupplyDetailsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SupplyDetailsPage> createState() => _SupplyDetailsPageState();
}

class _SupplyDetailsPageState extends ConsumerState<SupplyDetailsPage> {
  User? user = FirebaseAuth.instance.currentUser;
  late CombinedInfo userData;
  final appColors = AppColors();

  @override
  void initState() {
    super.initState();
    if (user != null) {
      userData = ref.read(profilePageRiverpod).combinedInfo;

    }
  }

  Widget build(BuildContext context){
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            topWidget(),
            Expanded(
              child: SizedBox(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                      child: details())),
            ),
            controlButtons()
          ],
        ),
      ),
    );
  }
  Widget controlButtons(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          getPanelButton("Kaydet",15,"FontBold",appColors.blue,appColors.white),
          GestureDetector(
            onTap: () async{
                try {
                  User? user = FirebaseAuth.instance.currentUser;
                  TUserInfo?  userCurrent = await FirestoreService().getUserInfo(user!.uid);

                  QuerySnapshot userQuery = await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: userCurrent!.id).get();
                  if (userQuery.docs.isNotEmpty) {
                    DocumentSnapshot userDoc = userQuery.docs.first;
                    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userDoc.id);
                    await userRef.update({
                      'advertList': FieldValue.arrayUnion([userData.supplyInfo.id]),
                    });
                  } else {
                    print('Kullanıcı bulunamadı');
                  }

                } catch (e) {
                  print('Hata oluştu: $e');
                }
                try {
                  await FirebaseFirestore.instance.collection('supplies').doc(userData.supplyInfo.id).update({
                    'sharersIdList': FieldValue.arrayUnion([user!.uid]),
                  });
                } catch (e) {
                  print('Hata oluştu: $e');
                }
            },
              child: getPanelButton("Paylaş",15,"FontBold",appColors.blue,appColors.white)),
          SizedBox(),
          getPanelButton("BAŞVUR",18,"FontBold",appColors.orange,appColors.white),
        ],
      ),
    );
  }

  Widget details(){
    CombinedInfo data = ref.read(profilePageRiverpod).combinedInfo;
    DateTime dateFirstFormat = DateTime.parse(data.supplyInfo.dateFirst);
    String dateFirst = DateFormat('dd.MM.yyyy HH:mm').format(dateFirstFormat);
    DateTime dateLastFormat = DateTime.parse(data.supplyInfo.dateLast);
    String dateLast = DateFormat('dd.MM.yyyy HH:mm').format(dateLastFormat);

    bool checkCompany = data.companyInfo.name != "";
    return Padding(
      padding: const EdgeInsets.only(left: 10,right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: getText("İlan Bilgileri", 18, appColors.orange, "FontBold", TextAlign.start),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8,bottom: 4),
            child: getText("Tedarik Türü", 16, appColors.black, "FontBold", TextAlign.start),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16,bottom: 6),
            child: getText(data.supplyInfo.type, 15, appColors.black, "FontNormal", TextAlign.start),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8,bottom: 4),
            child: getText("Tedarik Açıklaması", 16, appColors.black, "FontBold", TextAlign.start),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16,bottom: 6),
            child: getText(data.supplyInfo.description != "" ? data.supplyInfo.description: "Açıklama bilgisi eklenmemiş", 15, appColors.black, "FontNormal", TextAlign.start),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8,bottom: 4),
                    child: getText("Miktarı", 16, appColors.black, "FontBold", TextAlign.start),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16,bottom: 6),
                    child: getText(data.supplyInfo.amount.toString() != "" ? data.supplyInfo.amount.toString() : "Miktar belirtilmemiş", 15, appColors.black, "FontNormal", TextAlign.start),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8,bottom: 4),
                    child: getText("Teslim Süresi", 16, appColors.black, "FontBold", TextAlign.start),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16,bottom: 6),
                    child: getText(data.supplyInfo.minTime.toString() != "" ? "${data.supplyInfo.minTime} Gün".toString() : "Süre belirtilmemiş", 15, appColors.black, "FontNormal", TextAlign.start),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8,bottom: 4),
                    child: getText("İlan Tarihi", 16, appColors.black, "FontBold", TextAlign.start),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16,bottom: 6),
                    child: getText(dateFirst, 15, appColors.black, "FontNormal", TextAlign.start),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8,bottom: 4),
                    child: getText("İlan Son Tarihi", 16, appColors.black, "FontBold", TextAlign.start),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16,bottom: 6),
                    child: getText(dateLast, 15, appColors.black, "FontNormal", TextAlign.start),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8,bottom: 4),
            child: getText("Konumu", 16, appColors.black, "FontBold", TextAlign.start),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16,bottom: 6),
            child: getText(data.supplyInfo.location != "" ? "${data.supplyInfo.location} / Türkiye" : "Konum belirtilmemiş", 15, appColors.black, "FontNormal", TextAlign.start),
          ),
          Visibility(
            visible: checkCompany,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12,top: 12),
                  child: getText("Firma Bilgileri", 18, appColors.orange, "FontBold", TextAlign.start),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8,bottom: 4),
                  child: getText("Adı", 16, appColors.black, "FontBold", TextAlign.start),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16,bottom: 6),
                  child: getText(data.companyInfo.name, 15, appColors.black, "FontNormal", TextAlign.start),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8,bottom: 4),
                          child: getText("Şehir", 16, appColors.black, "FontBold", TextAlign.start),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16,bottom: 6),
                          child: getText(data.companyInfo.location, 15, appColors.black, "FontNormal", TextAlign.start),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8,bottom: 4),
                          child: getText("Kuruluş Yılı", 16, appColors.black, "FontBold", TextAlign.start),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16,bottom: 6),
                          child: getText(data.companyInfo.year.toString() != "" ? data.companyInfo.year.toString() : "Bilinmiyor", 15, appColors.black, "FontNormal", TextAlign.start),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8,bottom: 4),
                  child: getText("İletişim Numarası", 16, appColors.black, "FontBold", TextAlign.start),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16,bottom: 6),
                  child: getText(data.companyInfo.phone, 15, appColors.black, "FontNormal", TextAlign.start),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8,bottom: 4),
                  child: getText("Adresi", 16, appColors.black, "FontBold", TextAlign.start),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16,bottom: 6),
                  child: getText(data.companyInfo.address != "" ? data.companyInfo.address : "Adres bilgisi bulunamadı" , 15, appColors.black, "FontNormal", TextAlign.start),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8,bottom: 4),
                  child: getText("Firma Yetkilisi", 16, appColors.black, "FontBold", TextAlign.start),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16,bottom: 4),
                  child: getText(data.companyInfo.personNameSurname, 15, appColors.black, "FontNormal", TextAlign.start),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16,bottom: 6),
                  child: getText(data.companyInfo.personEmail, 15, appColors.black, "FontNormal", TextAlign.start),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8,top: 12),
            child: getText("Ek Dosyalar", 18, appColors.orange, "FontBold", TextAlign.start),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16,bottom: 6),
            child: getText("Ek dosya eklenmemiş", 15, appColors.black, "FontNormal", TextAlign.start),
          ),


        ],
      ),
    );
  }

  Widget topWidget(){
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                pageTopController(),
                userInfo(),
                buttons(),
               ],
            ),
          ),

        ],
      ),);
  }

  Widget pageTopController(){
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
          child: Text("İlan Detayları",style: TextStyle(color: appColors.white,fontSize: 18,fontFamily: "FontNormal"),),
        ),
        Spacer(),
        Container(height: 16,width: 36,
          padding: EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
              color: appColors.blueDark,
              borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: Image(color:appColors.white,fit: BoxFit.fitWidth,image: AssetImage("assets/icons/dots.png")),)
      ],
    );
  }

  Widget userInfo(){
      return Padding(
        padding: const EdgeInsets.only(top: 16,bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: 80,
                child: getText("İlan\nSahibi", 18, appColors.white, "fontBold",TextAlign.start)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                      color: appColors.white,
                      shape: BoxShape.circle
                  ),
                ),
                SizedBox(height: 8,),
                getText("${userData.userInfo.name} ${userData.userInfo.surname}", 16, appColors.white, "fontBold",TextAlign.center),
                SizedBox(height: 8,),
                getText("Tedarikçi", 15, appColors.white, "fontNormal",TextAlign.center),
              ],
            ),
            SizedBox(
                width: 80,
                child: getText("${userData.userInfo.city}\n${userData.userInfo.country}", 15, appColors.white, "fontNormal",TextAlign.end)),
          ],
        ),
      );
  }

  Widget buttons(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
     children: [
       getPanelButton("Profile Git",14,"FontNormal",appColors.blueDark,appColors.white),
       //getPanelButton("Mesaj Gönder")
     ],
    );
  }

  Widget getText(String text,double fontSize, Color color, String fontFamily, TextAlign align){
    return Text(
      text,style: TextStyle(
      color: color,
      fontSize: fontSize,
      height: 1,
      fontFamily: fontFamily
    ),
      textAlign: align,
    );
  }

  Widget getPanelButton(String text,double fontSize,String fontFamily,Color buttonColor,Color textColor){
    return Container(
      //width: 110,
      decoration:BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.all(Radius.circular(5))
      ),child: Center(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(text,style: TextStyle(color: textColor,fontSize: fontSize,fontFamily: fontFamily),),
    )),);
  }



}
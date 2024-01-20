import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/models/application_supply_info.dart';
import 'package:tedarikten/models/combined_info.dart';
import 'package:tedarikten/models/supply_info.dart';
import 'package:tedarikten/pages/profileInfoPage/profile_info_page.dart';
import 'package:tedarikten/riverpod_management.dart';
import 'package:tedarikten/utils/firestore_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class SupplyDetailsPage extends ConsumerStatefulWidget {
  late int mode;
  /*
  Mode 0 ise başkasının ilanı
  Mode 1 ise kendi ilanın
  Mode 2 ise ilana başvuran kişi
   */
  SupplyDetailsPage({Key? key,required this.mode}) : super(key: key,);

  @override
  ConsumerState<SupplyDetailsPage> createState() => _SupplyDetailsPageState();
}

class _SupplyDetailsPageState extends ConsumerState<SupplyDetailsPage> {
  User? user = FirebaseAuth.instance.currentUser;
  late CombinedInfo userData;
  PageController _pageControllerForDialog = PageController(initialPage: 0);
  final appColors = AppColors();
  @override
  void initState() {
    super.initState();
    if (user != null) {
      userData = ref.read(profilePageRiverpod).combinedInfo;

    }
  }

  Widget build(BuildContext context){
    var read = ref.read(profilePageRiverpod);
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
                      child: read.editingMode == false ? details() : editingMode())),
            ),
            widget.mode == 0 ? controlButtons() : read.editingMode == true ? editingModeButtons() : SizedBox()
          ],
        ),
      ),
    );
  }
  Widget controlButtons(){
    var read = ref.read(profilePageRiverpod);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
              onTap: () async{
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Center(
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                            color: appColors.whiteDark,
                            borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                        child: PageView(
                          controller: _pageControllerForDialog,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.bookmark_add_rounded,color: appColors.blueDark,size: 64,),
                                Text("Bu ilanı\nkaydetmek\nistiyor musunuz? \nSadece siz göreceksiniz",style: TextStyle(
                                    color: appColors.black,
                                    fontSize: 15,
                                    height: 1,
                                    fontFamily: "FontNormal",
                                    decoration: TextDecoration.none
                                ),textAlign: TextAlign.center,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: appColors.blueDark,
                                            borderRadius: BorderRadius.all(Radius.circular(5))
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                          child: Text("Geri dön",style: TextStyle(
                                              color: appColors.white,
                                              fontSize: 14,
                                              fontFamily: "FontNormal",
                                              decoration: TextDecoration.none
                                          ),),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async{
                                        _pageControllerForDialog.nextPage(duration: Duration(milliseconds: 300), curve: Curves.bounceInOut);

                                        String status = await FirestoreService().advertSave(userData.supplyInfo);
                                        if(status == "Ok"){
                                          _pageControllerForDialog.nextPage(duration: Duration(milliseconds: 300), curve: Curves.bounceInOut);
                                        }else{
                                          _pageControllerForDialog.jumpToPage(3);
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: appColors.blueDark,
                                            borderRadius: BorderRadius.all(Radius.circular(5))
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                          child: Text("Evet",style: TextStyle(
                                              color: appColors.white,
                                              fontSize: 14,
                                              fontFamily: "FontNormal",
                                              decoration: TextDecoration.none
                                          ),),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Center(
                              child: CircularProgressIndicator(
                                color: appColors.blueLight,
                              ),),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline_rounded,color: appColors.orange,size: 64,),
                                Text("İlan\nkaydedildi",style: TextStyle(
                                    color: appColors.blackLight,
                                    fontSize: 16,
                                    height: 1,
                                    fontFamily: "FontNormal",
                                    decoration: TextDecoration.none
                                ),textAlign: TextAlign.center,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: appColors.orange,
                                        borderRadius: BorderRadius.all(Radius.circular(5))
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                      child: Text("Tamam",style: TextStyle(
                                          color: appColors.white,
                                          fontSize: 14,
                                          fontFamily: "FontNormal",
                                          decoration: TextDecoration.none
                                      ),),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline_rounded,color: appColors.pink,size: 64,),
                                Text("Bir hata\nmeydana geldi",style: TextStyle(
                                    color: appColors.blackLight,
                                    fontSize: 16,
                                    height: 1,
                                    fontFamily: "FontNormal",
                                    decoration: TextDecoration.none
                                ),textAlign: TextAlign.center,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: appColors.blackLight,
                                        borderRadius: BorderRadius.all(Radius.circular(5))
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                      child: Text("Tamam",style: TextStyle(
                                          color: appColors.white,
                                          fontSize: 14,
                                          fontFamily: "FontNormal",
                                          decoration: TextDecoration.none
                                      ),),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  barrierDismissible: false,
                );
              },
              child: getPanelButton("Kaydet",15,"FontBold",appColors.blue,appColors.white)),
          GestureDetector(
            onTap: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                          color: appColors.whiteDark,
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: PageView(
                        controller: _pageControllerForDialog,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.share_rounded,color: appColors.blueDark,size: 64,),
                              Text("Bu ilan\nsayfanızda\npaylaşılsın mı?",style: TextStyle(
                                  color: appColors.black,
                                  fontSize: 16,
                                  height: 1,
                                  fontFamily: "FontNormal",
                                  decoration: TextDecoration.none
                              ),textAlign: TextAlign.center,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: appColors.blueDark,
                                          borderRadius: BorderRadius.all(Radius.circular(5))
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                        child: Text("Geri dön",style: TextStyle(
                                            color: appColors.white,
                                            fontSize: 14,
                                            fontFamily: "FontNormal",
                                            decoration: TextDecoration.none
                                        ),),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async{
                                      _pageControllerForDialog.nextPage(duration: Duration(milliseconds: 300), curve: Curves.bounceInOut);

                                      String status = await FirestoreService().advertShare(userData.supplyInfo);
                                      if(status == "Ok"){
                                        _pageControllerForDialog.nextPage(duration: Duration(milliseconds: 300), curve: Curves.bounceInOut);
                                      }else{
                                        _pageControllerForDialog.jumpToPage(3);
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: appColors.blueDark,
                                          borderRadius: BorderRadius.all(Radius.circular(5))
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                        child: Text("Evet",style: TextStyle(
                                            color: appColors.white,
                                            fontSize: 14,
                                            fontFamily: "FontNormal",
                                            decoration: TextDecoration.none
                                        ),),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Center(
                            child: CircularProgressIndicator(
                              color: appColors.blueLight,
                            ),),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline_rounded,color: appColors.orange,size: 64,),
                              Text("İlan\nsayfanızda\npaylaşıldı",style: TextStyle(
                                  color: appColors.blackLight,
                                  fontSize: 16,
                                  height: 1,
                                  fontFamily: "FontNormal",
                                  decoration: TextDecoration.none
                              ),textAlign: TextAlign.center,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: appColors.orange,
                                      borderRadius: BorderRadius.all(Radius.circular(5))
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                    child: Text("Tamam",style: TextStyle(
                                        color: appColors.white,
                                        fontSize: 14,
                                        fontFamily: "FontNormal",
                                        decoration: TextDecoration.none
                                    ),),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline_rounded,color: appColors.pink,size: 64,),
                              Text("Bir hata\nmeydana geldi",style: TextStyle(
                                  color: appColors.blackLight,
                                  fontSize: 16,
                                  height: 1,
                                  fontFamily: "FontNormal",
                                  decoration: TextDecoration.none
                              ),textAlign: TextAlign.center,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: appColors.blackLight,
                                      borderRadius: BorderRadius.all(Radius.circular(5))
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                    child: Text("Tamam",style: TextStyle(
                                        color: appColors.white,
                                        fontSize: 14,
                                        fontFamily: "FontNormal",
                                        decoration: TextDecoration.none
                                    ),),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                barrierDismissible: false,
              );
            },
              child: getPanelButton("Paylaş",15,"FontBold",appColors.blue,appColors.white)),
          SizedBox(),
          GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Center(
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                            color: appColors.whiteDark,
                            borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                        child: PageView(
                          controller: _pageControllerForDialog,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.add_rounded,color: appColors.blueDark,size: 64,),
                                Text("Bu ilana\nbaşvuru\nyapılsın mı?",style: TextStyle(
                                    color: appColors.black,
                                    fontSize: 16,
                                    height: 1,
                                    fontFamily: "FontNormal",
                                    decoration: TextDecoration.none
                                ),textAlign: TextAlign.center,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: appColors.blueDark,
                                            borderRadius: BorderRadius.all(Radius.circular(5))
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                          child: Text("Geri dön",style: TextStyle(
                                              color: appColors.white,
                                              fontSize: 14,
                                              fontFamily: "FontNormal",
                                              decoration: TextDecoration.none
                                          ),),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async{
                                        _pageControllerForDialog.nextPage(duration: Duration(milliseconds: 300), curve: Curves.bounceInOut);

                                        String status = await FirestoreService().advertApply(ApplicationSupplyInfo(applicantUserId: user!.uid, supplyId: userData.supplyInfo.id!, message: "title", date: DateTime.now().toString(), response: "Yanıt Bekleniyor"));
                                        if(status == "Ok"){
                                          _pageControllerForDialog.nextPage(duration: Duration(milliseconds: 300), curve: Curves.bounceInOut);
                                        }else{
                                          _pageControllerForDialog.jumpToPage(3);
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: appColors.blueDark,
                                            borderRadius: BorderRadius.all(Radius.circular(5))
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                          child: Text("Evet",style: TextStyle(
                                              color: appColors.white,
                                              fontSize: 14,
                                              fontFamily: "FontNormal",
                                              decoration: TextDecoration.none
                                          ),),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Center(
                              child: CircularProgressIndicator(
                                color: appColors.blueLight,
                              ),),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline_rounded,color: appColors.orange,size: 64,),
                                Text("Başvuru yapıldı.\nİlan sahibine\niletişim bilgileriniz\ngönderildi",style: TextStyle(
                                    color: appColors.blackLight,
                                    fontSize: 16,
                                    height: 1,
                                    fontFamily: "FontNormal",
                                    decoration: TextDecoration.none
                                ),textAlign: TextAlign.center,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: appColors.orange,
                                        borderRadius: BorderRadius.all(Radius.circular(5))
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                      child: Text("Tamam",style: TextStyle(
                                          color: appColors.white,
                                          fontSize: 14,
                                          fontFamily: "FontNormal",
                                          decoration: TextDecoration.none
                                      ),),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline_rounded,color: appColors.pink,size: 64,),
                                Text("Bir hata\nmeydana geldi",style: TextStyle(
                                    color: appColors.blackLight,
                                    fontSize: 16,
                                    height: 1,
                                    fontFamily: "FontNormal",
                                    decoration: TextDecoration.none
                                ),textAlign: TextAlign.center,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: appColors.blackLight,
                                        borderRadius: BorderRadius.all(Radius.circular(5))
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                      child: Text("Tamam",style: TextStyle(
                                          color: appColors.white,
                                          fontSize: 14,
                                          fontFamily: "FontNormal",
                                          decoration: TextDecoration.none
                                      ),),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  barrierDismissible: false,
                );
              },
              child: getPanelButton("BAŞVUR",18,"FontBold",appColors.orange,appColors.white)),
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
            child: getText("Tedarik Adı", 16, appColors.black, "FontBold", TextAlign.start),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16,bottom: 6),
            child: getText(data.supplyInfo.name, 15, appColors.black, "FontNormal", TextAlign.start),
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
          GestureDetector(
            onTap: () async{
              if(data.supplyInfo.documentId != "0"){
                String url = await FirestoreService().openFileUrl(data.supplyInfo.documentId);
                void launchURL() async {
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'URL açılamadı: $url';
                  }
                }
              }

            },
            child: Padding(
              padding: const EdgeInsets.only(left: 16,bottom: 6),
              child: getText(data.supplyInfo.documentId != "0" ? data.supplyInfo.documentId :"Ek dosya eklenmemiş", 15,data.supplyInfo.documentId != "0" ? appColors.blue : appColors.black, "FontNormal", TextAlign.start),
            ),
          ),


        ],
      ),
    );
  }

  Widget editingMode(){
    var read = ref.read(profilePageRiverpod);
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
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: appColors.greenLight,
              borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            child: Center(
              child: getText("Düzenlemek istediğiniz bilginin\nüstüne dokunun", 16, appColors.blackLight, "FontNormal", TextAlign.center),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: getText("İlan Bilgileri", 18, appColors.orange, "FontBold", TextAlign.start),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () async{
                  String? newValue = await _showNameInputDialogForDropDown(context,"Tedarik Türü",data.supplyInfo.type,typeSupplyList);
                  setState(() {
                    read.setType(newValue!);
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8,bottom: 4),
                      child: getText("Tedarik Türü", 16, appColors.black, "FontBold", TextAlign.start),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16,bottom: 6),
                      child: getText(read.type ?? data.supplyInfo.type, 15, appColors.black, "FontNormal", TextAlign.start),
                    ),
                  ],
                ),
              ),
              Visibility(
                  visible: read.type != null,
                  child: getText("Düzenlendi", 14, appColors.blueDark, "FontNormal", TextAlign.end))
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () async{
                  String? newValue = await _showNameInputDialogForTextField(context,"Tedarik Adı",data.supplyInfo.name,108);
                  setState(() {
                    read.setName(newValue!);
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8,bottom: 4),
                      child: getText("Tedarik Adı", 16, appColors.black, "FontBold", TextAlign.start),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16,bottom: 6),
                      child: getText(data.supplyInfo.name, 15, appColors.black, "FontNormal", TextAlign.start),
                    ),
                  ],
                ),
              ),
              Visibility(
                  visible: read.name != null,
                  child: getText("Düzenlendi", 14, appColors.blueDark, "FontNormal", TextAlign.end))

            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () async{
                  String? newValue = await _showNameInputDialogForTextField(context,"Tedarik Açıklaması",data.supplyInfo.description,256);
                  setState(() {
                    read.setDescription(newValue!);
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8,bottom: 4),
                      child: getText("Tedarik Açıklaması", 16, appColors.black, "FontBold", TextAlign.start),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16,bottom: 6),
                      child: getText(read.description ?? (data.supplyInfo.description != "" ? data.supplyInfo.description: "Açıklama bilgisi eklenmemiş"), 15, appColors.black, "FontNormal", TextAlign.start),
                    ),
                  ],
                ),
              ),
              Visibility(
                  visible: read.description != null,
                  child: getText("Düzenlendi", 14, appColors.blueDark, "FontNormal", TextAlign.end))
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8,bottom: 4),
                    child: getText("Teslim Süresi", 16, appColors.black, "FontBold", TextAlign.start),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16,bottom: 6),
                    child: getText(data.supplyInfo.minTime.toString() != "" ? "${data.supplyInfo.minTime} Gün".toString() : "Süre belirtilmemiş", 15, appColors.black, "FontNormal", TextAlign.start),
                  ),
                ],
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8,bottom: 4),
                    child: getText("İlan Son Tarihi", 16, appColors.black, "FontBold", TextAlign.start),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16,bottom: 6),
                    child: getText(dateLast, 15, appColors.black, "FontNormal", TextAlign.start),
                  ),
                ],
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8,bottom: 4),
                    child: getText("Konumu", 16, appColors.black, "FontBold", TextAlign.start),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16,bottom: 6),
                    child: getText(data.supplyInfo.location != "" ? "${data.supplyInfo.location} / Türkiye" : "Konum belirtilmemiş", 15, appColors.black, "FontNormal", TextAlign.start),
                  ),
                ],
              ),
            ],
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
            child: getText(data.supplyInfo.documentId != "0" ? "${data.supplyInfo.documentId}" :"Ek dosya eklenmemiş", 15, appColors.black, "FontNormal", TextAlign.start),
          ),


        ],
      ),
    );
  }

  Widget editingModeButtons(){
    var read = ref.read(profilePageRiverpod);
    CombinedInfo data = ref.read(profilePageRiverpod).combinedInfo;
    return Visibility(
      visible: read.name != null || read.type != null || read.description != null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
                onTap: () {
                  ref.read(profilePageRiverpod).clear();
                  setState(() {

                  });
                },
                child: getPanelButton("Geri Al",16,"FontNormal",appColors.blue,appColors.white)),
            GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Center(
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                              color: appColors.whiteDark,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child: PageView(
                            controller: _pageControllerForDialog,
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.save_alt_rounded,color: appColors.blueDark,size: 64,),
                                  Text("Değişiklikler\nkaydedilsin mi?",style: TextStyle(
                                      color: appColors.black,
                                      fontSize: 16,
                                      height: 1,
                                      fontFamily: "FontNormal",
                                      decoration: TextDecoration.none
                                  ),textAlign: TextAlign.center,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: appColors.blueDark,
                                              borderRadius: BorderRadius.all(Radius.circular(5))
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                            child: Text("Geri dön",style: TextStyle(
                                                color: appColors.white,
                                                fontSize: 14,
                                                fontFamily: "FontNormal",
                                                decoration: TextDecoration.none
                                            ),),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async{
                                          _pageControllerForDialog.nextPage(duration: Duration(milliseconds: 300), curve: Curves.bounceInOut);
                                          String newDescription = data.supplyInfo.description;
                                          if(read.description != null){
                                          newDescription = read.description!;
                                          }
                                          String newType = data.supplyInfo.type;
                                          if(read.type != null){
                                            newType = read.description!;
                                          }
                                          String newName = data.supplyInfo.name;
                                          if(read.name != null){
                                            newName = read.name!;
                                          }

                                          SupplyInfo newData = SupplyInfo(
                                              id: data.supplyInfo.id,
                                              type: newType,
                                              name: newName,
                                              description: newDescription,
                                              dateFirst: data.supplyInfo.dateFirst,
                                              dateLast: data.supplyInfo.dateLast,
                                              amount: data.supplyInfo.amount,
                                              minTime: data.supplyInfo.minTime,
                                              location: data.supplyInfo.location,
                                              status: data.supplyInfo.status,
                                              sharingDate: data.supplyInfo.sharingDate,
                                              editingDate: DateTime.now().toString(),
                                              companyId: data.supplyInfo.companyId,
                                              documentId: data.supplyInfo.documentId,
                                              sharersIdList: data.supplyInfo.sharersIdList,
                                              registrantsIdList: data.supplyInfo.registrantsIdList,
                                              applicantsIdList: data.supplyInfo.applicantsIdList,
                                              userId: data.supplyInfo.userId);
                                          String status = await FirestoreService().updateSupply(newData);
                                          if(status == "Ok"){
                                            _pageControllerForDialog.nextPage(duration: Duration(milliseconds: 300), curve: Curves.bounceInOut);
                                            read.setSupplyDetailsId(CombinedInfo(supplyInfo: newData, companyInfo: data.companyInfo, userInfo: data.userInfo));
                                          }else{
                                            _pageControllerForDialog.jumpToPage(3);
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: appColors.blueDark,
                                              borderRadius: BorderRadius.all(Radius.circular(5))
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                            child: Text("Evet",style: TextStyle(
                                                color: appColors.white,
                                                fontSize: 14,
                                                fontFamily: "FontNormal",
                                                decoration: TextDecoration.none
                                            ),),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Center(
                                child: CircularProgressIndicator(
                                  color: appColors.blueLight,
                                ),),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline_rounded,color: appColors.orange,size: 64,),
                                  Text("Değişiklikler\nkaydedildi",style: TextStyle(
                                      color: appColors.blackLight,
                                      fontSize: 16,
                                      height: 1,
                                      fontFamily: "FontNormal",
                                      decoration: TextDecoration.none
                                  ),textAlign: TextAlign.center,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      read.setEditingMode(false);
                                      read.clear();
                                      setState(() {

                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: appColors.orange,
                                          borderRadius: BorderRadius.all(Radius.circular(5))
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                        child: Text("Tamam",style: TextStyle(
                                            color: appColors.white,
                                            fontSize: 14,
                                            fontFamily: "FontNormal",
                                            decoration: TextDecoration.none
                                        ),),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline_rounded,color: appColors.pink,size: 64,),
                                  Text("Bir hata\nmeydana geldi",style: TextStyle(
                                      color: appColors.blackLight,
                                      fontSize: 16,
                                      height: 1,
                                      fontFamily: "FontNormal",
                                      decoration: TextDecoration.none
                                  ),textAlign: TextAlign.center,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: appColors.blackLight,
                                          borderRadius: BorderRadius.all(Radius.circular(5))
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                        child: Text("Tamam",style: TextStyle(
                                            color: appColors.white,
                                            fontSize: 14,
                                            fontFamily: "FontNormal",
                                            decoration: TextDecoration.none
                                        ),),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    barrierDismissible: false,
                  );
                },
                child: getPanelButton("Düzenlemeyi Kaydet",17,"FontNormal",appColors.blueDark,appColors.white)),
          ],
        ),
      ),
    );
  }

  Widget getEditContainer(Color color){
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle
      ),
      child: Icon(Icons.edit_rounded,color: appColors.white,size: 22,),
    );
  }

  Future<String?> _showNameInputDialogForTextField(BuildContext context, String title, String defaultValue, int maxLength) async {
    String? result;

    TextInputType? keyboardType(){
      if(title == "Miktarı"){
        return TextInputType.number;
      }else{
        return TextInputType.name;
      }
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _controller = TextEditingController(text: defaultValue);

        return AlertDialog(
          backgroundColor: appColors.whiteDark,
          title: Text(title),
          content: TextField(
            controller: _controller,
            keyboardType: keyboardType(),
            maxLength: maxLength,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                result = _controller.text;
                Navigator.of(context).pop();
              },
              child: Text('Tamam'),
            ),
          ],
        );
      },
    );

    return result;
  }

  Future<String?> _showNameInputDialogForDropDown(BuildContext context, String title, String defaultValue,List<String> list) async {
    String? result;
    TextEditingController _controller = TextEditingController(text: defaultValue);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: appColors.whiteDark,
          title: Text(title),
          content: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _controller.text,
              padding: EdgeInsets.zero,
              dropdownColor: appColors.whiteDark,
              iconEnabledColor: appColors.blackLight,
              isDense: true,
              hint: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(_controller.text,style: TextStyle(
                      color: appColors.blackLight
                  ),),
                ),
              ),
              icon: Icon(Icons.keyboard_arrow_down_rounded,size: 22),
              borderRadius: BorderRadius.all(Radius.circular(5)),
              menuMaxHeight: 180,
              // alignment: AlignmentDirectional(0,0),
              items: list.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8,right: 0),
                    child: Text(value,style: TextStyle(color: appColors.blackLight,fontSize: 14,height: 1)),
                  ),
                );
              }).toList(),
              onChanged: (value) {

                setState(() {
                  _controller.text = value!;
                });

                result = _controller.text;
                Navigator.of(context).pop();


              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                result = _controller.text;
                Navigator.of(context).pop();
              },
              child: Text('Tamam'),
            ),
          ],
        );
      },
    );

    return result;
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
            child: user != null ?  Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                pageTopController(),
                userInfo() ,
                buttons(),
               ],
            ): Center(child: Text("Giriş yapmadınız",style: TextStyle(color: Colors.white),))
          ),

        ],
      ),);
  }

  Widget pageTopController(){
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            ref.read(profilePageRiverpod).clear();
            ref.read(profilePageRiverpod).setEditingMode(false);
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
        GestureDetector(
          onTapDown: (TapDownDetails details) async {
            if(widget.mode == 1){
              await _showPopupMenuOtherUser(details.globalPosition);
            }else if(widget.mode == 0 || widget.mode == 2){
              await _showPopupMenuOtherUser(details.globalPosition);
            }
          },

          child: Container(height: 16,width: 36,
            padding: EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
                color: appColors.blueDark,
                borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            child: Image(color:appColors.white,fit: BoxFit.fitWidth,image: AssetImage("assets/icons/dots.png")),),
        )
      ],
    );
  }

  Widget userInfo(){
    String userWho(){
      if(widget.mode == 0){
        return "İlan\nSahibi";
      }else if(widget.mode == 1){
        return "Sizin\nİlanınız";
      }else if(widget.mode == 2){
        return "İlana\nBaşvuran\nKişi";
      }else{
        return "İlan\nSahibi";
      }
    }
      return Padding(
        padding: const EdgeInsets.only(top: 16,bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: 84,
                child: getText(userWho(), 17, appColors.white, "fontBold",TextAlign.start)),
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
                width: 84,
                child: getText("${userData.userInfo.city}\n${userData.userInfo.country}", 15, appColors.white, "fontNormal",TextAlign.end)),
          ],
        ),
      );
  }

  Widget buttons(){
    var read = ref.read(profilePageRiverpod);
    String buttonText(){
      if(widget.mode == 1 && read.editingMode == false && user!.uid == userData.userInfo.id ){
        return "İlanı Düzenle";
      }else if(widget.mode == 1 && read.editingMode == true ){
        return "Düzenlemeden Çık";
      }else if(widget.mode == 0 || widget.mode == 2){
        return "Profile Git";
      }else{
        return "Profile Git";
      }

    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
     children: [
       GestureDetector(
           onTap: () async{
             if(buttonText() == "İlanı Düzenle" || buttonText() == "Düzenlemeden Çık" ){
               read.setEditingMode(!read.editingMode);
             }else if(buttonText() == "Profile Git"){
               if(read.pushCounter == 0){
                 if(user != null){
                   await FirestoreService().getUserInfo(userData.userInfo.id).then((value) {
                     ref.read(firebaseControllerRiverpod).fetchUser(value!);
                   });
                 }
                 read.setPushCounter(1);
                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => ProfilePage(mode: 1,)),
                 );
               }else if(read.pushCounter == 1){
                 read.setPushCounter(0);
                 Navigator.pop(context);
               }
             }
             setState(() {

             });
           },
           child: getPanelButton(buttonText(),14,"FontNormal",read.editingMode == true ? appColors.blackLight : appColors.blueDark,appColors.white)),
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

  _showPopupMenuOtherUser(Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top+12, 12, 0),
      items: [
        PopupMenuItem<String>(
          child: const Text('Bildir'), value: 'Bildir',onTap: () async{
          setState(() {

          });
        },),
      ],
      elevation: 8.0,
    );
  }

  List<String> typeSupplyList = [
    "Türü Seçin",
    'Ürün Tedariği',
    "Hizmet Tedariği",
    "Lojistik Tedariği",
    "Diğer Tedarik"
  ];

  List<String> getTurkishCitiesList = [
    'Adana',
    'Adıyaman',
    'Afyonkarahisar',
    'Ağrı',
    'Aksaray',
    'Amasya',
    'Ankara',
    'Antalya',
    'Ardahan',
    'Artvin',
    'Aydın',
    'Balıkesir',
    'Bartın',
    'Batman',
    'Bayburt',
    'Bilecik',
    'Bingöl',
    'Bitlis',
    'Bolu',
    'Burdur',
    'Bursa',
    'Çanakkale',
    'Çankırı',
    'Çorum',
    'Denizli',
    'Diyarbakır',
    'Düzce',
    'Edirne',
    'Elazığ',
    'Erzincan',
    'Erzurum',
    'Eskişehir',
    'Gaziantep',
    'Giresun',
    'Gümüşhane',
    'Hakkari',
    'Hatay',
    'Iğdır',
    'Isparta',
    'İstanbul',
    'İzmir',
    'Kahramanmaraş',
    'Karabük',
    'Karaman',
    'Kars',
    'Kastamonu',
    'Kayseri',
    'Kırıkkale',
    'Kırklareli',
    'Kırşehir',
    'Kilis',
    'Kocaeli',
    'Konya',
    'Kütahya',
    'Malatya',
    'Manisa',
    'Mardin',
    'Mersin',
    'Muğla',
    'Muş',
    'Nevşehir',
    'Niğde',
    'Ordu',
    'Osmaniye',
    'Rize',
    'Sakarya',
    'Samsun',
    'Siirt',
    'Sinop',
    'Sivas',
    'Şanlıurfa',
    'Şırnak',
    'Tekirdağ',
    'Tokat',
    'Trabzon',
    'Tunceli',
    'Uşak',
    'Van',
    'Yalova',
    'Yozgat',
    'Zonguldak',
  ];


}
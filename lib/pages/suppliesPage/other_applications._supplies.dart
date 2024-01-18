import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/models/application_supply_info.dart';
import 'package:tedarikten/models/combined_info.dart';
import 'package:tedarikten/pages/supply_details_page.dart';
import 'package:tedarikten/riverpod_management.dart';
import 'package:tedarikten/utils/firestore_helper.dart';

class OtherApplicationsSupply extends ConsumerStatefulWidget {
  const OtherApplicationsSupply({Key? key}) : super(key: key);

  @override
  ConsumerState<OtherApplicationsSupply> createState() => _OtherApplicationsSupplySupplyState();
}

class _OtherApplicationsSupplySupplyState extends ConsumerState<OtherApplicationsSupply> {
  User? user = FirebaseAuth.instance.currentUser;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late List<CombinedInfo> userDataList = [];
  @override
  void initState() {
    super.initState();
    if(user != null){

    }
  }

  Widget build(BuildContext context) {
    final appColors = AppColors();
    if(user == null) {
      return Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: 'Paylaşımlarınızı görmek için\n', style: TextStyle(fontFamily: "FontNormal",color: appColors.black,fontSize: 15)),
              TextSpan(text: 'giriş yapmalısınız',style: TextStyle(fontFamily: "FontBold",color: appColors.blueDark,fontSize: 15)),
            ],
          ),
        ),
      );
    }else{
      return FutureBuilder<List<CombinedApplicationInfo>>(
        future: FirestoreService().getApplicantsIdList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
                height: 40,
                width: 40,
                child: Center(child: CircularProgressIndicator(color: appColors.blueDark,)));
          } else if (snapshot.hasError) {
            return Center(child: Text("Bir sorun oluştu",style:  TextStyle(color: appColors.blueDark),));
          }else{
            List<CombinedApplicationInfo>? supplyDataList = snapshot.data;
            if(supplyDataList!.isEmpty){
              return Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                        fontSize: 15,
                        height: 1,
                        color: appColors.blueDark
                    ),
                    children: <TextSpan>[
                      TextSpan(text: 'Henüz', style: TextStyle(fontFamily: "FontNormal")),
                      TextSpan(text: ' tedarik ',style: TextStyle(fontFamily: "FontBold")),
                      TextSpan(text: 'yok',style: TextStyle(fontFamily: "FontNormal")),
                    ],
                  ),
                ),
              );
            }else{
              return ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: supplyDataList.length,
                itemBuilder: (context, index) {
                  return getPostContainer(supplyDataList[index]); },
              );
            }
          }
        },
      );
    }

  }
  final appColors = AppColors();
  Widget getPostContainer(CombinedApplicationInfo data) {
    print(data.userInfo);
    final appColors = AppColors();


    DateTime sharingDateTime =  DateTime.parse(data.applicationInfo.date);
    String sharingDate = DateFormat('dd.MM.yyyy HH:mm').format(sharingDateTime);

    String companyName = "Tedarikçiniz Olmak İstiyor" ;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                        color: appColors.black,
                        shape: BoxShape.circle
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6,right: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getText("${data.userInfo.name} ${data.userInfo.surname}", 14, "FontNormal", appColors.black,TextAlign.start,1),
                        getText(companyName, 13, "FontNormal", appColors.blackLight,TextAlign.start,1)
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  getText(data.applicationInfo.response == "Yanıt Bekleniyor" ? "Yanıt Ver" : "Yanıt Verildi\n${data.applicationInfo.message}", 12, "FontNormal", appColors.blackLight, TextAlign.end,1),
                  Visibility(
                    visible: data.applicationInfo.response == "Yanıt Bekleniyor",
                    child: GestureDetector(
                      onTapDown: (TapDownDetails details) async {
                        await _showPopupMenu(details.globalPosition,data.applicationInfo.id!);
                      },
                      child: Container(height: 16,width: 36,
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        margin: EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                            color: appColors.blackLight,
                            borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                        child: Image(color:appColors.white,fit: BoxFit.fitWidth,image: AssetImage("assets/icons/dots.png")),),
                    ),
                  ),
                ],
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getText(data.supplyInfo.type, 14, "FontBold", appColors.black,TextAlign.start,1),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child:  SizedBox(
                          width: 200,
                          child: getText(data.supplyInfo.description != "" ? data.supplyInfo.description :"Açıklama\neklenmemiş", 13, "FontNormal", appColors.black,TextAlign.start,2)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                        width: 80,
                        child: getText(data.applicationInfo.response, 13, "FontNormal", appColors.black,TextAlign.end,2)),
                    Container(
                      margin: EdgeInsets.only(left: 4),
                      height: 40,
                      width: 8,
                      decoration: BoxDecoration(
                          color: appColors.blackLight,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(8),bottomLeft: Radius.circular(8))
                      ),
                    )
                  ],
                ),

              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                getText(sharingDate, 13, "FontNormal", appColors.black, TextAlign.start, 1),
                GestureDetector(
                  onTap: () {
                    int mode= 0;
                    if(user!.uid == data.supplyInfo.userId){
                      mode = 2;
                    }
                    ref.read(profilePageRiverpod).setSupplyDetailsId(CombinedInfo(supplyInfo: data.supplyInfo, companyInfo: data.companyInfo, userInfo: data.userInfo));
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SupplyDetailsPage(mode: mode,)),
                    );
                  },
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                        color: appColors.orange,
                        borderRadius: BorderRadius.all(Radius.circular(5))
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            getText("İlan detaylarını görüntüle", 12, "FontNormal", appColors.white, TextAlign.center,1),
                            Icon(Icons.arrow_forward_ios_rounded,color: appColors.white,size: 11,)
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )

        ],
      ),
    );
  }

  _showPopupMenu(Offset offset,String applicationId) async {
    double left = offset.dx;
    double top = offset.dy;
    await showMenu(
      context: context,
      color: appColors.blackLight,
      position: RelativeRect.fromLTRB(left, top+12, 12, 0),
      items: [
        PopupMenuItem<String>(
          height: 32,
          child: Text('Kabul Et',style: TextStyle(color: appColors.white,fontSize: 13)), value: 'Sil',onTap: () async{
          String editingDate = DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now());
          await FirestoreService().updateApply("Kabul Edildi",editingDate,applicationId);
            setState(() {

          });
        },),
        PopupMenuItem<String>(
          height: 32,
          child: Text('Reddet',style: TextStyle(color: appColors.white,fontSize: 13),), value: 'Düzenle',onTap: () async{
          String editingDate = DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now());
          await FirestoreService().updateApply("Reddedildi",editingDate,applicationId);
          setState(() {

          });
        },),
      ],
      elevation: 2.0,
    );
  }


  Widget getText(String text, double size, String family, Color textColor, TextAlign align,int maxLines){
    return Text(text,
      textAlign: align,
      overflow: TextOverflow.ellipsis,
      maxLines: maxLines,
      style: TextStyle(
          color: textColor,
          height: 1,
          fontSize: size,
          fontFamily: family
      ),);
  }
}



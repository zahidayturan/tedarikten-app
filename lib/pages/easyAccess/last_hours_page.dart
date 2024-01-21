import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/models/combined_info.dart';
import 'package:tedarikten/pages/supply_details_page.dart';
import 'package:tedarikten/riverpod_management.dart';
import 'package:tedarikten/utils/firestore_helper.dart';

class LastHoursSupplyPage extends ConsumerStatefulWidget {

  LastHoursSupplyPage({Key? key}) : super(key: key);
  @override
  ConsumerState<LastHoursSupplyPage> createState() => _LastHoursSupplyPage();
}

class _LastHoursSupplyPage extends ConsumerState<LastHoursSupplyPage> {

  User? user = FirebaseAuth.instance.currentUser;
  FirestoreService firestoreService = FirestoreService();
  final appColors = AppColors();
  @override



  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    var read = ref.read(profilePageRiverpod);
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            topWidget(),
            user != null ? Container(
              height: size.height-300,
              width: size.width,
              padding: EdgeInsets.all(10),
              child: getItems(),
            ) : Center(child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Text("Henüz giriş yapmadınız"),
            )),
          ],
        ),
      ),
    );
  }

  Widget topWidget(){
    final appColors = AppColors();
    return Container(
      height: 200,
      child: Stack(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
                color: appColors.pink
            ),
          ),
          pageInfo(),

        ],
      ),);
  }
  Widget pageTopController(){
    final appColors = AppColors();
    var readNavBar = ref.read(customNavBarRiverpod);
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            readNavBar.setCurrentIndex(0);
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: appColors.white,
                borderRadius: BorderRadius.all(Radius.circular(5))
            ),
            child: Image(
              color: appColors.orange,
              image: AssetImage(
                  "assets/icons/arrow.png"
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text("48 Saat İlanlar",style: TextStyle(color: appColors.white,fontSize: 18,fontFamily: "FontNormal"),),
        ),
        Spacer(),
        Container(
          width: 30,
          height: 30,
          padding: EdgeInsets.all(4),
          child: Image(
            color: appColors.white,
            image: AssetImage(
                "assets/icons/question.png"
            ),
          ),)
      ],
    );
  }
  Widget pageInfo(){
    return Stack(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
              color: appColors.orange
          ),
        ),
        Positioned(
          right: 10,
          top: -20,
          child: SizedBox(
            width: 150,
            height: 150,
            child: Image(
              color: appColors.white.withOpacity(0.4),
              image: AssetImage(
                  "assets/icons/clock.png"
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              pageTopController(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 36),
                      child: user != null ?  Center(
                        child:getText("48 Saat\nİçinde Bitecek","Bu İlanlar\n", 18, appColors.white),
                      )
                          : getLineText("Henüz giriş yapmadınız", 15, "FontBold", appColors.white, TextAlign.start)
                  ),
                ],
              ),
              SizedBox()
            ],
          ),
        ),

      ],
    );
  }

  Widget getText(String textNormal, String textBold,double fontSize, Color color){
    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(text: textBold,style: TextStyle(fontFamily: "FontBold",fontSize: fontSize,color: color)),
          TextSpan(text: textNormal, style: TextStyle(fontFamily: "FontNormal",fontSize: fontSize,color: color)),
        ],
      ),
    );
  }

  Widget getItems() {
    final appColors = AppColors();
    if(user == null ){
      return Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: '48 saat ilanlarını görmek için\n', style: TextStyle(fontFamily: "FontNormal",color: appColors.black,fontSize: 15)),
              TextSpan(text: 'giriş yapmalısınız',style: TextStyle(fontFamily: "FontBold",color: appColors.blueDark,fontSize: 15)),
            ],
          ),
        ),
      );
    }else{
      return FutureBuilder<List<CombinedInfo>>(
        future: FirestoreService().getLastHoursSupplyFromFirestore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
                height: 40,
                width: 40,
                child: Center(child: CircularProgressIndicator(color: appColors.orange,)));
          } else if (snapshot.hasError) {
            return Center(child: Text("Bir sorun oluştu",style:  TextStyle(color: appColors.pink),));
          }else{
            List<CombinedInfo>? supplyDataList = snapshot.data;
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
                      TextSpan(text: 'Henüz', style: TextStyle(fontFamily: "FontNormal",color: appColors.black)),
                      TextSpan(text: ' ilan ',style: TextStyle(fontFamily: "FontBold",color: appColors.orange)),
                      TextSpan(text: 'yok',style: TextStyle(fontFamily: "FontBold",color: appColors.orange)),
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

  Widget getPostContainer(CombinedInfo data) {
    final appColors = AppColors();

    String dataStatus = data.supplyInfo.status != "" ? "${data.supplyInfo.status.split(" ")[0]}\n${data.supplyInfo.status.split(" ")[1]}" : "Tedarik\nPaylaşımı";


    DateTime firstDateTime = data.supplyInfo.dateFirst != "" ? DateTime.parse(data.supplyInfo.dateFirst) : DateTime.now();
    String firstDate = DateFormat('dd.MM.yyyy HH:mm').format(firstDateTime);
    DateTime lastDateTime = data.supplyInfo.dateLast != "" ? DateTime.parse(data.supplyInfo.dateLast) : DateTime.now();
    String lastDate = DateFormat('dd.MM.yyyy HH:mm').format(lastDateTime);

    String getCompleteStatus(){
      if(data.supplyInfo.dateLast != "" && data.supplyInfo.dateFirst != ""){
        DateTime sharingDateTime = DateTime.parse(data.supplyInfo.dateLast);
        if(sharingDateTime.isBefore(DateTime.now())){
          return "Tamamlanmış\nİlan";
        }
        else{
          return "Aktif\nİlan";
        }
      }else{
        return "";
      }
    }

    Color getStatusColor(){
      if(data.supplyInfo.status == "Tedarikçi Arıyor"){
        return appColors.pink;
      } else if(data.supplyInfo.status == "Tedarik Arıyor"){
        return appColors.orange;
      } else{
        return appColors.blueDark;
      }
    }

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getLineText(data.supplyInfo.type, 17, "FontBold", appColors.black,TextAlign.start),
                  getLineText("${data.userInfo.name} ${data.userInfo.surname}", 14, "FontNormal", appColors.blackLight,TextAlign.start)
                ],
              ),
              GestureDetector(
                onTapDown: (TapDownDetails details) async {
                  await _showPopupMenuOtherUser(details.globalPosition,user!.uid,data.supplyInfo.id!);
                },
                child: Container(height: 16,width: 36,
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                      color: getStatusColor(),
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  child: Image(color:appColors.white,fit: BoxFit.fitWidth,image: AssetImage("assets/icons/dots.png")),),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getLineText(data.supplyInfo.name, 13, "FontNormal", appColors.black,TextAlign.start),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    getLineText(dataStatus, 13, "FontNormal", appColors.black,TextAlign.right),
                    Container(
                      margin: EdgeInsets.only(left: 4),
                      height: 40,
                      width: 8,
                      decoration: BoxDecoration(
                          color: getStatusColor(),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(8),bottomLeft: Radius.circular(8))
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: 56,
                              child: getLineText("İlan\nTarihi", 12, "FontBold", appColors.blackLight, TextAlign.start)),
                          getLineText(firstDate, 12, "FontNormal", appColors.black, TextAlign.start),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 56,
                                child: getLineText("İlan Son\nTarihi", 12, "FontBold", appColors.blackLight, TextAlign.start)),
                            getLineText(lastDate, 12, "FontNormal", appColors.black, TextAlign.start),
                          ],
                        ),
                      ),

                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      getLineText(getCompleteStatus(), 13, "FontNormal", appColors.blueDark,TextAlign.right),
                      GestureDetector(
                        onTap: () {
                          int mode= 0;
                          if(user!.uid == data.supplyInfo.userId){
                            mode = 1;
                          }
                          ref.read(profilePageRiverpod).setSupplyDetailsId(data);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SupplyDetailsPage(mode: mode,)),
                          );
                        },
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                              color: appColors.blueDark,
                              borderRadius: BorderRadius.all(Radius.circular(5))
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                children: [
                                  getLineText("Detayları görüntüle", 12, "FontNormal", appColors.white, TextAlign.center),
                                  Icon(Icons.arrow_forward_ios_rounded,color: appColors.white,size: 11,)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget getLineText(String text, double size, String family, Color textColor, TextAlign align){
    return Text(text,
      textAlign: align,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          color: textColor,
          height: 1,
          fontSize: size,
          fontFamily: family
      ),);
  }

  _showPopupMenuOtherUser(Offset offset,String userId, String supplyId) async {
    double left = offset.dx;
    double top = offset.dy;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top+12, 12, 0),
      items: [
        PopupMenuItem<String>(
          child: const Text('Bildir'), value: 'Çıkar',onTap: () async{
          setState(() {

          });
        },),
      ],
      elevation: 8.0,
    );
  }

}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/models/combined_info.dart';
import 'package:tedarikten/models/supply_info.dart';
import 'package:tedarikten/pages/supply_details_page.dart';
import 'package:tedarikten/riverpod_management.dart';
import 'package:tedarikten/utils/firestore_helper.dart';


class MyActivePosts extends ConsumerStatefulWidget {
  late int mode;
  late String userId;
  MyActivePosts({Key? key,required this.mode, required this.userId}) : super(key: key);

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
    if(user == null ){
      return Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: widget.mode == 0 ? 'Paylaşımlarınızı görmek için\n' : 'Paylaşımları görmek için\n', style: TextStyle(fontFamily: "FontNormal",color: appColors.black,fontSize: 15)),
              TextSpan(text: 'giriş yapmalısınız',style: TextStyle(fontFamily: "FontBold",color: appColors.blueDark,fontSize: 15)),
            ],
          ),
        ),
      );
    }else{
      return FutureBuilder<List<CombinedInfo>>(
        future: FirestoreService().getActiveSupplyDataFromFirestore(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
                height: 40,
                width: 40,
                child: Center(child: CircularProgressIndicator(color: appColors.blueDark,)));
          } else if (snapshot.hasError) {
            return Center(child: Text("Bir sorun oluştu",style:  TextStyle(color: appColors.blueDark),));
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
                      TextSpan(text: 'Henüz', style: TextStyle(fontFamily: "FontNormal")),
                      TextSpan(text: widget.mode == 0 ? ' aktif ilanınız ' : ' aktif ilanı ',style: TextStyle(fontFamily: "FontBold")),
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

  Widget getPostContainer(CombinedInfo data) {
    final appColors = AppColors();

    String name = data.userInfo.name ?? "Kullanıcı";

    String dataStatus = data.supplyInfo.status != "" ? "${data.supplyInfo.status.split(" ")[0]}\n${data.supplyInfo.status.split(" ")[1]}" : "Tedarik\nPaylaşımı";

    DateTime sharingDateTime = data.supplyInfo.sharingDate != "" ? DateTime.parse(data.supplyInfo.sharingDate) : DateTime.now();
    String sharingDate = DateFormat('dd.MM.yyyy').format(sharingDateTime);
    String sharingTime = DateFormat('HH:mm').format(sharingDateTime);

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
                  getText(data.supplyInfo.type, 17, "FontBold", appColors.black,TextAlign.start),
                  getText("${data.userInfo.name} ${data.userInfo.surname}", 14, "FontNormal", appColors.blackLight,TextAlign.start)
                ],
              ),
              GestureDetector(
                onTapDown: (TapDownDetails details) async {
                  if(widget.mode == 0){
                    await _showPopupMenu(details.globalPosition,data.supplyInfo.id!,user!.uid,data.userInfo.id);
                  }else if(widget.mode == 1){
                    await _showPopupMenuOtherUser(details.globalPosition);
                  }
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
              getText(data.supplyInfo.name, 13, "FontNormal", appColors.black,TextAlign.start),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    getText(dataStatus, 13, "FontNormal", appColors.black,TextAlign.right),
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
                              child: getText("İlan\nTarihi", 12, "FontBold", appColors.blackLight, TextAlign.start)),
                          getText(firstDate, 12, "FontNormal", appColors.black, TextAlign.start),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 56,
                                child: getText("İlan Son\nTarihi", 12, "FontBold", appColors.blackLight, TextAlign.start)),
                            getText(lastDate, 12, "FontNormal", appColors.black, TextAlign.start),
                          ],
                        ),
                      ),

                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      getText(getCompleteStatus(), 13, "FontNormal", appColors.blueDark,TextAlign.right),
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
                                  getText("Detayları görüntüle", 12, "FontNormal", appColors.white, TextAlign.center),
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

  Widget getText(String text, double size, String family, Color textColor, TextAlign align){
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

  _showPopupMenu(Offset offset,String documentId,String currentUserId,String otherUserId) async {
    double left = offset.dx;
    double top = offset.dy;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top+12, 12, 0),
      items: [
        PopupMenuItem<String>(
          child: const Text('Sil'), value: 'Sil',onTap: () async{
          String message = await FirestoreService().deleteSupply(documentId,currentUserId,otherUserId);
          print(message);
          setState(() {

          });
        },),
      ],
      elevation: 8.0,
    );
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
}
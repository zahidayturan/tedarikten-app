import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/models/combined_info.dart';
import 'package:tedarikten/pages/supply_details_page.dart';
import 'package:tedarikten/riverpod_management.dart';
import 'package:intl/intl.dart';
import 'package:tedarikten/utils/firestore_helper.dart';

class MyPosts extends ConsumerStatefulWidget {
  const MyPosts({Key? key}) : super(key: key);

  @override
  ConsumerState<MyPosts> createState() => _MyPostsState();
}

class _MyPostsState extends ConsumerState<MyPosts> {
  User? user = FirebaseAuth.instance.currentUser;
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
      return FutureBuilder<List<CombinedInfo>>(
        future: FirestoreService().getSupplyDataFromFirestore(user!.uid),
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
                      TextSpan(text: ' paylaşımınız ',style: TextStyle(fontFamily: "FontBold")),
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
    print(data.userInfo);
    final appColors = AppColors();

    String name = ref.read(firebaseControllerRiverpod).getUser()?.name ?? "Kullanıcı";

    String postInfo = data.supplyInfo.userId == user!.uid ? "${name} bir ilan paylaştı" : "${name} bir ilanı yeniden paylaştı";

    String dataStatus = data.supplyInfo.status != "" ? "${data.supplyInfo.status.split(" ")[0]}\n${data.supplyInfo.status.split(" ")[1]}" : "Tedarik\nPaylaşımı";

    DateTime sharingDateTime =  DateTime.parse(data.supplyInfo.sharingDate);
    String sharingDate = DateFormat('dd.MM.yyyy').format(sharingDateTime);
    String sharingTime = DateFormat('HH:mm').format(sharingDateTime);

    String companyName = data.companyInfo.name != "" ? data.companyInfo.name  : "Tedarikçi Olacak" ;

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
            children: [
              getText(postInfo, 11, "FontNormal", appColors.blue,TextAlign.start),
              Container(height: 16,width: 36,
              padding: EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: getStatusColor(),
                borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: Image(color:appColors.white,fit: BoxFit.fitWidth,image: AssetImage("assets/icons/dots.png")),)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getText(data.supplyInfo.type, 17, "FontBold", appColors.black,TextAlign.start),
                  getText("${data.userInfo.name} ${data.userInfo.surname}", 14, "FontNormal", appColors.blackLight,TextAlign.start)
                ],
              ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 4),
                    height: 40,
                    width: 8,
                    decoration: BoxDecoration(
                        color: appColors.blueDark,
                        borderRadius: BorderRadius.only(topRight: Radius.circular(8),bottomRight: Radius.circular(8))
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getText(companyName, 14, "FontNormal", appColors.black,TextAlign.start),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: getText(data.supplyInfo.name, 13, "FontNormal", appColors.black,TextAlign.start),
                      ),
                    ],
                  ),
                ],
              ),
              getText(getCompleteStatus(), 13, "FontNormal", appColors.blueDark,TextAlign.right),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Row(
              children: [
                getText(sharingDate, 12, "FontNormal", appColors.black, TextAlign.start),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: getText(sharingTime, 12, "FontNormal", appColors.black, TextAlign.start),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    ref.read(profilePageRiverpod).setSupplyDetailsId(data);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SupplyDetailsPage()),
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
                )
              ],
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
}



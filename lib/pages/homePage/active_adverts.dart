
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


class ActiveAdverts extends ConsumerStatefulWidget {
  const ActiveAdverts({Key? key}) : super(key: key);

  @override
  ConsumerState<ActiveAdverts> createState() => _ActiveAdvertsState();
}

class _ActiveAdvertsState extends ConsumerState<ActiveAdverts> {
  User? user = FirebaseAuth.instance.currentUser;
  final appColors = AppColors();
  @override
  void initState() {
    super.initState();
  }

  late List<CombinedInfo> userDataList = [];


  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: getText("Aktif İlanlar", 16, "FontBold", appColors.blackLight, TextAlign.start),
        ),
        getItems()
      ],
    );

  }

  Widget getItems(){
      if(user != null){
        return Expanded(
          child: FutureBuilder<List<CombinedInfo>>(
            future: FirestoreService().getActiveSupplyDataFromFirestoreAllUser(user!.uid),
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
          ),
        );
      }else{
        return Expanded(
          child: Center(child: Text("Giriş yaptıktan sonra\nilan görüntüleyebilirsiniz")),
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
                        getText("${data.userInfo.name} ${data.userInfo.surname}", 14, "FontNormal", appColors.black,TextAlign.start),
                        getText(companyName, 13, "FontNormal", appColors.blackLight,TextAlign.start)
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getText(getCompleteStatus(), 12, "FontNormal", appColors.black,TextAlign.right),
                  Container(
                    margin: EdgeInsets.only(left: 4),
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                        color: getStatusColor(),
                        borderRadius: BorderRadius.only(topRight: Radius.circular(10),bottomLeft: Radius.circular(30),topLeft: Radius.circular(5),bottomRight: Radius.circular(5))
                    ),
                  )
                ],
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: getText("Yeni", 12, "FontBold", appColors.orange,TextAlign.start),
                          ),
                        getText(data.supplyInfo.type, 14, "FontBold", appColors.black,TextAlign.start),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          getText("İlan Son Tarihi: ", 12, "FontBold", appColors.black, TextAlign.start),
                          getText(sharingDate, 12, "FontNormal", appColors.black, TextAlign.start),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                    width: 150,
                    child: getText(data.supplyInfo.description != "" ? data.supplyInfo.description :"Açıklama\neklenmemiş", 13, "FontNormal", appColors.black,TextAlign.right)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Row(
              children: [
                Row(
                  children: [
                    Container(
                      height: 20,
                      width: 20,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: appColors.blue,
                          borderRadius: BorderRadius.all(Radius.circular(5))
                      ),
                      child: Image(
                          color: appColors.orange,
                          image: const AssetImage(
                              "assets/icons/share.png")),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: getText("Paylaş", 12, "FontNormal", appColors.black,TextAlign.right),
                    ),
                  ],
                ),
                SizedBox(width: 12,),
                Row(
                  children: [
                    Container(
                      height: 20,
                      width: 20,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: appColors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(5))
                      ),
                      child: Image(
                          color: appColors.orange,
                          image: const AssetImage(
                              "assets/icons/bookmark.png")),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: getText("Kaydet", 12, "FontNormal", appColors.black,TextAlign.right),
                  ),
                  ],
                ),
                Spacer(),
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
      maxLines: 2,
      style: TextStyle(
          color: textColor,
          height: 1,
          fontSize: size,
          fontFamily: family
      ),);
  }
}
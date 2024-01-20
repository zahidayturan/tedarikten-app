
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


class MyActiveAdverts extends ConsumerStatefulWidget {
  const MyActiveAdverts({Key? key}) : super(key: key);

  @override
  ConsumerState<MyActiveAdverts> createState() => _MyActiveAdvertsState();
}

class _MyActiveAdvertsState extends ConsumerState<MyActiveAdverts> {
  User? user = FirebaseAuth.instance.currentUser;
  final appColors = AppColors();
  @override
  void initState() {
    super.initState();
  }



  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            getText("Aktif İlanlarım", 16, "FontBold", appColors.blackLight, TextAlign.start),
            getText("İlanların Aktif Listeleniyor", 12, "FontNormal", appColors.blackLight, TextAlign.start),
          ],
        ),
        getItems()
      ],
    );
    
  }

  Widget getItems() {
    final appColors = AppColors();
    if(user == null ){
      return Container(
        height: 120,
        child: Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(text: 'Paylaşımlarınızı görmek için\n', style: TextStyle(fontFamily: "FontNormal",color: appColors.black,fontSize: 15)),
                TextSpan(text: 'giriş yapmalısınız',style: TextStyle(fontFamily: "FontBold",color: appColors.blueDark,fontSize: 15)),
              ],
            ),
          ),
        ),
      );
    }else{
      return FutureBuilder<List<CombinedInfo>>(
        future: FirestoreService().getActiveSupplyDataFromFirestore(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
                height: 120,
                width: 40,
                child: Center(child: CircularProgressIndicator(color: appColors.blueDark,)));
          } else if (snapshot.hasError) {
            return Center(child: Text("Bir sorun oluştu",style:  TextStyle(color: appColors.blueDark),));
          }else{
            List<CombinedInfo>? supplyDataList = snapshot.data;
            if(supplyDataList!.isEmpty){
              return Container(
                height: 120,
                child: Center(
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
                        TextSpan(text: ' aktif ilanınız ' ,style: TextStyle(fontFamily: "FontBold")),
                        TextSpan(text: 'yok',style: TextStyle(fontFamily: "FontNormal")),
                      ],
                    ),
                  ),
                ),
              );
            }else{
              return SizedBox(
                height: 120,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: supplyDataList.length,
                  itemBuilder: (context, index) {
                    return getPostContainer(supplyDataList[index],supplyDataList.length); },
                ),
              );
            }
          }
        },
      );
    }
  }

  Widget getPostContainer(CombinedInfo data,int length) {
    final appColors = AppColors();
    var size = MediaQuery.of(context).size;

    DateTime firstDateTime = data.supplyInfo.dateFirst != "" ? DateTime.parse(data.supplyInfo.dateFirst) : DateTime.now();
    String firstDate = DateFormat('dd.MM.yyyy').format(firstDateTime);

    DateTime lastDateTime = data.supplyInfo.dateLast != "" ? DateTime.parse(data.supplyInfo.dateLast) : DateTime.now();
    String lastDate = DateFormat('dd.MM.yyyy').format(lastDateTime);

    return Container(
      width: length != 1 ? 360 : size.width-20,
      height: 120,
      margin:  EdgeInsets.only(right: length != 1 ? 8 : 0,top: 8),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: appColors.greenLight,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getText(data.supplyInfo.type, 15, "FontBold", appColors.blue,TextAlign.start),
              SizedBox(
                  width: 160,
                  child: getText(data.supplyInfo.name, 13, "FontNormal", appColors.black,TextAlign.end)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  getText("İlan Tarihi: ", 11, "FontBold", appColors.blackLight, TextAlign.start),
                      getText(firstDate, 12, "FontNormal", appColors.black, TextAlign.start),
                ],
              ),
              Row(
                children: [
                  getText("İlan Son Tarihi: ", 11, "FontBold", appColors.blackLight, TextAlign.start),
                  getText(lastDate, 12, "FontNormal", appColors.black, TextAlign.start),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  getText(data.supplyInfo.applicantsIdList.length.toString(), 13, "FontBold", appColors.black, TextAlign.start),
                  getText(" İlgileniyor", 12, "FontNormal", appColors.blackLight, TextAlign.start),
                ],
              ),
              Row(
                children: [
                  getText(data.supplyInfo.registrantsIdList.length.toString(), 13, "FontBold", appColors.black, TextAlign.start),
                  getText(" Kaydetti", 12, "FontNormal", appColors.blackLight, TextAlign.start),
                ],
              ),
              Row(
                children: [
                  getText(data.supplyInfo.sharersIdList.length.toString(), 13, "FontBold", appColors.black, TextAlign.start),
                  getText(" Paylaştı", 12, "FontNormal", appColors.blackLight, TextAlign.start),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(),
              GestureDetector(
                onTap: () {
                  int mode= 1;
                  ref.read(profilePageRiverpod).setSupplyDetailsId(data);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SupplyDetailsPage(mode: mode,)),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: appColors.blueDark,
                      borderRadius: BorderRadius.all(Radius.circular(5))
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 4),
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
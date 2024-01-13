
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/models/supply_info.dart';
import 'package:tedarikten/riverpod_management.dart';


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
    if(user != null){
      fetchUserDataFromFirestore(FirebaseAuth.instance.currentUser!.uid);
    }
  }

  late List<SupplyInfo> userDataList = [];

  Future<void> fetchUserDataFromFirestore(String userId) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('supplies')
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<DocumentSnapshot> documents = querySnapshot.docs;

        // Null değerleri filtreleyerek SupplyInfo listesi oluştur
        userDataList = documents.map((doc) {
          Map<String, dynamic> jsonData = doc.data() as Map<String, dynamic>;

          DateTime dateLast = DateTime.parse(jsonData['dateLast']);
          DateTime today = DateTime.now();

          if (dateLast.isAfter(today)) {
            return SupplyInfo.fromJson(jsonData);
          } else {
            return null;
          }
        }).whereType<SupplyInfo>().toList(); // whereType kullanarak null olmayanları al

        print('Gelen SupplyInfo Listesi: $userDataList');
      } else {
        print('Belge bulunamadı.');
      }
    } catch (e) {
      print('Veri çekme hatası: $e');
    }

    setState(() {
      // State güncelleme işlemleri burada
    });
  }



  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            getText("Aktif İlanlarım", 16, "FontBold", appColors.blackLight, TextAlign.start),
            getText("${userDataList.length} İlanın Aktif Olarak Listeleniyor", 12, "FontNormal", appColors.blackLight, TextAlign.start),
          ],
        ),
        getItems()

      ],
    );
    
  }
  
  Widget getItems(){
    if(user != null && userDataList.isNotEmpty){
      return SizedBox(
        height: 120,
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: userDataList.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
                return getPostContainer(userDataList[index]);
          },
        ),
      );
    }else if(userDataList.isEmpty){
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
              TextSpan(text: ' aktif ilanınız ',style: TextStyle(fontFamily: "FontBold")),
              TextSpan(text: 'yok',style: TextStyle(fontFamily: "FontNormal")),
            ],
          ),
        ),
      );
    } else if(userDataList == null) {
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
      return Center(child: Text("Bir sorun oluştu",style:  TextStyle(color: appColors.blueDark),));
    }
  }

  Widget getPostContainer(SupplyInfo data) {
    final appColors = AppColors();

    DateTime firstDateTime = data.dateFirst != "" ? DateTime.parse(data.dateFirst) : DateTime.now();
    String firstDate = DateFormat('dd.MM.yyyy').format(firstDateTime);

    DateTime lastDateTime = data.dateLast != "" ? DateTime.parse(data.dateLast) : DateTime.now();
    String lastDate = DateFormat('dd.MM.yyyy').format(lastDateTime);

    return Container(
      width: 360,
      height: 120,
      margin: EdgeInsets.only(right: 8,top: 8),
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
              getText(data.type, 15, "FontBold", appColors.blue,TextAlign.start),
              SizedBox(
                  width: 160,
                  child: getText(data.name, 13, "FontNormal", appColors.black,TextAlign.end)),
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
                  getText(data.applicantsIdList.length.toString(), 13, "FontBold", appColors.black, TextAlign.start),
                  getText(" İlgileniyor", 12, "FontNormal", appColors.blackLight, TextAlign.start),
                ],
              ),
              Row(
                children: [
                  getText(data.registrantsIdList.length.toString(), 13, "FontBold", appColors.black, TextAlign.start),
                  getText(" Kaydetti", 12, "FontNormal", appColors.blackLight, TextAlign.start),
                ],
              ),
              Row(
                children: [
                  getText(data.sharersIdList.length.toString(), 13, "FontBold", appColors.black, TextAlign.start),
                  getText(" Paylaştı", 12, "FontNormal", appColors.blackLight, TextAlign.start),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(),
              Container(
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/models/supply_info.dart';
import 'package:tedarikten/riverpod_management.dart';


class MyActivePosts extends ConsumerStatefulWidget {
  const MyActivePosts({Key? key}) : super(key: key);

  @override
  ConsumerState<MyActivePosts> createState() => _MyActivePostsState();
}

class _MyActivePostsState extends ConsumerState<MyActivePosts> {
  User? user = FirebaseAuth.instance.currentUser;
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
    final appColors = AppColors();
    if(user != null && userDataList.isNotEmpty){
      return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: userDataList.length,
        itemBuilder: (context, index) {
            if(userDataList[index].dateLast != ""){
              DateTime sharingDateTime = DateTime.parse(userDataList[index].dateLast);
              if(sharingDateTime.isAfter(DateTime.now())){
                return getPostContainer(userDataList[index]);
              }
              else{
                return null;
              }
            }else{
              return null;
            }
           },
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

    String name = ref.read(firebaseControllerRiverpod).getUser()?.name ?? "Kullanıcı";

    String dataStatus = data.status != "" ? "${data.status.split(" ")[0]}\n${data.status.split(" ")[1]}" : "Tedarik\nPaylaşımı";

    DateTime sharingDateTime = data.sharingDate != "" ? DateTime.parse(data.sharingDate) : DateTime.now();
    String sharingDate = DateFormat('dd.MM.yyyy').format(sharingDateTime);
    String sharingTime = DateFormat('HH:mm').format(sharingDateTime);

    DateTime firstDateTime = data.dateFirst != "" ? DateTime.parse(data.dateFirst) : DateTime.now();
    String firstDate = DateFormat('dd.MM.yyyy HH:mm').format(firstDateTime);



    DateTime lastDateTime = data.dateLast != "" ? DateTime.parse(data.dateLast) : DateTime.now();
    String lastDate = DateFormat('dd.MM.yyyy HH:mm').format(lastDateTime);



    String getCompleteStatus(){
      if(data.dateLast != "" && data.dateFirst != ""){
        DateTime sharingDateTime = DateTime.parse(data.dateLast);
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
      if(data.status == "Tedarikçi Arıyor"){
        return appColors.pink;
      } else if(data.status == "Tedarik Arıyor"){
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
                  getText(data.type, 17, "FontBold", appColors.black,TextAlign.start),
                  getText("Mehmet Yılmaz", 14, "FontNormal", appColors.blackLight,TextAlign.start)
                ],
              ),
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
              getText(data.name, 13, "FontNormal", appColors.black,TextAlign.start),
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
                      Container(
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
}
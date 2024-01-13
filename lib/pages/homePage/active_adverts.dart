
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/models/supply_info.dart';
import 'package:tedarikten/riverpod_management.dart';


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
      return Expanded(
        child: SizedBox(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: 5,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4,top: 4),
                child: Container(
                  height: 144,
                  decoration: BoxDecoration(
                    color: appColors.white
                  ),
                ),
              );
            },
          ),
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
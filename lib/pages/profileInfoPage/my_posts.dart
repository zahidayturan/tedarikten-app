import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tedarikten/constants/app_colors.dart';

class MyPosts extends ConsumerStatefulWidget {
  const MyPosts({Key? key}) : super(key: key);

  @override
  ConsumerState<MyPosts> createState() => _MyPostsState();
}

class _MyPostsState extends ConsumerState<MyPosts> {
  @override
  late List<Map<String, dynamic>> userDataList = [];


  User? user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    if(user != null){
      fetchUserDataFromFirestore(FirebaseAuth.instance.currentUser!.uid);
    }
  }

  Future<void> fetchUserDataFromFirestore(String userId) async {
    userDataList.clear();

    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('supplies')
          .where('userId', isEqualTo: userId)
          .get();

      List<QueryDocumentSnapshot> documents = querySnapshot.docs;
      for (var document in documents) {
        Map<String, dynamic> data = {
          'typeSupply': document['typeSupply'],
          'nameSupply': document['nameSupply'],
        };

        userDataList.add(data);
      }
    } catch (e) {
      print('Veri çekme hatası: $e');
    }

    setState(() {});
  }

  Widget build(BuildContext context) {
    final appColors = AppColors();
    if(user != null && userDataList.isNotEmpty){
      return ListView.builder(
        itemCount: userDataList.length,
        itemBuilder: (context, index) {
          return getPostContainer(userDataList[index]); },
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
              TextSpan(text: ' paylaşımınız ',style: TextStyle(fontFamily: "FontBold")),
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

  Widget getPostContainer(Map<String, dynamic> data) {
    final appColors = AppColors();

    return Container(
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Column(
        children: [
          Text('${data['typeSupply']}'),
          Text('${data['nameSupply']}'),
        ],
      ),
    );
  }
}



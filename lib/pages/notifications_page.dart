import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/models/notification_info.dart';
import 'package:tedarikten/models/user_info.dart';
import 'package:tedarikten/pages/login_page.dart';
import 'package:tedarikten/pages/profileInfoPage/my_active_posts.dart';
import 'package:tedarikten/pages/profileInfoPage/my_posts.dart';
import 'package:tedarikten/riverpod_management.dart';
import 'package:tedarikten/utils/firestore_helper.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);
  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPage();
}

class _NotificationsPage extends ConsumerState<NotificationsPage> {
  User? user = FirebaseAuth.instance.currentUser;
  FirestoreService firestoreService = FirestoreService();
  final appColors = AppColors();

  @override
  void initState(){
    super.initState();
  }


  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    var read = ref.read(profilePageRiverpod);
    int switchIndex = read.switchCurrentIndex;
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            topWidget(user),
            SizedBox(height: 20,),
            Expanded(child: getNotifications())
          ],
        ),
      ),
    );
  }

  Widget getNotifications() {
    if(user == null) {
      return Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: 'Bildirimlerinizi görmek için\n', style: TextStyle(fontFamily: "FontNormal",color: appColors.black,fontSize: 15)),
              TextSpan(text: 'giriş yapmalısınız',style: TextStyle(fontFamily: "FontBold",color: appColors.blueDark,fontSize: 15)),
            ],
          ),
        ),
      );
    }else{
      return FutureBuilder<List<CombinedNotificationInfo>>(
        future: FirestoreService().getNotificationsByUserId(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
                height: 40,
                width: 40,
                child: Center(child: CircularProgressIndicator(color: appColors.blueDark,)));
          } else if (snapshot.hasError) {
            return Center(child: Text("Bir sorun oluştu",style:  TextStyle(color: appColors.blueDark),));
          }else{
            List<CombinedNotificationInfo>? notifications = snapshot.data;
            if(notifications!.isEmpty){
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
                      TextSpan(text: ' bildiriminiz ',style: TextStyle(fontFamily: "FontBold")),
                      TextSpan(text: 'yok',style: TextStyle(fontFamily: "FontNormal")),
                    ],
                  ),
                ),
              );
            }else{
              return ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return getPostContainer(notifications[index]); },
              );
            }
          }
        },
      );
    }
  }

  Widget getPostContainer(CombinedNotificationInfo data) {
    var size = MediaQuery.of(context).size;

    DateTime dateTime =  DateTime.parse(data.notificationInfo.date);
    String sharingDate = DateFormat('dd.MM.yyyy').format(dateTime);
    String sharingTime = DateFormat('HH:mm').format(dateTime);
    


    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: size.width,
        height: 72,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 6,
              margin: EdgeInsets.only(right: 10),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: appColors.blueDark,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: appColors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    getText("${data.userInfo.name} ${data.userInfo.surname} ", data.notificationInfo.title, 15, appColors.blackLight),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("$sharingDate "),
                            Text(sharingTime)
                          ],
                        ),
                        GestureDetector(
                            onTap: () async{
                              await FirestoreService().deleteNotifications(data.notificationInfo.id!);
                              setState(() {

                              });
                              },
                            child: getButton("Sil", appColors.pink, appColors.blackLight, 13,Icons.delete_forever_rounded)),
                        Visibility(
                          visible: data.notificationInfo.isRead == false,
                          child: GestureDetector(
                              onTap: () async {
                                await FirestoreService().updateNotifications(data.notificationInfo.id!);
                                setState(() {

                                });
                                },
                              child: getButton("Okudum", appColors.blueLight, appColors.blackLight, 13,Icons.check_rounded)),
                        ),
                        Visibility(
                            visible: data.notificationInfo.isRead == true,
                            child: Text("Okundu",style: TextStyle(color: appColors.blueDark),)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getButton(String text,Color buttonColor,Color textColor,double fontSize,IconData icon){
    var size = MediaQuery.of(context).size;
    return Row(
      children: [
        Container(
          width: 24,
          decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.all(Radius.circular(5))
          ),
          child: Icon(
            icon,
            color: appColors.white,
          )
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 6),
          child: Center(child: Text(text, style: TextStyle(color: textColor,fontSize: fontSize,fontFamily: "FontNormal"))),
        ),
      ],
    );
  }

  Widget topWidget(User? user){
    final appColors = AppColors();
    return Container(
      height: 200,
      child: Stack(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
                color: appColors.blueDark,
            ),
          ),
          Positioned(
              right: -60,
              top: -20,
              child: Icon(Icons.notifications_rounded,color: appColors.blueLight.withOpacity(0.2),size: 176,)),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                pageTopController(),
                Padding(
                  padding: const EdgeInsets.only(top: 36,left: 36),
                  child: user != null ? getNotificationCount() : Text("Henüz\ngiriş\nyapmadınız",style: TextStyle(color: appColors.white),),
                )
                
              ],
            ),
          ),

        ],
      ),);
  }
  Widget pageTopController(){
    final appColors = AppColors();
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: appColors.blueDark,
                borderRadius: BorderRadius.all(Radius.circular(5))
            ),
            child: Image(
              color: appColors.white,
              image: AssetImage(
                  "assets/icons/arrow.png"
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text("Bildirimler",style: TextStyle(color: appColors.white,fontSize: 18,fontFamily: "FontNormal"),),
        ),
      ],
    );
  }


  Widget getText(String textNormal, String textBold,double fontSize, Color color){
    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(text: textNormal, style: TextStyle(fontFamily: "FontNormal",fontSize: fontSize,color: color)),
          TextSpan(text: textBold,style: TextStyle(fontFamily: "FontBold",fontSize: fontSize,color: color)),
        ],
      ),
    );
  }

  Widget getNotificationCount(){
    return FutureBuilder<String>(
      future: FirestoreService().getNotificationCountFromFirestore(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(color: appColors.orange,);
        } else if (snapshot.hasError) {
          return const Text('?');
        } else {
          String count = snapshot.data ?? "0";
          return count != "0" ?
          getText("$count Adet\n", "Okunmamış\nBildiriminiz Var", 18, appColors.white)
              : getText("Henüz\nBildiriminiz\n","Yok", 18, appColors.white);
        }
      },
    );
  }
}


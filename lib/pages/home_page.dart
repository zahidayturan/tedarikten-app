import 'package:flutter/material.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/ui/home_app_bar.dart';
import 'package:tedarikten/ui/navigation_bar.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors();
    return SafeArea(
      child: Scaffold(
        backgroundColor: appColors.whiteDark,
        appBar: HomeAppBar(),
        bottomNavigationBar: const CustomBottomNavigationBar(),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(children: [
            easyAccessContainer()

          ],),
        )
      ),
    );
  }

  Widget easyAccessContainer (){
    final appColors = AppColors();
    return SizedBox(
      height: 124,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            getContainerForEasyAccess(appColors.pink,const Color(0XFFB82F43),"Acil\n","Olan\nİlanları\nGörüntüle","assets/icons/sandWatch.png"),
            const SizedBox(width: 10,),
            getContainerForEasyAccess(appColors.orange,const Color(0XFFF99000),"Son\n48 Saat\n","İlanlarını\nGörüntüle","assets/icons/clock.png"),
            const SizedBox(width: 10,),
            getContainerForEasyAccess(appColors.blue,const Color(0XFF8FA9B1),"Yakınında\n","Olan\nİlanları\nGörüntüle","assets/icons/location.png"),
            const SizedBox(width: 10,),
            getContainerForEasyAccess(appColors.blueDark,const Color(0XFF16697A),"Kayıtlı\n","İlanları\nGörüntüle","assets/icons/bookmark.png"),
          ],
        ),
      ),
    );
  }
  
  Widget getContainerForEasyAccess(Color color,Color colorGradient,String textBold, String textNormal, String icon){
    final appColors = AppColors();
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        color: color,
        gradient: LinearGradient(
          transform: const GradientRotation(140),
            colors: [
          color,
          colorGradient
        ]),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
        BoxShadow(
          color: appColors.blackLight.withOpacity(0.6),
          blurRadius: 1,
          offset: const Offset(0,1),
        )
        ]
      ),
      child: Stack(
        fit: StackFit.loose,
        children: [
          Positioned(
            right: 6,
            top: 6,
            child: RichText(
              textDirection: TextDirection.rtl,
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: textBold, style: const TextStyle(fontFamily: "FontBold",fontSize: 17)),
                  TextSpan(text: textNormal,style: const TextStyle(fontFamily: "FontNormal",fontSize: 17)),
                ],
              ),
            ),
          ),
          Positioned(
            left: 4,
            bottom: 10,
            child: SizedBox(
              width: 90,
              height: 90,
              child: Image(
                color: appColors.white.withOpacity(0.2),
                image: AssetImage(
                  icon,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
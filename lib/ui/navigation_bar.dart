import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/riverpod_management.dart';

class CustomBottomNavigationBar extends ConsumerStatefulWidget {
  const CustomBottomNavigationBar({Key? key}) : super(key: key);
  @override
  ConsumerState<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBar();
}


class _CustomBottomNavigationBar extends ConsumerState<CustomBottomNavigationBar>{

  Widget build(BuildContext context){
    final appColors = AppColors();
    var size = MediaQuery.of(context).size;
    return Container(
      height: 64,
      color: appColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          getButton(0,"Ana Sayfa","assets/icons/homeActive.png","assets/icons/homePassive.png"),
          getButton(1,"Sosyal","assets/icons/socialActive.png","assets/icons/socialPassive.png"),
          getButton(2, "Ekle", "",""),
          getButton(3,"Tedarikler","assets/icons/supplyActive.png","assets/icons/supplyPassive.png"),
          getButton(4,"Diğer","assets/icons/otherActive.png","assets/icons/otherPassive.png")
        ],
      ),
    );
  }


  Widget getButton(int menuIndex,String text,String activeIcon,String passiveIcon){
    var read = ref.read(customNavBarRiverpod);
    bool check = read.currentIndex == menuIndex;
    final appColors = AppColors();
    return GestureDetector(
      onTap: () {
        setState(() {
          read.currentIndex = menuIndex;
        });
      },
      child: menuIndex == 2 ? Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(22)),
          color: appColors.orange
        ),
        child: Icon(
          Icons.add_rounded,
          color: appColors.white,
          size: 48,
        ),
      ) : Column(
        mainAxisAlignment:  MainAxisAlignment.spaceAround,
        children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8,),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: 28 ,
              height: check == true ? 8 : 0,
              decoration: BoxDecoration(
              color: appColors.blue,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)
              )
            ),),
            const SizedBox(height: 8,),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: SizedBox(
            width: 26,
            height: 26,
            child: Image(
              color: check == true ? appColors.blue : appColors.blackLight,
              image: AssetImage(
                check == true ? activeIcon : passiveIcon,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(text,style: TextStyle(
            color: check == true ? appColors.blue : appColors.blackLight,
            fontSize: 12,
            height: 1,
          ),),
        )
      ]),
    );
  }
}
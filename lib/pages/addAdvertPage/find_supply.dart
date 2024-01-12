import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tedarikten/constants/app_colors.dart';
import 'package:tedarikten/utils/firestore_helper.dart';

class FindSupply extends ConsumerStatefulWidget {
  const FindSupply({Key? key}) : super(key: key);

  @override
  ConsumerState<FindSupply> createState() => _FindSupplyState();
}

class _FindSupplyState extends ConsumerState<FindSupply> {
  @override
  FirestoreService firestoreService = FirestoreService();
  final appColors = AppColors();
  @override
  void initState() {
    super.initState();
    typeSupplyController.text = typeSupplySelect;
    locationSupplyController.text = locationSupplySelect;
    locationCompanySupplyController.text = locationCompanySupplySelect;

  }
  User? user = FirebaseAuth.instance.currentUser;
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final appColors = AppColors();
    return user != null ? Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                getSectionText("İlan Bilgileri",appColors.blueDark),
                SizedBox(height: 8,),
                getSectionContainerWithRow(true,"Tedarik Türü",getDropDownMenu(typeSupplyList,typeSupplyController,"",appColors.blueDark)),
                SizedBox(height: 8,),
                getSectionContainerWithRow(true,"Tedarik\nÜrün Adı",getTextFormField(0,0,54,nameSupplyController,"Ürün adını yazınız",108,2,appColors.blueDark,"")),
                SizedBox(height: 8,),
                getSectionContainerWithRow(false,"Tedarik\nAçıklaması",getTextFormField(0,0,54,descriptionSupplyController,"Açıklama metnini yazınız",256,2,appColors.blueDark,"")),
                SizedBox(height: 8,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 1,child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: getSectionContainerWithRow(true,"İlan\nTarihi",getDateSupply(context,"First")),
                        )),
                    Expanded(
                        flex: 1,child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: getSectionContainerWithRow(true,"İlan\nSon\nTarihi",getDateSupply(context,"Last")),
                        )),
                  ],
                ),
                SizedBox(height: 8,),
                getSectionContainerWithRow(false,"Tedarik Miktarı",getTextFormField(1,124,28,amountSupplyController,"Miktar Girin",12,1,appColors.white,"")),
                SizedBox(height: 8,),
                getSectionContainerWithRow(false,"Minimum Teslim Süresi",getTextFormField(1,60,28,minDeliveryTimeSupplyController,"Girin",4,1,appColors.white,"Gün")),
                SizedBox(height: 8,),
                getSectionContainerWithRow(false,"Konumu",getDropDownMenu(getTurkishCitiesList,locationSupplyController," /Türkiye",appColors.blueDark)),

                SizedBox(height: 16,),
                getSectionText("Firma Bilgileri", appColors.blueLight),
                SizedBox(height: 8,),
                getSectionContainerWithRow(true,"Firma\nAdı",getTextFormField(0,0,54,companyNameSupplyController,"Firma adını yazınız",108,2,appColors.blueLight,"")),
                SizedBox(height: 8,),
                getSectionContainerWithRow(true,"Konumu",getDropDownMenu(getTurkishCitiesList,locationCompanySupplyController," /Türkiye",appColors.blueLight)),
                SizedBox(height: 8,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 124,
                      height: 64,
                      decoration: BoxDecoration(
                        color: appColors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5))
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("Kuruluş Yılı",style: TextStyle(color: appColors.black,height: 1,fontSize: 14),),
                            getTextFormField(2,100,28,companyYearSupplyController,"Yıl yazınız",4,1,appColors.white,""),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: getSectionContainerWithRow(true,"İletişim\nNumarası",getTextFormField(0,0,54,companyPhoneSupplyController,"0*** *** ** **",14,1,appColors.blueLight,"")),
                    )),
                  ],
                ),
                SizedBox(height: 8,),
                getSectionContainerWithRow(false,"Adres\nBilgisi",getTextFormField(0,0,54,companyAddressSupplyController,"Adres metnini yazınız",108,2,appColors.blueLight,"")),
                SizedBox(height: 8,),
                getSectionContainerWithRow(true,"Firma Yetkilisi\nAdı Soyadı",getTextFormField(0,0,54,companyPersonNameSurnameSupplyController,"Bilgileri yazınız",24,2,appColors.blueLight,"")),
                SizedBox(height: 8,),
                getSectionContainerWithRow(true,"Firma Yetkilisi\ne-Posta Adresi",getTextFormField(0,0,54,companyPersonEmailSupplyController,"Mail adresini yazınız",108,2,appColors.blueLight,"")),

                SizedBox(height: 16,),
                getSectionText("Ek Dosyalar", appColors.blue),
                getSectionContainerWithRow(false, "Dosya Eklemek İçin Dokunun", SizedBox())
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
            GestureDetector(
              onTap: () {
                nameSupplyController.clear();
                descriptionSupplyController.clear();
                setState(() {

                });
              },child: getButton("SIFIRLA", appColors.blue, appColors.white,16),
           ),
            GestureDetector(
              onTap: () async{
                await firestoreService.addAdvertToFirestore(user!.uid);
              }, child: getButton("PAYLAŞ", appColors.orange, appColors.white,16))
          ],),
        )

      ],
    ) : Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(text: 'İlan oluşturmak için\n', style: TextStyle(fontFamily: "FontNormal",color: appColors.black,fontSize: 15)),
            TextSpan(text: 'giriş yapmalısınız',style: TextStyle(fontFamily: "FontBold",color: appColors.orange,fontSize: 15)),
          ],
        ),
      ),
    );
  }
  Widget getButton(String text,Color buttonColor,Color textColor,double fontSize){

    var size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 12),
        child: Text(text, style: TextStyle(color: textColor,fontSize: fontSize,fontFamily: "FontBold")),
      ),
    );
  }

  Widget getSectionText(String text,Color color){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(text,style: TextStyle(fontSize: 17,color: color,fontFamily: "FontBold"),),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(height: 3,decoration: BoxDecoration(color: color,borderRadius: BorderRadius.all(Radius.circular(5))),),
          ),
        )
      ],
    );
  }

  DateTime selectedDateFirst = DateTime.now();
  DateTime selectedDateLast = DateTime.now();
  TimeOfDay selectedTimeFirst = TimeOfDay.now();
  TimeOfDay selectedTimeLast = TimeOfDay.now();
  Widget getDateSupply(BuildContext context,String selectedDateType){

      String getTextDateTime(){
        if(selectedDateType == "First"){
          return "${selectedDateFirst.day}.${selectedDateFirst.month}.${selectedDateFirst.year}";
        }else{
          return "${selectedDateLast.day}.${selectedDateLast.month}.${selectedDateLast.year}";
        }
      }
      DateTime getDateTime(){
        if(selectedDateType == "First"){
          return selectedDateFirst;
        }else{
          return selectedDateLast;
        }
      }
      Future<void> _selectDate() async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: getDateTime(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );

        if (picked != null &&( picked != selectedDateFirst || picked != selectedDateLast)) {
          setState(() {
            if(selectedDateType == "First"){
              selectedDateFirst = picked;
            }else{
              selectedDateLast= picked;
            }
          });
        }
      }

      String getTextTimeOfDay(){
        if(selectedDateType == "First"){
          return "${selectedTimeFirst.hour.toString()}:${selectedTimeFirst.minute.toString()}";
        }else{
          return "${selectedTimeLast.hour.toString()}:${selectedTimeLast.minute.toString()}";
        }
      }
      TimeOfDay getTimeOfDay(){
        if(selectedDateType == "First"){
          return selectedTimeFirst;
        }else{
          return selectedTimeLast;
        }
      }

      Future<void> _selectTime() async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: getTimeOfDay(),
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
        );

        if (picked != null && (picked != selectedTimeFirst || picked != selectedTimeLast)) {
          setState(() {
            if(selectedDateType == "First"){
              selectedTimeFirst = picked;
            }else{
              selectedTimeLast = picked;
            }
          });
        }
      }

      return Container(
      height: 54,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            height: 24,
            decoration: BoxDecoration(
              color: appColors.blueDark,
              borderRadius: BorderRadius.all(Radius.circular(5))
            ),
            child: GestureDetector(
                onTap: () async{
                  _selectDate();
                  setState(() {

                  });
                },
                child: Center(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(getTextDateTime(),style: TextStyle(color: appColors.white),),
                ))),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(Icons.access_time_rounded,color: appColors.blueDark,),
              ),
              Container(
                height: 24,
                decoration: BoxDecoration(
                    color: appColors.blueDark,
                    borderRadius: BorderRadius.all(Radius.circular(5))
                ),
                child: GestureDetector(
                  onTap: () {
                    _selectTime();
                    setState(() {
                    });
                  },
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(getTextTimeOfDay(),style: TextStyle(color: appColors.white),),
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

  List<String> typeSupplyList = [
    'Türü Seçin',
    'Ürün Tedariği',
    "Hizmet Tedariği",
    "Lojistik Tedariği",
    "Diğer Tedarik"
  ];


  String typeSupplySelect = "Türü Seçin";
  String locationSupplySelect = "Şehir Seçin";
  String locationCompanySupplySelect = "Şehir Seçin";
  TextEditingController typeSupplyController = TextEditingController();
  TextEditingController locationSupplyController = TextEditingController();
  TextEditingController locationCompanySupplyController = TextEditingController() ;

  Widget getDropDownMenu(List<String> list,TextEditingController controller,String helperText, Color color) {
    final appColors = AppColors();
    return Row(
      children: [
        Container(
          height: 28,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(8))
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.text,
              padding: EdgeInsets.zero,
              dropdownColor: color,
              iconEnabledColor: appColors.white,
              isDense: true,
              hint: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(controller.text,style: TextStyle(
                    color: appColors.white
                  ),),
                ),
              ),
              icon: Icon(Icons.keyboard_arrow_down_rounded,size: 22),
              borderRadius: BorderRadius.all(Radius.circular(5)),
              menuMaxHeight: 180,
             // alignment: AlignmentDirectional(0,0),
              items: list.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8,right: 0),
                    child: Text(value,style: TextStyle(color: appColors.white,fontSize: 14,height: 1)),
                  ),
                );
              }).toList(),
              onChanged: (value) {

                setState(() {
                  controller.text = value!;
                });

              },
            ),
          ),
        ),
        Visibility(
          visible: helperText.isNotEmpty,
          child: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(helperText,style: TextStyle(
                color: color,
            ),),
          ),
        )
      ],
    );
  }

  final TextEditingController nameSupplyController = TextEditingController();
  final TextEditingController descriptionSupplyController = TextEditingController();
  final TextEditingController amountSupplyController = TextEditingController();
  final TextEditingController minDeliveryTimeSupplyController = TextEditingController();
  final TextEditingController companyNameSupplyController = TextEditingController();
  final TextEditingController companyYearSupplyController = TextEditingController();
  final TextEditingController companyPhoneSupplyController = TextEditingController();
  final TextEditingController companyAddressSupplyController = TextEditingController();
  final TextEditingController companyPersonNameSurnameSupplyController = TextEditingController();
  final TextEditingController companyPersonEmailSupplyController = TextEditingController();

  Widget getTextFormField(int formType,double width,double height,TextEditingController? controller,String hintText,int maxLength, int maxLines,Color textColor,String helperText){
    if(formType == 0){
      return Expanded(
        child: Container(
          height: height,
          child: TextFormField(
            maxLines: maxLines,
            maxLength: maxLength,
            controller: controller,
            style: TextStyle(color: textColor),
            keyboardType: TextInputType.text,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    height: 1
                ),
                counterStyle: TextStyle(
                  color: textColor,
                ),
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none
            ),
          ),
        ),
      );
    }
    else if(formType == 1){
    return Row(
      children: [
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: appColors.blueDark,
            borderRadius: BorderRadius.all(Radius.circular(8))
          ),
          child: TextFormField(
            maxLines: maxLines,
            maxLength: maxLength,
            controller: controller,
            style: TextStyle(color: textColor),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: textColor,
                fontSize: 14,
                height: 1
              ),
              counterText: "",
              contentPadding: EdgeInsets.only(bottom: 16),
              border: InputBorder.none
            ),
          ),
        ),
        Visibility(
          visible: helperText.isNotEmpty,
          child: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(helperText,style: TextStyle(
              color: appColors.blueDark
            ),),
          ),
        )
      ],
    );
    }
    else{
      return Column(
        children: [
          Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
                color: appColors.blueLight,
                borderRadius: BorderRadius.all(Radius.circular(8))
            ),
            child: TextFormField(
              maxLines: maxLines,
              maxLength: maxLength,
              controller: controller,
              style: TextStyle(color: textColor),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      height: 1
                  ),
                  counterText: "",
                  contentPadding: EdgeInsets.only(bottom: 16),
                  border: InputBorder.none
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget getSectionContainerWithRow(bool required,String text,Widget yourWidget){
    final appColors = AppColors();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6,vertical: 6),
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Row(
              children: [
                Text(required == true ? "* " : "   ",style: TextStyle(color: appColors.orange,fontFamily: "FontBold"),),
                Text(text,style: TextStyle(color: appColors.black,height: 1,fontSize: 14),),
              ],
            ),
          ),
          yourWidget,
        ],
      ),
    );
  }

  List<String> getTurkishCitiesList = [
    'Şehir Seçin',
    'Adana',
    'Adıyaman',
    'Afyonkarahisar',
    'Ağrı',
    'Aksaray',
    'Amasya',
    'Ankara',
    'Antalya',
    'Ardahan',
    'Artvin',
    'Aydın',
    'Balıkesir',
    'Bartın',
    'Batman',
    'Bayburt',
    'Bilecik',
    'Bingöl',
    'Bitlis',
    'Bolu',
    'Burdur',
    'Bursa',
    'Çanakkale',
    'Çankırı',
    'Çorum',
    'Denizli',
    'Diyarbakır',
    'Düzce',
    'Edirne',
    'Elazığ',
    'Erzincan',
    'Erzurum',
    'Eskişehir',
    'Gaziantep',
    'Giresun',
    'Gümüşhane',
    'Hakkari',
    'Hatay',
    'Iğdır',
    'Isparta',
    'İstanbul',
    'İzmir',
    'Kahramanmaraş',
    'Karabük',
    'Karaman',
    'Kars',
    'Kastamonu',
    'Kayseri',
    'Kırıkkale',
    'Kırklareli',
    'Kırşehir',
    'Kilis',
    'Kocaeli',
    'Konya',
    'Kütahya',
    'Malatya',
    'Manisa',
    'Mardin',
    'Mersin',
    'Muğla',
    'Muş',
    'Nevşehir',
    'Niğde',
    'Ordu',
    'Osmaniye',
    'Rize',
    'Sakarya',
    'Samsun',
    'Siirt',
    'Sinop',
    'Sivas',
    'Şanlıurfa',
    'Şırnak',
    'Tekirdağ',
    'Tokat',
    'Trabzon',
    'Tunceli',
    'Uşak',
    'Van',
    'Yalova',
    'Yozgat',
    'Zonguldak',
  ];

}



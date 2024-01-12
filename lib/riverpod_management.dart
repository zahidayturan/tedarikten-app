import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tedarikten/riverpod/add_advert_page_riverpod.dart';
import 'package:tedarikten/riverpod/custom_nav_bar_riverpod.dart';
import 'package:tedarikten/riverpod/firebase_controller_riverpod.dart';
import 'package:tedarikten/riverpod/profile_page_riverpod.dart';

final customNavBarRiverpod = ChangeNotifierProvider((ref) => CustomBottomNavBarRiverpod());
final profilePageRiverpod = ChangeNotifierProvider((ref) => ProfilePageRiverpod());
final addAdvertPageRiverpod = ChangeNotifierProvider((ref) => AddAdvertPageRiverpod());
final firebaseControllerRiverpod = ChangeNotifierProvider((ref) => FirebaseControllerRiverpod());
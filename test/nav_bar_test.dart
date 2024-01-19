import 'package:flutter_test/flutter_test.dart';
import 'package:tedarikten/pages/addAdvertPage/add_advert_page.dart';
import 'package:tedarikten/pages/homePage/home_page.dart';
import 'package:tedarikten/pages/suppliesPage/supplies_page.dart';
import 'package:tedarikten/riverpod/custom_nav_bar_riverpod.dart';


void main() {
  group('CustomBottomNavBarRiverpod Tests', () {
    test('Initial index should be 0', () {
      final customBottomNavBar = CustomBottomNavBarRiverpod();

      expect(customBottomNavBar.currentIndex, 0);
    });

    test('Setting current index should update currentIndex', () {
      final customBottomNavBar = CustomBottomNavBarRiverpod();

      customBottomNavBar.setCurrentIndex(2);

      expect(customBottomNavBar.currentIndex, 2);
    });

    test('body() method should return HomePage widget for index 0', () {
      final customBottomNavBar = CustomBottomNavBarRiverpod();

      final bodyWidget = customBottomNavBar.body();

      expect(bodyWidget, isA<HomePage>());
    });

    test('body() method should return AddAdvertPage widget for index 2', () {
      final customBottomNavBar = CustomBottomNavBarRiverpod();
      customBottomNavBar.setCurrentIndex(2);

      final bodyWidget = customBottomNavBar.body();

      expect(bodyWidget, isA<AddAdvertPage>());
    });

    test('body() method should return SuppliesPage widget for index 3', () {
      final customBottomNavBar = CustomBottomNavBarRiverpod();
      customBottomNavBar.setCurrentIndex(3);

      final bodyWidget = customBottomNavBar.body();

      expect(bodyWidget, isA<SuppliesPage>());
    });

    test('body() method should return HomePage widget for default index', () {
      final customBottomNavBar = CustomBottomNavBarRiverpod();
      customBottomNavBar.setCurrentIndex(5); // Any index not covered in switch statement

      final bodyWidget = customBottomNavBar.body();

      expect(bodyWidget, isA<HomePage>());
    });
  });
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'splash_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart'; // Ayarlar sayfasını ekledik
import 'sicaklik_screen.dart'; // Sıcaklık sayfası
import 'yem_su_screen.dart'; // Yem & Su sayfası
import 'kayan_kapi_screen.dart'; // Kayan Kapı sayfası
import 'tavuk_sayisi_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/external_camera_screen.dart';
import 'services/language_service.dart';
import 'services/theme_service.dart';
import 'services/camera_service.dart';
import 'services/statistics_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageService()),
        ChangeNotifierProvider(create: (context) => ThemeService()),
        ChangeNotifierProvider(create: (context) => StatisticsService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Akıllı Kümes',
      theme: Provider.of<ThemeService>(context).currentTheme,
      home: SplashScreen(),
      onGenerateRoute: (settings) {
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            switch (settings.name) {
              case '/home':
                return HomeScreen();
              case '/sicaklik':
                return SicaklikScreen();
              case '/yem_su':
                return YemSuScreen();
              case '/kayan_kapi':
                return KayanKapiScreen();
              case '/tavuk_sayisi':
                return TavukSayisiScreen();
              case '/ayarlar':
                return SettingsScreen();
              case '/statistics':
                return StatisticsScreen();
              case '/external_camera':
                return ExternalCameraScreen();
              default:
                return HomeScreen();
            }
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: Duration(milliseconds: 1000),
          reverseTransitionDuration: Duration(milliseconds: 1000),
        );
      },
    );
  }
}

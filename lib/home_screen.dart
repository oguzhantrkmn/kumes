import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:kumes/widgets/rtsp_stream_view.dart';
import 'services/language_service.dart';
import 'services/theme_service.dart';
import 'sicaklik_screen.dart';
import 'yem_su_screen.dart';
import 'tavuk_sayisi_screen.dart';
import 'settings_screen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'screens/statistics_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _sicaklik = 0.0;
  double _yemSeviyesi = 0.0;
  double _suSeviyesi = 0.0;
  int _tavukSayisi = 0;
  bool _kapiDurumu = false;

  double cameraHeight = 300;

  bool _isLoading = true;
  int _selectedIndex = 0;
  bool _isFirstLaunch = true;

  late DatabaseReference _temperatureRef;
  String _todayKey = '';

  @override
  void initState() {
    super.initState();
    _temperatureRef = FirebaseDatabase.instance.ref('sensor_data');
    final now = DateTime.now();
    _todayKey =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    _yemSuDegerleriniYukle();
    _tavukSayisiniYukle();
    _kapiDurumunuYukle();
    _loadSettings();
  }

  Future<void> _yemSuDegerleriniYukle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _yemSeviyesi = 0.0;
      _suSeviyesi = 0.0;
    });
  }

  Future<void> _tavukSayisiniYukle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tavukSayisi = 0;
    });
  }

  Future<void> _kapiDurumunuYukle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _kapiDurumu = prefs.getBool('kapi_durumu') ?? false;
    });
  }

  Future<void> _kapiDurumunuDegistir() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _kapiDurumu = !_kapiDurumu;
    });
    await prefs.setBool('kapi_durumu', _kapiDurumu);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
      _isLoading = false;
    });

    if (_isFirstLaunch) {
      await Future.delayed(const Duration(milliseconds: 500));
      _showTutorialDialog();
    }
  }

  void _showTutorialDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      title: 'Hoş Geldiniz!',
      desc:
          'Kümes Yönetim Uygulamasına hoş geldiniz. Bu uygulama ile kümesinizi kolayca yönetebilirsiniz.',
      btnOkText: 'Başla',
      btnOkOnPress: () {
        _showNextTutorialDialog(0);
      },
      customHeader: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          "assets/images/chicken.png",
          width: 40,
          height: 40,
        ),
      ),
    ).show();
  }

  void _showNextTutorialDialog(int index) {
    List<Map<String, dynamic>> tutorials = [
      {
        'title': 'Sıcaklık',
        'desc': 'Kümesin sıcaklığını ve geçmiş verileri takip edebilirsiniz.',
        'lottie': 'assets/lottie/thermometer.json',
      },
      {
        'title': 'Yem ve Su',
        'desc': 'Yem ve su seviyelerini anlık ve geçmiş olarak görebilirsiniz.',
        'lottie': 'assets/lottie/feed.json',
        'lottie2': 'assets/lottie/water.json',
      },
      {
        'title': 'Kayan Kapı',
        'desc': 'Kümes kapısının açık veya kapalı durumunu görebilirsiniz.',
        'lottie': 'assets/lottie/door.json',
      },
      {
        'title': 'Tavuk Sayısı',
        'desc':
            'Kümesinizdeki tavuk sayısını ve geçmişini takip edebilirsiniz.',
        'lottie': 'assets/lottie/chicken.json',
      },
      {
        'title': 'İstatistikler',
        'desc': 'Tüm verilerinizi grafikler halinde görüntüleyebilirsiniz.',
        'lottie': 'assets/lottie/statistics.json',
      },
      {
        'title': 'Dış Kamera',
        'desc': 'Kümesin dışını canlı olarak izleyebilirsiniz.',
        'lottie': 'assets/lottie/camera.json',
      },
      {
        'title': 'Hava Kontrolü',
        'desc':
            'Gaz sensörü ile ortam havasını ve risk seviyesini takip edebilirsiniz.',
        'lottie': 'assets/lottie/gas_sensor.json',
      },
    ];

    if (index < tutorials.length) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.scale,
        title: tutorials[index]['title'],
        desc: tutorials[index]['desc'],
        btnOkText: index == tutorials.length - 1 ? 'Tamam' : 'Sonraki',
        btnOkOnPress: () {
          if (index < tutorials.length - 1) {
            _showNextTutorialDialog(index + 1);
          } else {
            SharedPreferences.getInstance().then((prefs) {
              prefs.setBool('isFirstLaunch', false);
            });
          }
        },
        customHeader: tutorials[index]['lottie2'] != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(tutorials[index]['lottie'],
                      width: 48, height: 48),
                  SizedBox(height: 4),
                  Lottie.asset(tutorials[index]['lottie2'],
                      width: 48, height: 48),
                ],
              )
            : Lottie.asset(tutorials[index]['lottie'], width: 80, height: 80),
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final themeService = Provider.of<ThemeService>(context);
    final localizations = AppLocalizations(languageService.currentLanguage);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                "assets/images/chicken.png",
                                width: 40,
                                height: 40,
                              ),
                            ),
                            SizedBox(width: 15),
                            Text(
                              "Akıllı Kümes",
                              style: TextStyle(
                                fontFamily: "Tektur-Regular",
                                fontSize: 24,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.info_outline,
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                              onPressed: () {
                                _showTutorialDialog();
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.settings,
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                              onPressed: () {
                                Navigator.pushNamed(context, '/ayarlar');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30.0),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: cameraHeight,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: RtspStreamView(),
                                ),
                              ),
                              SizedBox(height: 24),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  localizations.get('kontrol_paneli'),
                                  style: TextStyle(
                                    fontFamily: "Tektur-Regular",
                                    fontSize: 22,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              GridView.count(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                children: [
                                  StreamBuilder<DatabaseEvent>(
                                    stream: _temperatureRef
                                        .child(_todayKey)
                                        .onValue,
                                    builder: (context, snapshot) {
                                      double sicaklik = 0.0;
                                      if (snapshot.hasData &&
                                          snapshot.data!.snapshot.value !=
                                              null) {
                                        final dataMap =
                                            Map<String, dynamic>.from(snapshot
                                                .data!.snapshot.value as Map);
                                        if (dataMap.isNotEmpty) {
                                          final sortedKeys =
                                              dataMap.keys.toList()..sort();
                                          final lastEntry =
                                              dataMap[sortedKeys.last] as Map;
                                          sicaklik =
                                              (lastEntry['temperature'] as num?)
                                                      ?.toDouble() ??
                                                  0.0;
                                        }
                                      }
                                      return _buildFeatureCard(
                                        context,
                                        "${localizations.get('sicaklik')}\n${sicaklik.toStringAsFixed(1)}°C",
                                        ['assets/lottie/thermometer.json'],
                                        Colors.orange,
                                        localizations,
                                        () async {
                                          final result =
                                              await Navigator.pushNamed(
                                                  context, '/sicaklik');
                                        },
                                      );
                                    },
                                  ),
                                  StreamBuilder<DatabaseEvent>(
                                    stream: FirebaseDatabase.instance
                                        .ref('sensor_data/$_todayKey')
                                        .onValue,
                                    builder: (context, snapshot) {
                                      double yem = 0.0;
                                      double su = 0.0;
                                      if (snapshot.hasData &&
                                          snapshot.data!.snapshot.value !=
                                              null) {
                                        final dataMap =
                                            Map<String, dynamic>.from(snapshot
                                                .data!.snapshot.value as Map);
                                        if (dataMap.isNotEmpty) {
                                          final sortedKeys =
                                              dataMap.keys.toList()..sort();
                                          final lastEntry =
                                              dataMap[sortedKeys.last] as Map;
                                          yem =
                                              (lastEntry['yemYuzdesi'] as num?)
                                                      ?.toDouble() ??
                                                  0.0;
                                          su = (lastEntry['suYuzdesi'] as num?)
                                                  ?.toDouble() ??
                                              0.0;
                                        }
                                      }
                                      return _buildFeatureCard(
                                        context,
                                        "${localizations.get('yem_su')}\nYem: %${yem.toStringAsFixed(0)} | Su: %${su.toStringAsFixed(0)}",
                                        [
                                          'assets/lottie/feed.json',
                                          'assets/lottie/water.json'
                                        ],
                                        Colors.blue,
                                        localizations,
                                        () async {
                                          final result =
                                              await Navigator.pushNamed(
                                                  context, '/yem_su');
                                          if (result == true) {
                                            await _yemSuDegerleriniYukle();
                                          }
                                        },
                                      );
                                    },
                                  ),
                                  _buildFeatureCard(
                                    context,
                                    "${localizations.get('kayan_kapi')}\n${_kapiDurumu ? 'Açık' : 'Kapalı'}",
                                    ['assets/lottie/door.json'],
                                    Colors.purple,
                                    localizations,
                                    () {
                                      _kapiDurumunuDegistir();
                                    },
                                  ),
                                  _buildFeatureCard(
                                    context,
                                    "${localizations.get('tavuk_sayisi')}\n${_tavukSayisi} adet",
                                    ['assets/lottie/chicken.json'],
                                    Colors.red,
                                    localizations,
                                    () async {
                                      final result = await Navigator.pushNamed(
                                          context, '/tavuk_sayisi');
                                      if (result == true) {
                                        await _tavukSayisiniYukle();
                                      }
                                    },
                                  ),
                                  _buildFeatureCard(
                                    context,
                                    localizations.get('istatistikler'),
                                    ['assets/lottie/statistics.json'],
                                    Colors.green,
                                    localizations,
                                    () {
                                      Navigator.pushNamed(
                                          context, '/statistics');
                                    },
                                  ),
                                  _buildFeatureCard(
                                    context,
                                    localizations.get('dis_kamera'),
                                    ['assets/lottie/camera.json'],
                                    Colors.teal,
                                    localizations,
                                    () {
                                      Navigator.pushNamed(
                                          context, '/external_camera');
                                    },
                                  ),
                                  _buildFeatureCard(
                                    context,
                                    'Hava Kontrolü',
                                    ['assets/lottie/gas_sensor.json'],
                                    Colors.brown,
                                    localizations,
                                    () async {
                                      await Navigator.pushNamed(
                                          context, '/gaz_sensoru');
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    List<String> animationPaths,
    Color color,
    AppLocalizations localizations,
    VoidCallback onTap,
  ) {
    final parts = title.split('\n');
    final baslik = parts[0];
    final deger = parts.length > 1 ? parts[1] : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: baslik == localizations.get('yem_su')
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: Lottie.asset(animationPaths[0])),
                          SizedBox(width: 4),
                          Expanded(child: Lottie.asset(animationPaths[1])),
                        ],
                      )
                    : Lottie.asset(animationPaths[0]),
              ),
              SizedBox(height: 8),
              FittedBox(
                child: Text(
                  baslik,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Tektur-Regular",
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (deger.isNotEmpty) ...[
                SizedBox(height: 4),
                FittedBox(
                  child: Text(
                    deger,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Tektur-Regular",
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

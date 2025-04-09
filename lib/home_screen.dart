import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart'; // Ekran yönü değiştirmek için gerekli
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'services/language_service.dart';
import 'sicaklik_screen.dart';
import 'yem_su_screen.dart';
import 'kayan_kapi_screen.dart';
import 'tavuk_sayisi_screen.dart';
import 'settings_screen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'screens/statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  double _sicaklik = 0.0;
  double _yemSeviyesi = 0.0;
  double _suSeviyesi = 0.0;
  int _tavukSayisi = 0;
  bool _kapiDurumu = false;

  double cameraHeight = 300;
  double _currentZoomLevel = 1.0;
  double _maxZoomLevel = 8.0;
  bool _isFullScreen = false;

  double _baseZoom = 1.0;

  bool _isLoading = true;
  int _selectedIndex = 0;
  bool _isFirstLaunch = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _sicaklikDegeriniYukle();
    _yemSuDegerleriniYukle();
    _tavukSayisiniYukle();
    _kapiDurumunuYukle();
    _loadSettings();
  }

  Future<void> _sicaklikDegeriniYukle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sicaklik = prefs.getDouble('sicaklik_degeri') ?? 0.0;
    });
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

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);

    await _cameraController.initialize();
    _maxZoomLevel = await _cameraController.getMaxZoomLevel();

    if (mounted) {
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  Future<void> _setZoomLevel(double zoom) async {
    if (_cameraController.value.isInitialized) {
      double newZoomLevel = zoom.clamp(1.0, _maxZoomLevel);
      await _cameraController.setZoomLevel(newZoomLevel);
      setState(() {
        _currentZoomLevel = newZoomLevel;
      });
    }
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
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
        'title': 'Sıcaklık Kontrolü',
        'desc':
            'Bu bölümde kümesin sıcaklığını takip edebilir ve geçmiş sıcaklık verilerini görüntüleyebilirsiniz.',
        'icon': Icons.thermostat,
        'color': Colors.orange,
      },
      {
        'title': 'Yem ve Su Seviyeleri',
        'desc':
            'Yem ve su seviyelerini buradan takip edebilir, geçmiş verileri görüntüleyebilirsiniz.',
        'icon': Icons.water_drop,
        'color': Colors.blue,
      },
      {
        'title': 'Kayan Kapı Kontrolü',
        'desc':
            'Kümes kapısını buradan kontrol edebilir, otomatik kapanma saati ayarlayabilirsiniz.',
        'icon': Icons.door_front_door,
        'color': Colors.purple,
      },
      {
        'title': 'Tavuk Sayısı',
        'desc':
            'Kümesinizdeki tavuk sayısını buradan takip edebilir, geçmiş verileri görüntüleyebilirsiniz.',
        'icon': Icons.pets,
        'color': Colors.red,
      },
      {
        'title': 'İstatistikler',
        'desc':
            'Tüm verilerinizi grafikler halinde görüntüleyebilir, detaylı analizler yapabilirsiniz.',
        'icon': Icons.bar_chart,
        'color': Colors.green,
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
        customHeader: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tutorials[index]['color'].withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            tutorials[index]['icon'],
            size: 40,
            color: tutorials[index]['color'],
          ),
        ),
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final localizations = AppLocalizations(languageService.currentLanguage);

    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _isFullScreen
                ? Stack(
                    children: [
                      _isCameraInitialized
                          ? Container(
                              width: double.infinity,
                              height: double.infinity,
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: _cameraController
                                      .value.previewSize!.width,
                                  height: _cameraController
                                      .value.previewSize!.height,
                                  child: CameraPreview(_cameraController),
                                ),
                              ),
                            )
                          : Center(
                              child: CircularProgressIndicator(),
                            ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          icon: Icon(
                            Icons.fullscreen_exit,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: _toggleFullScreen,
                        ),
                      ),
                    ],
                  )
                : SafeArea(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.info_outline,
                                        color: Colors.black87),
                                    onPressed: () {
                                      _showTutorialDialog();
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.settings,
                                        color: Colors.black87),
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
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: cameraHeight,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.surface,
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
                                      child: Stack(
                                        children: [
                                          _isCameraInitialized
                                              ? Container(
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  child: FittedBox(
                                                    fit: BoxFit.cover,
                                                    child: SizedBox(
                                                      width: _cameraController
                                                          .value
                                                          .previewSize!
                                                          .width,
                                                      height: _cameraController
                                                          .value
                                                          .previewSize!
                                                          .height,
                                                      child: CameraPreview(
                                                          _cameraController),
                                                    ),
                                                  ),
                                                )
                                              : Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.fullscreen,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                              onPressed: _toggleFullScreen,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    localizations.get('kontrol_paneli'),
                                    style: TextStyle(
                                      fontFamily: "Tektur-Regular",
                                      fontSize: 20,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  GridView.count(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    children: [
                                      _buildFeatureCard(
                                        context,
                                        "${localizations.get('sicaklik')}\n${_sicaklik.toStringAsFixed(1)}°C",
                                        Icons.thermostat,
                                        Colors.orange,
                                        localizations,
                                        () async {
                                          final result =
                                              await Navigator.pushNamed(
                                                  context, '/sicaklik');
                                          if (result == true) {
                                            await _sicaklikDegeriniYukle();
                                          }
                                        },
                                      ),
                                      _buildFeatureCard(
                                        context,
                                        "${localizations.get('yem_su')}\nYem: %${_yemSeviyesi.toStringAsFixed(0)} | Su: %${_suSeviyesi.toStringAsFixed(0)}",
                                        Icons.food_bank,
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
                                      ),
                                      _buildFeatureCard(
                                        context,
                                        "${localizations.get('kayan_kapi')}\n${_kapiDurumu ? 'Açık' : 'Kapalı'}",
                                        Icons.door_front_door,
                                        Colors.purple,
                                        localizations,
                                        () async {
                                          final result =
                                              await Navigator.pushNamed(
                                                  context, '/kayan_kapi');
                                          if (result == true) {
                                            await _kapiDurumunuYukle();
                                          }
                                        },
                                      ),
                                      _buildFeatureCard(
                                        context,
                                        "${localizations.get('tavuk_sayisi')}\n${_tavukSayisi} adet",
                                        Icons.pets,
                                        Colors.red,
                                        localizations,
                                        () async {
                                          final result =
                                              await Navigator.pushNamed(
                                                  context, '/tavuk_sayisi');
                                          if (result == true) {
                                            await _tavukSayisiniYukle();
                                          }
                                        },
                                      ),
                                      _buildFeatureCard(
                                        context,
                                        localizations.get('istatistikler'),
                                        Icons.bar_chart,
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
                                        Icons.camera_outdoor,
                                        Colors.teal,
                                        localizations,
                                        () {
                                          Navigator.pushNamed(
                                              context, '/external_camera');
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (baslik == localizations.get('yem_su'))
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child:
                        Icon(Icons.food_bank, size: 30, color: Colors.orange),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.water_drop, size: 30, color: Colors.blue),
                  ),
                ],
              )
            else
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: color),
              ),
            SizedBox(height: 8),
            Text(
              baslik,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Tektur-Regular",
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (deger.isNotEmpty) ...[
              SizedBox(height: 4),
              Text(
                deger,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Tektur-Regular",
                  fontSize: 14,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

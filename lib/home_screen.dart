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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  double _sicaklik = 25.0;
  double _yemSeviyesi = 75.0;
  double _suSeviyesi = 80.0;
  int _tavukSayisi = 10;
  bool _kapiDurumu = false;

  double cameraHeight = 300;
  double _currentZoomLevel = 1.0;
  double _maxZoomLevel = 8.0;
  bool _isFullScreen = false;

  double _baseZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _sicaklikDegeriniYukle();
    _yemSuDegerleriniYukle();
    _tavukSayisiniYukle();
    _kapiDurumunuYukle();
  }

  Future<void> _sicaklikDegeriniYukle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sicaklik = prefs.getDouble('sicaklik_degeri') ?? 25.0;
    });
  }

  Future<void> _yemSuDegerleriniYukle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _yemSeviyesi = prefs.getDouble('yem_seviyesi') ?? 75.0;
      _suSeviyesi = prefs.getDouble('su_seviyesi') ?? 80.0;
    });
  }

  Future<void> _tavukSayisiniYukle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tavukSayisi = prefs.getInt('tavuk_sayisi') ?? 10;
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

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final localizations = AppLocalizations(languageService.currentLanguage);

    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _isFullScreen
            ? Stack(
                children: [
                  _isCameraInitialized
                      ? Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _cameraController.value.previewSize!.width,
                              height:
                                  _cameraController.value.previewSize!.height,
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                          IconButton(
                            icon: Icon(Icons.settings, color: Colors.black87),
                            onPressed: () {
                              Navigator.pushNamed(context, '/ayarlar');
                            },
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
                                                      .value.previewSize!.width,
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
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
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
                                    () async {
                                      final result = await Navigator.pushNamed(
                                          context, '/sicaklik');
                                      if (result == true) {
                                        await _sicaklikDegeriniYukle();
                                      }
                                    },
                                  ),
                                  _buildFeatureCard(
                                    context,
                                    "${localizations.get('yem_su')}\n${_yemSeviyesi.toStringAsFixed(0)}% / ${_suSeviyesi.toStringAsFixed(0)}%",
                                    Icons.water_drop,
                                    Colors.blue,
                                    () async {
                                      final result = await Navigator.pushNamed(
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
                                    () async {
                                      final result = await Navigator.pushNamed(
                                          context, '/kayan_kapi');
                                      if (result == true) {
                                        await _kapiDurumunuYukle();
                                      }
                                    },
                                  ),
                                  _buildFeatureCard(
                                    context,
                                    "${localizations.get('tavuk_sayisi')}\n${_tavukSayisi}",
                                    Icons.pets,
                                    Colors.red,
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
                                    Icons.bar_chart,
                                    Colors.green,
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

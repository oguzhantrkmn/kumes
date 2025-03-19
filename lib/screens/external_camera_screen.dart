import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';

class ExternalCameraScreen extends StatefulWidget {
  @override
  _ExternalCameraScreenState createState() => _ExternalCameraScreenState();
}

class _ExternalCameraScreenState extends State<ExternalCameraScreen> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool _isFullScreen = true;
  double _currentZoomLevel = 1.0;
  double _baseZoom = 1.0;
  double _maxZoomLevel = 8.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
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
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_isCameraInitialized)
            GestureDetector(
              onScaleStart: (ScaleStartDetails details) {
                _baseZoom = _currentZoomLevel;
              },
              onScaleUpdate: (ScaleUpdateDetails details) {
                double newZoom = _baseZoom * details.scale;
                _setZoomLevel(newZoom);
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: CameraPreview(_cameraController),
              ),
            )
          else
            Center(child: CircularProgressIndicator()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    localizations.get('dis_kamera'),
                    style: TextStyle(
                      fontFamily: "Tektur-Regular",
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: _toggleFullScreen,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

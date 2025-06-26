import 'package:flutter/material.dart';
import 'package:kumes/widgets/rtsp_stream_view.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';

class ExternalCameraScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final localizations = AppLocalizations(languageService.currentLanguage);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Kamera görüntüsü tam ekran, döndürülmüş ve siyah boşluksuz
          Positioned.fill(
            child: Transform.rotate(
              angle: 1.5708, // 90 derece sağa (radyan)
              child: OverflowBox(
                alignment: Alignment.center,
                minWidth: screenSize.height * 1.5,
                maxWidth: screenSize.height * 1.8,
                minHeight: screenSize.width * 1.5,
                maxHeight: screenSize.width * 1.8,
                child: RtspStreamView(url: 'rtsp://172.20.10.3:8554/unicast'),
              ),
            ),
          ),
          // Sol üstte geri butonu
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

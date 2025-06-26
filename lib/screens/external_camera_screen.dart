import 'package:flutter/material.dart';
import 'package:kumes/widgets/rtsp_stream_view.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';

class ExternalCameraScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final localizations = AppLocalizations(languageService.currentLanguage);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Kamera görüntüsü tam ekran ve döndürülmüş şekilde
          Positioned.fill(
            child: RotatedBox(
              quarterTurns: 5, // Sağa 90 derece döndür
              child: RtspStreamView(url: 'http://192.168.0.32:8082'),
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

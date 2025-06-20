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
      appBar: AppBar(
        title: Text(localizations.get('dis_kamera')),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: const Center(
        child: RtspStreamView(),
      ),
    );
  }
}

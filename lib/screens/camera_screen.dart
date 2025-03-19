import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/camera_service.dart';
import '../services/language_service.dart';

class CameraScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cameraService = Provider.of<CameraService>(context);
    final languageService = Provider.of<LanguageService>(context);
    final localizations = AppLocalizations(languageService.currentLanguage);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kamera Kontrol',
          style: TextStyle(
            fontFamily: "Tektur-Regular",
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              cameraService.isNightVisionEnabled
                  ? Icons.nightlight_round
                  : Icons.wb_sunny,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => cameraService.toggleNightVision(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Canlı Kamera Görüntüsü (Placeholder)
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child:
                        Icon(Icons.videocam, size: 50, color: Colors.white54),
                  ),
                ),
                SizedBox(height: 20),

                // Hayvan Sayısı
                _buildInfoCard(
                  context,
                  'Mevcut Hayvan Sayısı',
                  '${cameraService.currentAnimalCount}',
                  Icons.pets,
                  Colors.blue,
                ),
                SizedBox(height: 20),

                // Son Yabancı Hayvan Tespiti
                if (cameraService.lastUnknownAnimalDetection != null)
                  _buildInfoCard(
                    context,
                    'Son Yabancı Hayvan Tespiti',
                    '${cameraService.lastUnknownAnimalDetection!.toString().split('.')[0]}',
                    Icons.warning,
                    Colors.orange,
                  ),
                SizedBox(height: 20),

                // Hareket Algılama Switchi
                _buildSettingCard(
                  context,
                  'Hareket Algılama',
                  Icons.motion_photos_on,
                  Colors.purple,
                  Switch(
                    value: cameraService.isMotionDetectionEnabled,
                    onChanged: (value) => cameraService.toggleMotionDetection(),
                    activeColor: Colors.purple,
                  ),
                ),
                SizedBox(height: 20),

                // Alarm Geçmişi
                if (cameraService.alarmHistory.isNotEmpty) ...[
                  Text(
                    'Alarm Geçmişi',
                    style: TextStyle(
                      fontFamily: "Tektur-Regular",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
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
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: cameraService.alarmHistory.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            cameraService.alarmHistory[index],
                            style: TextStyle(
                              fontFamily: "Tektur-Regular",
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          leading: Icon(Icons.notification_important,
                              color: Colors.red),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => cameraService.clearAlarmHistory(),
                    icon: Icon(Icons.delete),
                    label: Text('Geçmişi Temizle'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: "Tektur-Regular",
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: "Tektur-Regular",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget child,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              SizedBox(width: 15),
              Text(
                title,
                style: TextStyle(
                  fontFamily: "Tektur-Regular",
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

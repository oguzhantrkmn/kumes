import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'services/language_service.dart';
import 'services/theme_service.dart';
import 'services/app_localizations.dart' as app;
import 'package:url_launcher/url_launcher_string.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _bildirimler = true;
  final String _phoneNumber = "+905426229055";

  @override
  void initState() {
    super.initState();
    _ayarlariYukle();
  }

  Future<void> _ayarlariYukle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bildirimler = prefs.getBool('bildirimler') ?? true;
    });
  }

  Future<void> _bildirimDegistir(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bildirimler', value);
    setState(() {
      _bildirimler = value;
    });
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final message =
        "Merhaba, Akıllı Kümes uygulaması hakkında destek almak istiyorum.";
    final url =
        "https://wa.me/$_phoneNumber/?text=${Uri.encodeComponent(message)}";

    try {
      await launchUrlString(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('WhatsApp açılamadı'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final themeService = Provider.of<ThemeService>(context);
    final localizations = app.AppLocalizations(languageService.currentLanguage);

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
          localizations.get('ayarlar'),
          style: TextStyle(
            fontFamily: "Tektur-Regular",
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                _buildSettingCard(
                  context,
                  localizations.get('bildirimler'),
                  Icons.notifications,
                  Colors.orange,
                  child: Switch(
                    value: _bildirimler,
                    onChanged: _bildirimDegistir,
                    activeColor: Colors.orange,
                  ),
                  subtitle: localizations.get('bildirimler_aciklama'),
                ),
                SizedBox(height: 20),
                _buildSettingCard(
                  context,
                  localizations.get('karanlik_mod'),
                  Icons.dark_mode,
                  Colors.purple,
                  child: Switch(
                    value: themeService.isDarkMode,
                    onChanged: (value) {
                      themeService.toggleTheme();
                    },
                    activeColor: Colors.purple,
                  ),
                  subtitle: localizations.get('karanlik_mod_aciklama'),
                ),
                SizedBox(height: 20),
                _buildSettingCard(
                  context,
                  localizations.get('canli_destek'),
                  Icons.support_agent,
                  Colors.green,
                  child: IconButton(
                    icon: Icon(
                      Icons.message,
                      color: Colors.green,
                      size: 30,
                    ),
                    onPressed: () => _openWhatsApp(context),
                  ),
                  subtitle: localizations.get('canli_destek_aciklama'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color, {
    required Widget child,
    String? subtitle,
  }) {
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
      child: Column(
        children: [
          Row(
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
          if (subtitle != null) ...[
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: "Tektur-Regular",
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

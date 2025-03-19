import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/language_service.dart';

class KayanKapiScreen extends StatefulWidget {
  @override
  _KayanKapiScreenState createState() => _KayanKapiScreenState();
}

class _KayanKapiScreenState extends State<KayanKapiScreen> {
  bool _isLoading = true;
  bool _kapiDurumu = false;

  @override
  void initState() {
    super.initState();
    _loadKapiDurumu();
  }

  Future<void> _loadKapiDurumu() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _kapiDurumu = prefs.getBool('kapi_durumu') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _toggleKapiDurumu() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final yeniDurum = !_kapiDurumu;
    await prefs.setBool('kapi_durumu', yeniDurum);

    setState(() {
      _kapiDurumu = yeniDurum;
      _isLoading = false;
    });

    // Ana ekranı güncellemek için true değerini döndür
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final localizations = AppLocalizations(languageService.currentLanguage);

    return WillPopScope(
      onWillPop: () async {
        // Geri tuşuna basıldığında da ana ekranı güncelle
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            localizations.get('kapi_kontrol'),
            style: TextStyle(fontFamily: "Tektur-Regular"),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.door_front_door,
                            size: 80,
                            color: _kapiDurumu ? Colors.green : Colors.red,
                          ),
                          SizedBox(height: 20),
                          Text(
                            localizations.get('kapi_durumu'),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Tektur-Regular",
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _kapiDurumu
                                ? localizations.get('acik')
                                : localizations.get('kapali'),
                            style: TextStyle(
                              fontSize: 20,
                              color: _kapiDurumu ? Colors.green : Colors.red,
                              fontFamily: "Tektur-Regular",
                            ),
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _toggleKapiDurumu,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor:
                                  _kapiDurumu ? Colors.red : Colors.green,
                            ),
                            child: Text(
                              _kapiDurumu ? 'Kapıyı Kapat' : 'Kapıyı Aç',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: "Tektur-Regular",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

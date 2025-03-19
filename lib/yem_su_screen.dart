import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/language_service.dart';

class YemSuScreen extends StatefulWidget {
  @override
  _YemSuScreenState createState() => _YemSuScreenState();
}

class _YemSuScreenState extends State<YemSuScreen> {
  bool _isLoading = true;
  double _yemSeviyesi = 100.0;
  double _suSeviyesi = 100.0;

  @override
  void initState() {
    super.initState();
    _loadValues();
  }

  Future<void> _loadValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _yemSeviyesi = prefs.getDouble('yem_seviyesi') ?? 100.0;
      _suSeviyesi = prefs.getDouble('su_seviyesi') ?? 100.0;
      _isLoading = false;
    });
  }

  Future<void> _saveValues() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('yem_seviyesi', _yemSeviyesi);
    await prefs.setDouble('su_seviyesi', _suSeviyesi);
    setState(() => _isLoading = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final localizations = AppLocalizations(languageService.currentLanguage);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            localizations.get('yem_su_kontrol'),
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
                          // Yem Kontrolü
                          Icon(
                            Icons.food_bank,
                            size: 60,
                            color: Colors.orange,
                          ),
                          SizedBox(height: 10),
                          Text(
                            localizations.get('yem_seviyesi'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Tektur-Regular",
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '${_yemSeviyesi.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.orange,
                              fontFamily: "Tektur-Regular",
                            ),
                          ),
                          Slider(
                            value: _yemSeviyesi,
                            min: 0,
                            max: 100,
                            divisions: 100,
                            activeColor: Colors.orange,
                            onChanged: (value) {
                              setState(() {
                                _yemSeviyesi = value;
                              });
                            },
                          ),
                          SizedBox(height: 30),
                          // Su Kontrolü
                          Icon(
                            Icons.water_drop,
                            size: 60,
                            color: Colors.blue,
                          ),
                          SizedBox(height: 10),
                          Text(
                            localizations.get('su_seviyesi'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Tektur-Regular",
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '${_suSeviyesi.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.blue,
                              fontFamily: "Tektur-Regular",
                            ),
                          ),
                          Slider(
                            value: _suSeviyesi,
                            min: 0,
                            max: 100,
                            divisions: 100,
                            activeColor: Colors.blue,
                            onChanged: (value) {
                              setState(() {
                                _suSeviyesi = value;
                              });
                            },
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _saveValues,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: Colors.blue,
                            ),
                            child: Text(
                              localizations.get('kaydet'),
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

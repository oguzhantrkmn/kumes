import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/language_service.dart';

class SicaklikScreen extends StatefulWidget {
  @override
  _SicaklikScreenState createState() => _SicaklikScreenState();
}

class _SicaklikScreenState extends State<SicaklikScreen> {
  bool _isLoading = true;
  double _sicaklik = 25.0;

  @override
  void initState() {
    super.initState();
    _loadSicaklik();
  }

  Future<void> _loadSicaklik() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sicaklik = prefs.getDouble('sicaklik_degeri') ?? 25.0;
      _isLoading = false;
    });
  }

  Future<void> _saveSicaklik() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sicaklik_degeri', _sicaklik);
    setState(() => _isLoading = false);
    Navigator.pop(context, true);
  }

  void _increaseSicaklik() {
    if (_sicaklik < 40.0) {
      setState(() {
        _sicaklik += 0.5;
      });
    }
  }

  void _decreaseSicaklik() {
    if (_sicaklik > 10.0) {
      setState(() {
        _sicaklik -= 0.5;
      });
    }
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
            localizations.get('sicaklik_kontrol'),
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
                            Icons.thermostat,
                            size: 80,
                            color: Colors.orange,
                          ),
                          SizedBox(height: 20),
                          Text(
                            '${_sicaklik.toStringAsFixed(1)}°C',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Tektur-Regular",
                              color: Colors.orange,
                            ),
                          ),
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _decreaseSicaklik,
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(20),
                                  backgroundColor: Colors.red,
                                ),
                                child: Icon(Icons.remove, color: Colors.white),
                              ),
                              SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: _increaseSicaklik,
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(20),
                                  backgroundColor: Colors.green,
                                ),
                                child: Icon(Icons.add, color: Colors.white),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _saveSicaklik,
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

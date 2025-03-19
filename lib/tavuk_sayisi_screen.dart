import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/language_service.dart';

class TavukSayisiScreen extends StatefulWidget {
  @override
  _TavukSayisiScreenState createState() => _TavukSayisiScreenState();
}

class _TavukSayisiScreenState extends State<TavukSayisiScreen> {
  bool _isLoading = true;
  int _tavukSayisi = 10;

  @override
  void initState() {
    super.initState();
    _loadTavukSayisi();
  }

  Future<void> _loadTavukSayisi() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tavukSayisi = prefs.getInt('tavuk_sayisi') ?? 10;
      _isLoading = false;
    });
  }

  Future<void> _saveTavukSayisi() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tavuk_sayisi', _tavukSayisi);
    setState(() => _isLoading = false);
    Navigator.pop(context, true);
  }

  void _increaseTavukSayisi() {
    if (_tavukSayisi < 100) {
      setState(() {
        _tavukSayisi++;
      });
    }
  }

  void _decreaseTavukSayisi() {
    if (_tavukSayisi > 0) {
      setState(() {
        _tavukSayisi--;
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
            localizations.get('tavuk_sayisi_kontrol'),
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
                            Icons.pets,
                            size: 80,
                            color: Colors.brown,
                          ),
                          SizedBox(height: 20),
                          Text(
                            '$_tavukSayisi',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Tektur-Regular",
                              color: Colors.brown,
                            ),
                          ),
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _decreaseTavukSayisi,
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(20),
                                  backgroundColor: Colors.red,
                                ),
                                child: Icon(Icons.remove, color: Colors.white),
                              ),
                              SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: _increaseTavukSayisi,
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
                            onPressed: _saveTavukSayisi,
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

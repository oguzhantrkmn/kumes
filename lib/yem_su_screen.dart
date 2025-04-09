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
  final List<Map<String, dynamic>> _yemGecmisi = [];
  final List<Map<String, dynamic>> _suGecmisi = [];

  @override
  void initState() {
    super.initState();
    _loadValues();
    _gecmisVerileriniOlustur();
  }

  void _gecmisVerileriniOlustur() {
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      _yemGecmisi.add(
          {'tarih': '${date.day}.${date.month}.${date.year}', 'deger': 0.0});
      _suGecmisi.add(
          {'tarih': '${date.day}.${date.month}.${date.year}', 'deger': 0.0});
    }
  }

  Future<void> _loadValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _yemSeviyesi = 0.0;
      _suSeviyesi = 0.0;
      _isLoading = false;
    });
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
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ana Göstergeler
                    Row(
                      children: [
                        Expanded(
                          child: _buildSeviyeGostergesi(
                            context,
                            localizations.get('yem_seviyesi'),
                            _yemSeviyesi,
                            Icons.food_bank,
                            Colors.orange,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildSeviyeGostergesi(
                            context,
                            localizations.get('su_seviyesi'),
                            _suSeviyesi,
                            Icons.water_drop,
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Yem Geçmişi
                    _buildGecmisKarti(
                      context,
                      localizations.get('yem_seviyesi'),
                      _yemGecmisi,
                      Colors.orange,
                    ),
                    SizedBox(height: 20),

                    // Su Geçmişi
                    _buildGecmisKarti(
                      context,
                      localizations.get('su_seviyesi'),
                      _suGecmisi,
                      Colors.blue,
                    ),
                    SizedBox(height: 20),

                    // İstatistikler
                    Container(
                      padding: EdgeInsets.all(16),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'İstatistikler',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Tektur-Regular",
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildIstatistikKarti(
                                'Ortalama Yem',
                                '0%',
                                Icons.food_bank,
                                Colors.orange,
                              ),
                              _buildIstatistikKarti(
                                'Ortalama Su',
                                '0%',
                                Icons.water_drop,
                                Colors.blue,
                              ),
                            ],
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

  Widget _buildSeviyeGostergesi(
    BuildContext context,
    String title,
    double value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
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
          Icon(icon, size: 40, color: color),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontFamily: "Tektur-Regular",
            ),
          ),
          SizedBox(height: 5),
          Text(
            '${value.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: "Tektur-Regular",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGecmisKarti(
    BuildContext context,
    String title,
    List<Map<String, dynamic>> gecmis,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title Geçmişi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: "Tektur-Regular",
            ),
          ),
          SizedBox(height: 10),
          ...gecmis.map((veri) => ListTile(
                leading: Icon(Icons.history, color: color),
                title: Text(
                  '${veri['tarih']}',
                  style: TextStyle(fontFamily: "Tektur-Regular"),
                ),
                trailing: Text(
                  '${veri['deger']}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Tektur-Regular",
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildIstatistikKarti(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontFamily: "Tektur-Regular",
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: "Tektur-Regular",
          ),
        ),
      ],
    );
  }
}

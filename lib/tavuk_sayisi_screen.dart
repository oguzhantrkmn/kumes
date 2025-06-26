import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/language_service.dart';
import 'package:lottie/lottie.dart';

class TavukSayisiScreen extends StatefulWidget {
  @override
  _TavukSayisiScreenState createState() => _TavukSayisiScreenState();
}

class _TavukSayisiScreenState extends State<TavukSayisiScreen> {
  bool _isLoading = true;
  int _tavukSayisi = 0;
  final List<Map<String, dynamic>> _tavukGecmisi = [];

  @override
  void initState() {
    super.initState();
    _loadTavukSayisi();
    _tavukGecmisiniOlustur();
  }

  void _tavukGecmisiniOlustur() {
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      _tavukGecmisi.add({
        'tarih': '${date.day}.${date.month}.${date.year}',
        'sayi': 0,
      });
    }
  }

  Future<void> _loadTavukSayisi() async {
    setState(() {
      _tavukSayisi = 0;
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
            localizations.get('tavuk_sayisi'),
            style: TextStyle(fontFamily: "Tektur-Regular"),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/lottie/chicken.json',
                      width: 120,
                      height: 120,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Yükleniyor...',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "Tektur-Regular",
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Ana Tavuk Sayısı Gösterimi
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
                            color: Colors.orange,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Mevcut Tavuk Sayısı',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Tektur-Regular",
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '0',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                              fontFamily: "Tektur-Regular",
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'adet',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey[600],
                              fontFamily: "Tektur-Regular",
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Tavuk Geçmişi
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
                            'Tavuk Sayısı Geçmişi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Tektur-Regular",
                            ),
                          ),
                          SizedBox(height: 10),
                          ..._tavukGecmisi.map((veri) => ListTile(
                                leading: Icon(
                                  Icons.history,
                                  color: Colors.orange,
                                ),
                                title: Text(
                                  '${veri['tarih']}',
                                  style:
                                      TextStyle(fontFamily: "Tektur-Regular"),
                                ),
                                trailing: Text(
                                  '0 adet',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Tektur-Regular",
                                  ),
                                ),
                              )),
                        ],
                      ),
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
                                'Ortalama',
                                '0 adet',
                                Icons.calculate,
                                Colors.orange,
                              ),
                              _buildIstatistikKarti(
                                'En Yüksek',
                                '0 adet',
                                Icons.trending_up,
                                Colors.green,
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildIstatistikKarti(
                                'En Düşük',
                                '0 adet',
                                Icons.trending_down,
                                Colors.red,
                              ),
                              _buildIstatistikKarti(
                                'Değişim',
                                '0%',
                                Icons.compare_arrows,
                                Colors.blue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Tavuk Sağlığı İpuçları
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
                            'Tavuk Sağlığı İpuçları',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Tektur-Regular",
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildIpuclariKarti(
                            'Kümes Sıcaklığı',
                            'Tavuklar için ideal sıcaklık 18-22°C arasındadır.',
                            Icons.thermostat,
                          ),
                          SizedBox(height: 10),
                          _buildIpuclariKarti(
                            'Yem Tüketimi',
                            'Her tavuk günde ortalama 120-150 gram yem tüketir.',
                            Icons.food_bank,
                          ),
                          SizedBox(height: 10),
                          _buildIpuclariKarti(
                            'Su Tüketimi',
                            'Her tavuk günde 200-300 ml su tüketir.',
                            Icons.water_drop,
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

  Widget _buildIpuclariKarti(
    String title,
    String description,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: "Tektur-Regular",
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: "Tektur-Regular",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

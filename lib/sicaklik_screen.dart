import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'services/language_service.dart';

class SicaklikScreen extends StatefulWidget {
  @override
  _SicaklikScreenState createState() => _SicaklikScreenState();
}

class _SicaklikScreenState extends State<SicaklikScreen> {
  bool _isLoading = true;
  double _sicaklik = 0.0;
  List<Map<String, dynamic>> _sicaklikGecmisi = [];

  @override
  void initState() {
    super.initState();
    _loadSicaklik();
  }

  Future<void> _loadSicaklik() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sicaklik = 0.0;
      _sicaklikGecmisiniYukle(prefs);
      _isLoading = false;
    });
  }

  Future<void> _sicaklikGecmisiniYukle(SharedPreferences prefs) async {
    final now = DateTime.now();
    _sicaklikGecmisi = List.generate(7, (index) {
      final date = now.subtract(Duration(days: index));
      return {'tarih': '${date.day}.${date.month}.${date.year}', 'deger': 0.0};
    });
  }

  Future<void> _saveSicaklik() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sicaklik_degeri', 0.0);

    // Güncel sıcaklığı bugünün tarihine kaydet
    final now = DateTime.now();
    final todayKey = 'sicaklik_${now.day}_${now.month}_${now.year}';
    await prefs.setDouble(todayKey, 0.0);

    // Geçmiş verileri güncelle
    await _sicaklikGecmisiniYukle(prefs);

    setState(() => _isLoading = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final localizations = AppLocalizations(languageService.currentLanguage);

    return WillPopScope(
      onWillPop: () async {
        await _saveSicaklik();
        return true;
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
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ana Sıcaklık Göstergesi
                    Container(
                      width: double.infinity,
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
                          SizedBox(height: 10),
                          Text(
                            'Güncel Sıcaklık',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontFamily: "Tektur-Regular",
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Sıcaklık Grafiği
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
                            'Sıcaklık Grafiği',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Tektur-Regular",
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          '${value.toInt()}°C',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                            fontFamily: "Tektur-Regular",
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() >= 0 &&
                                            value.toInt() <
                                                _sicaklikGecmisi.length) {
                                          final date =
                                              _sicaklikGecmisi[value.toInt()]
                                                      ['tarih']
                                                  .toString()
                                                  .split('.');
                                          return Text(
                                            '${date[0]}.${date[1]}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                              fontFamily: "Tektur-Regular",
                                            ),
                                          );
                                        }
                                        return Text('');
                                      },
                                    ),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: List.generate(
                                      _sicaklikGecmisi.length,
                                      (index) => FlSpot(
                                        index.toDouble(),
                                        _sicaklikGecmisi[index]['deger'],
                                      ),
                                    ),
                                    isCurved: true,
                                    color: Colors.orange,
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(show: true),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Colors.orange.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                                minY: 0,
                                maxY: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Sıcaklık Geçmişi
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
                            'Sıcaklık Geçmişi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Tektur-Regular",
                            ),
                          ),
                          SizedBox(height: 10),
                          ..._sicaklikGecmisi.map((veri) => ListTile(
                                leading:
                                    Icon(Icons.history, color: Colors.orange),
                                title: Text(
                                  '${veri['tarih']}',
                                  style:
                                      TextStyle(fontFamily: "Tektur-Regular"),
                                ),
                                trailing: Text(
                                  '${veri['deger']}°C',
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

                    // Sıcaklık İstatistikleri
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
                            'Sıcaklık İstatistikleri',
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
                              _buildStatCard(
                                  'En Yüksek', '0°C', Icons.arrow_upward),
                              _buildStatCard(
                                  'En Düşük', '0°C', Icons.arrow_downward),
                              _buildStatCard(
                                  'Ortalama', '0°C', Icons.trending_flat),
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

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.orange, size: 30),
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
            color: Colors.orange,
            fontFamily: "Tektur-Regular",
          ),
        ),
      ],
    );
  }
}

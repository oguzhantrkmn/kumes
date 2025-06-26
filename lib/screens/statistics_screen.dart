import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/statistics_service.dart';
import '../services/language_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  late DatabaseReference _temperatureRef;
  Map<String, List<double>> _gunlukSicaklik = {};
  Map<String, List<double>> _gunlukYem = {};
  Map<String, List<double>> _gunlukSu = {};
  Map<String, List<double>> _gunlukGaz = {};
  List<String> _son7Gun = [];
  bool _loading = true;
  String _todayKey = '';

  @override
  void initState() {
    super.initState();
    _temperatureRef = FirebaseDatabase.instance.ref('sensor_data');
    _olusturSon7Gun();
    final now = DateTime.now();
    _todayKey =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    _verileriYukle();
  }

  void _olusturSon7Gun() {
    final now = DateTime.now();
    _son7Gun = List.generate(7, (i) {
      final date = now.subtract(Duration(days: i));
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    }).reversed.toList();
  }

  Future<void> _verileriYukle() async {
    Map<String, List<double>> gunlukSicaklik = {};
    Map<String, List<double>> gunlukYem = {};
    Map<String, List<double>> gunlukSu = {};
    Map<String, List<double>> gunlukGaz = {};

    for (String gun in _son7Gun) {
      final snap = await _temperatureRef.child(gun).get();
      if (snap.exists) {
        List<double> sicakliklar = [];
        List<double> yemler = [];
        List<double> sular = [];
        List<double> gazlar = [];

        for (final child in snap.children) {
          final data = child.value as Map?;
          if (data != null) {
            if (data['temperature'] != null) {
              sicakliklar.add((data['temperature'] as num).toDouble());
            }
            if (data['yemYuzdesi'] != null) {
              yemler.add((data['yemYuzdesi'] as num).toDouble());
            }
            if (data['suYuzdesi'] != null) {
              sular.add((data['suYuzdesi'] as num).toDouble());
            }
            if (data['gazSeviyesi'] != null) {
              gazlar.add((data['gazSeviyesi'] as num).toDouble());
            }
          }
        }
        gunlukSicaklik[gun] = sicakliklar;
        gunlukYem[gun] = yemler;
        gunlukSu[gun] = sular;
        gunlukGaz[gun] = gazlar;
      } else {
        gunlukSicaklik[gun] = [];
        gunlukYem[gun] = [];
        gunlukSu[gun] = [];
        gunlukGaz[gun] = [];
      }
    }

    setState(() {
      _gunlukSicaklik = gunlukSicaklik;
      _gunlukYem = gunlukYem;
      _gunlukSu = gunlukSu;
      _gunlukGaz = gunlukGaz;
      _loading = false;
    });
  }

  List<double> _gunlukSicaklikOrtalamalar() {
    return _son7Gun.map((gun) {
      final veriler = _gunlukSicaklik[gun] ?? [];
      if (veriler.isEmpty) return 0.0;
      return veriler.reduce((a, b) => a + b) / veriler.length;
    }).toList();
  }

  List<double> _gunlukYemOrtalamalar() {
    return _son7Gun.map((gun) {
      final veriler = _gunlukYem[gun] ?? [];
      if (veriler.isEmpty) return 0.0;
      return veriler.reduce((a, b) => a + b) / veriler.length;
    }).toList();
  }

  List<double> _gunlukSuOrtalamalar() {
    return _son7Gun.map((gun) {
      final veriler = _gunlukSu[gun] ?? [];
      if (veriler.isEmpty) return 0.0;
      return veriler.reduce((a, b) => a + b) / veriler.length;
    }).toList();
  }

  List<double> _gunlukGazOrtalamalar() {
    return _son7Gun.map((gun) {
      final veriler = _gunlukGaz[gun] ?? [];
      if (veriler.isEmpty) return 0.0;
      return veriler.reduce((a, b) => a + b) / veriler.length;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final statisticsService = Provider.of<StatisticsService>(context);
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
          localizations.get('istatistikler'),
          style: TextStyle(
            fontFamily: "Tektur-Regular",
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Container(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sıcaklık Grafiği
                      _buildSectionTitle('Sıcaklık İstatistikleri'),
                      Container(
                        height: 250,
                        decoration: _buildCardDecoration(context),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Son 7 Günlük Sıcaklık Grafiği',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Tektur-Regular",
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: 10),
                              Expanded(
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
                                                    _son7Gun.length) {
                                              final date =
                                                  _son7Gun[value.toInt()]
                                                      .split('-');
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
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      topTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: List.generate(
                                          _gunlukSicaklikOrtalamalar().length,
                                          (index) => FlSpot(
                                              index.toDouble(),
                                              _gunlukSicaklikOrtalamalar()[
                                                  index]),
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
                      ),
                      SizedBox(height: 20),

                      // Yem & Su Grafiği
                      _buildSectionTitle('Yem & Su İstatistikleri'),
                      Container(
                        height: 250,
                        decoration: _buildCardDecoration(context),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Son 7 Günlük Yem & Su Seviyesi',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Tektur-Regular",
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: 10),
                              Expanded(
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
                                              '%${value.toInt()}',
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
                                                    _son7Gun.length) {
                                              final date =
                                                  _son7Gun[value.toInt()]
                                                      .split('-');
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
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      topTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: List.generate(
                                          _gunlukYemOrtalamalar().length,
                                          (index) => FlSpot(index.toDouble(),
                                              _gunlukYemOrtalamalar()[index]),
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
                                      LineChartBarData(
                                        spots: List.generate(
                                          _gunlukSuOrtalamalar().length,
                                          (index) => FlSpot(index.toDouble(),
                                              _gunlukSuOrtalamalar()[index]),
                                        ),
                                        isCurved: true,
                                        color: Colors.blue,
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(show: true),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: Colors.blue.withOpacity(0.1),
                                        ),
                                      ),
                                    ],
                                    minY: 0,
                                    maxY: 100,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Hava Kontrol Grafiği
                      _buildSectionTitle('Hava Kontrol İstatistikleri'),
                      Container(
                        height: 250,
                        decoration: _buildCardDecoration(context),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Son 7 Günlük Gaz Seviyesi',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Tektur-Regular",
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: 10),
                              Expanded(
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(show: false),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 40,
                                          interval: 300,
                                          getTitlesWidget: (value, meta) {
                                            if (value % 300 == 0) {
                                              return Text(
                                                '${value.toInt()} ppm',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                  fontFamily: "Tektur-Regular",
                                                ),
                                              );
                                            }
                                            return Container();
                                          },
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            if (value.toInt() >= 0 &&
                                                value.toInt() <
                                                    _son7Gun.length) {
                                              final date =
                                                  _son7Gun[value.toInt()]
                                                      .split('-');
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
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      topTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: List.generate(
                                          _gunlukGazOrtalamalar().length,
                                          (index) => FlSpot(index.toDouble(),
                                              _gunlukGazOrtalamalar()[index]),
                                        ),
                                        isCurved: true,
                                        color: Colors.brown,
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(show: true),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: Colors.brown.withOpacity(0.1),
                                        ),
                                      ),
                                    ],
                                    minY: 0,
                                    maxY: 1500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: "Tektur-Regular",
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: Offset(0, 5),
        ),
      ],
    );
  }
}

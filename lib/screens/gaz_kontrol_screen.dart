import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

class GazKontrolScreen extends StatefulWidget {
  const GazKontrolScreen({super.key});

  @override
  State<GazKontrolScreen> createState() => _GazKontrolScreenState();
}

class _GazKontrolScreenState extends State<GazKontrolScreen> {
  List<String> _son7Gun = [];
  Map<String, List<double>> _gunlukGaz = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _olusturSon7Gun();
    _load7GunVeri();
  }

  void _olusturSon7Gun() {
    final now = DateTime.now();
    _son7Gun = List.generate(7, (i) {
      final date = now.subtract(Duration(days: i));
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    }).reversed.toList();
  }

  Future<void> _load7GunVeri() async {
    Map<String, List<double>> gunlukGaz = {};
    for (String gun in _son7Gun) {
      final snap =
          await FirebaseDatabase.instance.ref('sensor_data/$gun').get();
      if (snap.exists) {
        List<double> gazlar = [];
        for (final child in snap.children) {
          final data = child.value as Map?;
          if (data != null && data['gazSeviyesi'] != null) {
            gazlar.add((data['gazSeviyesi'] as num).toDouble());
          }
        }
        gunlukGaz[gun] = gazlar;
      } else {
        gunlukGaz[gun] = [];
      }
    }
    setState(() {
      _gunlukGaz = gunlukGaz;
      _loading = false;
    });
  }

  List<double> _gunlukGazOrtalamalar() {
    return _son7Gun.map((gun) {
      final veriler = _gunlukGaz[gun] ?? [];
      if (veriler.isEmpty) return 0.0;
      return veriler.reduce((a, b) => a + b) / veriler.length;
    }).toList();
  }

  double _gazGenelOrtalama() {
    final tum = _gunlukGazOrtalamalar().where((v) => v > 0).toList();
    if (tum.isEmpty) return 0.0;
    return tum.reduce((a, b) => a + b) / tum.length;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayKey =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hava Kontrolü'),
        centerTitle: true,
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/lottie/gas_sensor.json',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ana Gaz Seviyesi Göstergesi
                  StreamBuilder<DatabaseEvent>(
                    stream: FirebaseDatabase.instance
                        .ref('sensor_data/$todayKey')
                        .onValue,
                    builder: (context, snapshot) {
                      double gaz = 0.0;
                      if (snapshot.hasData &&
                          snapshot.data!.snapshot.value != null) {
                        final dataMap = Map<String, dynamic>.from(
                            snapshot.data!.snapshot.value as Map);
                        if (dataMap.isNotEmpty) {
                          final sortedKeys = dataMap.keys.toList()..sort();
                          final lastEntry = dataMap[sortedKeys.last] as Map;
                          gaz =
                              (lastEntry['gazSeviyesi'] as num?)?.toDouble() ??
                                  0.0;
                        }
                      }
                      return Container(
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
                            SizedBox(height: 20),
                            Text(
                              '${gaz.toStringAsFixed(1)} ppm',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Tektur-Regular",
                                color: Colors.brown,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Güncel Gaz Seviyesi',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontFamily: "Tektur-Regular",
                              ),
                            ),
                            SizedBox(height: 16),
                            _buildGazUyari(gaz),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),

                  // Gaz Seviyesi Grafiği
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
                          'Son 7 Günlük Gaz Seviyesi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Tektur-Regular",
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          height: 200,
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
                                          value.toInt() < _son7Gun.length) {
                                        final date =
                                            _son7Gun[value.toInt()].split('-');
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
                  SizedBox(height: 20),

                  // Gaz Seviyesi Geçmişi
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
                          'Gaz Seviyesi Geçmişi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Tektur-Regular",
                          ),
                        ),
                        SizedBox(height: 10),
                        ...List.generate(_son7Gun.length, (i) {
                          final date = _son7Gun[i].split('-');
                          final ortalama = _gunlukGazOrtalamalar()[i];
                          return ListTile(
                            leading: Icon(Icons.history, color: Colors.brown),
                            title: Text(
                              '${date[0]}.${date[1]}.${date[2]}',
                              style: TextStyle(fontFamily: "Tektur-Regular"),
                            ),
                            trailing: Text(
                              '${ortalama.toStringAsFixed(1)} ppm',
                              style: TextStyle(
                                color: Colors.brown,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Tektur-Regular",
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Gaz İstatistikleri
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
                          'Gaz İstatistikleri',
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
                              'Ortalama Gaz',
                              '${_gazGenelOrtalama().toStringAsFixed(1)} ppm',
                              Icons.air,
                              Colors.brown,
                            ),
                            _buildStatCard(
                              'En Yüksek',
                              '${_gunlukGazOrtalamalar().reduce((a, b) => a > b ? a : b).toStringAsFixed(1)} ppm',
                              Icons.trending_up,
                              Colors.red,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
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

  Widget _buildGazUyari(double gaz) {
    String mesaj = '';
    Color renk = Colors.green;
    IconData ikon = Icons.check_circle;

    if (gaz <= 300) {
      mesaj = 'Hava Temiz';
      renk = Colors.green;
      ikon = Icons.check_circle;
    } else if (gaz <= 600) {
      mesaj = 'Düşük Risk: Hava Kalitesi Azalmış';
      renk = Colors.yellow[700]!;
      ikon = Icons.warning;
    } else if (gaz <= 900) {
      mesaj = 'Orta Risk: Dikkatli Olun';
      renk = Colors.orange;
      ikon = Icons.error_outline;
    } else if (gaz <= 1200) {
      mesaj = 'Yüksek Risk: Hava Zararlı!';
      renk = Colors.red;
      ikon = Icons.dangerous;
    } else {
      mesaj = 'Çok Yüksek Risk: Acil Müdahale Gerekli!';
      renk = Colors.red[900]!;
      ikon = Icons.dangerous;
    }

    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: renk.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: renk, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(ikon, color: renk, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              mesaj,
              style: TextStyle(
                color: renk,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: "Tektur-Regular",
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

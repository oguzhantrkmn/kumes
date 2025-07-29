import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'services/language_service.dart';

class SicaklikScreen extends StatefulWidget {
  @override
  _SicaklikScreenState createState() => _SicaklikScreenState();
}

class _SicaklikScreenState extends State<SicaklikScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  late DatabaseReference _temperatureRef;
  Map<String, List<double>> _gunlukVeriler = {};
  List<String> _son7Gun = [];
  double _anlikSicaklik = 0.0;
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
    Map<String, List<double>> gunluk = {};
    double anlik = 0.0;
    for (String gun in _son7Gun) {
      final snap = await _temperatureRef.child(gun).get();
      if (snap.exists) {
        List<double> sicakliklar = [];
        for (final child in snap.children) {
          final data = child.value as Map?;
          if (data != null && data['temperature'] != null) {
            sicakliklar.add((data['temperature'] as num).toDouble());
          }
        }
        gunluk[gun] = sicakliklar;
        // Bugünün son sıcaklığı anlık gösterge için
        if (gun == _son7Gun.last && sicakliklar.isNotEmpty) {
          anlik = sicakliklar.last;
        }
      } else {
        gunluk[gun] = [];
      }
    }
    setState(() {
      _gunlukVeriler = gunluk;
      _anlikSicaklik = anlik;
      _loading = false;
    });
  }

  List<double> _gunlukOrtalamalar() {
    return _son7Gun.map((gun) {
      final veriler = _gunlukVeriler[gun] ?? [];
      if (veriler.isEmpty) return 0.0;
      return veriler.reduce((a, b) => a + b) / veriler.length;
    }).toList();
  }

  List<double> _gunlukMinler() {
    return _son7Gun.map((gun) {
      final veriler = _gunlukVeriler[gun] ?? [];
      if (veriler.isEmpty) return 0.0;
      return veriler.reduce((a, b) => a < b ? a : b);
    }).toList();
  }

  List<double> _gunlukMaxlar() {
    return _son7Gun.map((gun) {
      final veriler = _gunlukVeriler[gun] ?? [];
      if (veriler.isEmpty) return 0.0;
      return veriler.reduce((a, b) => a > b ? a : b);
    }).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final localizations = AppLocalizations(languageService.currentLanguage);
    final ortalamalar = _gunlukOrtalamalar();
    final minler = _gunlukMinler();
    final maxlar = _gunlukMaxlar();
    final bugunIndex = _son7Gun.length - 1;
    final bugunVeriler = _gunlukVeriler[_son7Gun.last] ?? [];
    final bugunOrtalama = bugunVeriler.isEmpty
        ? 0.0
        : bugunVeriler.reduce((a, b) => a + b) / bugunVeriler.length;
    final bugunMin = bugunVeriler.isEmpty
        ? 0.0
        : bugunVeriler.reduce((a, b) => a < b ? a : b);
    final bugunMax = bugunVeriler.isEmpty
        ? 0.0
        : bugunVeriler.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.get('sicaklik_kontrol'),
          style: TextStyle(fontFamily: "Tektur-Regular"),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(seconds: 1),
                      curve: Curves.easeInOut,
                      builder: (context, value, child) {
                        return Transform.rotate(
                          angle: value * 6.3, // 2*pi
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  Colors.orange,
                                  Colors.orangeAccent,
                                  Colors.deepOrange,
                                  Colors.orange,
                                ],
                                stops: [0.0, 0.5, 0.8, 1.0],
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Veriler Yükleniyor...',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: "Tektur-Regular",
                      color: Colors.orange,
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
                  // Ana Sıcaklık Göstergesi
                  StreamBuilder<DatabaseEvent>(
                    stream: _temperatureRef.child(_todayKey).onValue,
                    builder: (context, snapshot) {
                      double sicaklik = 0.0;
                      double nem = 0.0;
                      if (snapshot.hasData &&
                          snapshot.data!.snapshot.value != null) {
                        final dataMap = Map<String, dynamic>.from(
                            snapshot.data!.snapshot.value as Map);
                        if (dataMap.isNotEmpty) {
                          final sortedKeys = dataMap.keys.toList()..sort();
                          final lastEntry = dataMap[sortedKeys.last] as Map;
                          sicaklik =
                              (lastEntry['temperature'] as num?)?.toDouble() ??
                                  0.0;
                          nem = (lastEntry['humidity'] as num?)?.toDouble() ??
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
                            Icon(
                              Icons.thermostat,
                              size: 80,
                              color: Colors.orange,
                            ),
                            SizedBox(height: 20),
                            Text(
                              '${sicaklik.toStringAsFixed(1)}°C',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Tektur-Regular",
                                color: Colors.orange,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Nem: ${nem.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontFamily: "Tektur-Regular",
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
                            SizedBox(height: 16),
                            _buildSicaklikUyari(sicaklik),
                          ],
                        ),
                      );
                    },
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
                          'Günlük Sıcaklık Grafiği',
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
                                    ortalamalar.length,
                                    (index) => FlSpot(
                                        index.toDouble(), ortalamalar[index]),
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
                        ...List.generate(_son7Gun.length, (i) {
                          final date = _son7Gun[i].split('-');
                          return ListTile(
                            leading: Icon(Icons.history, color: Colors.orange),
                            title: Text(
                              '${date[0]}.${date[1]}.${date[2]}',
                              style: TextStyle(fontFamily: "Tektur-Regular"),
                            ),
                            trailing: Text(
                              '${ortalamalar[i].toStringAsFixed(1)}°C',
                              style: TextStyle(
                                color: Colors.orange,
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
                                'En Yüksek',
                                '${bugunMax.toStringAsFixed(1)}°C',
                                Icons.arrow_upward),
                            _buildStatCard(
                                'En Düşük',
                                '${bugunMin.toStringAsFixed(1)}°C',
                                Icons.arrow_downward),
                            _buildStatCard(
                                'Ortalama',
                                '${bugunOrtalama.toStringAsFixed(1)}°C',
                                Icons.trending_flat),
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

  Widget _buildSicaklikUyari(double sicaklik) {
    String mesaj = '';
    Color renk = Colors.green;
    IconData ikon = Icons.check_circle;

    if (sicaklik < 0) {
      mesaj = 'Geçersiz Sıcaklık';
      renk = Colors.grey;
      ikon = Icons.help_outline;
    } else if (sicaklik <= 10) {
      mesaj = 'Tehlikeli Soğuk';
      renk = Colors.pink;
      ikon = Icons.dangerous;
    } else if (sicaklik <= 17) {
      mesaj = 'Az Tehlikeli Soğuk';
      renk = Colors.amber;
      ikon = Icons.warning;
    } else if (sicaklik <= 24) {
      mesaj = 'İdeal / Çok İyi';
      renk = Colors.green;
      ikon = Icons.check_box;
    } else if (sicaklik <= 29) {
      mesaj = 'Az Tehlikeli Sıcak';
      renk = Colors.amber;
      ikon = Icons.warning;
    } else if (sicaklik <= 35) {
      mesaj = 'Tehlikeli Sıcak';
      renk = Colors.pink;
      ikon = Icons.dangerous;
    } else {
      mesaj = 'Aşırı Tehlikeli';
      renk = Colors.deepOrange;
      ikon = Icons.local_fire_department;
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'services/language_service.dart';
import 'package:fl_chart/fl_chart.dart';

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
  StreamSubscription<DatabaseEvent>? _subscription;
  List<String> _son7Gun = [];
  Map<String, List<double>> _gunlukYem = {};
  Map<String, List<double>> _gunlukSu = {};

  @override
  void initState() {
    super.initState();
    _olusturSon7Gun();
    _listenToFirebase();
    _gecmisVerileriniOlustur();
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
    Map<String, List<double>> gunlukYem = {};
    Map<String, List<double>> gunlukSu = {};
    List<Map<String, dynamic>> yeniYemGecmisi = [];
    List<Map<String, dynamic>> yeniSuGecmisi = [];
    for (String gun in _son7Gun) {
      final snap =
          await FirebaseDatabase.instance.ref('sensor_data/$gun').get();
      if (snap.exists) {
        List<double> yemler = [];
        List<double> sular = [];
        for (final child in snap.children) {
          final data = child.value as Map?;
          if (data != null) {
            if (data['yemYuzdesi'] != null)
              yemler.add((data['yemYuzdesi'] as num).toDouble());
            if (data['suYuzdesi'] != null)
              sular.add((data['suYuzdesi'] as num).toDouble());
          }
        }
        gunlukYem[gun] = yemler;
        gunlukSu[gun] = sular;
        // Ortalama hesapla ve geçmişe ekle
        double yemOrt = yemler.isNotEmpty
            ? yemler.reduce((a, b) => a + b) / yemler.length
            : 0.0;
        double suOrt = sular.isNotEmpty
            ? sular.reduce((a, b) => a + b) / sular.length
            : 0.0;
        yeniYemGecmisi
            .add({'tarih': gun.replaceAll('-', '.'), 'deger': yemOrt});
        yeniSuGecmisi.add({'tarih': gun.replaceAll('-', '.'), 'deger': suOrt});
      } else {
        gunlukYem[gun] = [];
        gunlukSu[gun] = [];
        yeniYemGecmisi.add({'tarih': gun.replaceAll('-', '.'), 'deger': 0.0});
        yeniSuGecmisi.add({'tarih': gun.replaceAll('-', '.'), 'deger': 0.0});
      }
    }
    setState(() {
      _gunlukYem = gunlukYem;
      _gunlukSu = gunlukSu;
      _yemGecmisi.clear();
      _yemGecmisi.addAll(yeniYemGecmisi);
      _suGecmisi.clear();
      _suGecmisi.addAll(yeniSuGecmisi);
    });
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

  double _yemGenelOrtalama() {
    final tum = _gunlukYemOrtalamalar().where((v) => v > 0).toList();
    if (tum.isEmpty) return 0.0;
    return tum.reduce((a, b) => a + b) / tum.length;
  }

  double _suGenelOrtalama() {
    final tum = _gunlukSuOrtalamalar().where((v) => v > 0).toList();
    if (tum.isEmpty) return 0.0;
    return tum.reduce((a, b) => a + b) / tum.length;
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

  void _listenToFirebase() {
    final now = DateTime.now();
    final todayKey =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    final dbRef = FirebaseDatabase.instance.ref('sensor_data/$todayKey');
    _subscription = dbRef.onValue.listen((event) {
      double su = 0.0;
      double yem = 0.0;
      if (event.snapshot.exists) {
        Map data = event.snapshot.value as Map;
        if (data.isNotEmpty) {
          var lastKey = data.keys.last;
          var lastData = data[lastKey];
          su = (lastData['suYuzdesi'] ?? 0).toDouble();
          yem = (lastData['yemYuzdesi'] ?? 0).toDouble();
        }
      }
      setState(() {
        _yemSeviyesi = yem;
        _suSeviyesi = su;
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final localizations = AppLocalizations(languageService.currentLanguage);
    final now = DateTime.now();
    final todayKey =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

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
                    StreamBuilder<DatabaseEvent>(
                      stream: FirebaseDatabase.instance
                          .ref('sensor_data/$todayKey')
                          .onValue,
                      builder: (context, snapshot) {
                        double yem = 0.0;
                        double su = 0.0;
                        if (snapshot.hasData &&
                            snapshot.data!.snapshot.value != null) {
                          final dataMap = Map<String, dynamic>.from(
                              snapshot.data!.snapshot.value as Map);
                          if (dataMap.isNotEmpty) {
                            final sortedKeys = dataMap.keys.toList()..sort();
                            final lastEntry = dataMap[sortedKeys.last] as Map;
                            yem =
                                (lastEntry['yemYuzdesi'] as num?)?.toDouble() ??
                                    0.0;
                            su = (lastEntry['suYuzdesi'] as num?)?.toDouble() ??
                                0.0;
                          }
                        }
                        return Row(
                          children: [
                            Expanded(
                              child: _buildSeviyeGostergesi(
                                context,
                                localizations.get('yem_seviyesi'),
                                yem,
                                Icons.food_bank,
                                Colors.orange,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildSeviyeGostergesi(
                                context,
                                localizations.get('su_seviyesi'),
                                su,
                                Icons.water_drop,
                                Colors.blue,
                              ),
                            ),
                          ],
                        );
                      },
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

                    // Yem & Su Grafiği
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
                            'Son 7 Günlük Yem & Su Seviyesi',
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
                                            value.toInt() < _son7Gun.length) {
                                          final date = _son7Gun[value.toInt()]
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
                                '%${_yemGenelOrtalama().toStringAsFixed(1)}',
                                Icons.food_bank,
                                Colors.orange,
                              ),
                              _buildIstatistikKarti(
                                'Ortalama Su',
                                '%${_suGenelOrtalama().toStringAsFixed(1)}',
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
                  '${veri['deger'].toStringAsFixed(2)}%',
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

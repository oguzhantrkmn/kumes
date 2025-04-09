import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/statistics_service.dart';
import '../services/language_service.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatelessWidget {
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
      body: Container(
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
                // Tavuk Sayısı Grafiği
                _buildSectionTitle('Tavuk Sayısı İstatistikleri'),
                Container(
                  height: 200,
                  decoration: _buildCardDecoration(context),
                  child: _buildTavukSayisiChart(),
                ),
                SizedBox(height: 20),

                // Yem Tüketim Grafiği
                _buildSectionTitle('Yem Tüketim İstatistikleri'),
                Container(
                  height: 200,
                  decoration: _buildCardDecoration(context),
                  child: _buildYemTuketimChart(),
                ),
                SizedBox(height: 20),

                // Su Tüketim Grafiği
                _buildSectionTitle('Su Tüketim İstatistikleri'),
                Container(
                  height: 200,
                  decoration: _buildCardDecoration(context),
                  child: _buildSuTuketimChart(),
                ),
                SizedBox(height: 20),

                // Sıcaklık Grafiği
                _buildSectionTitle('Sıcaklık İstatistikleri'),
                Container(
                  height: 200,
                  decoration: _buildCardDecoration(context),
                  child: _buildSicaklikChart(),
                ),
                SizedBox(height: 20),

                // Kapı Hareketleri Grafiği
                _buildSectionTitle('Kapı Hareketleri'),
                Container(
                  height: 200,
                  decoration: _buildCardDecoration(context),
                  child: _buildKapiHareketleriChart(),
                ),
                SizedBox(height: 20),

                // Sağlık İstatistikleri
                _buildSectionTitle('Sağlık İstatistikleri'),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: _buildCardDecoration(context),
                  child: Column(
                    children: [
                      _buildHealthStatItem(
                        'Tavuk Başına Yem',
                        '0 g/gün',
                        Icons.food_bank,
                        Colors.orange,
                      ),
                      SizedBox(height: 10),
                      _buildHealthStatItem(
                        'Tavuk Başına Su',
                        '0 ml/gün',
                        Icons.water_drop,
                        Colors.blue,
                      ),
                      SizedBox(height: 10),
                      _buildHealthStatItem(
                        'Ortalama Kilo Artışı',
                        '0 g/gün',
                        Icons.monitor_weight,
                        Colors.green,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Uyarılar ve Öneriler
                _buildSectionTitle('Uyarılar ve Öneriler'),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: _buildCardDecoration(context),
                  child: Column(
                    children: [
                      _buildWarningItem(
                        'Sıcaklık Uyarısı',
                        'Kümes sıcaklığı ideal aralıkta değil (18-22°C)',
                        Icons.thermostat,
                        Colors.red,
                      ),
                      SizedBox(height: 10),
                      _buildWarningItem(
                        'Yem Tüketimi',
                        'Günlük yem tüketimi normal seviyede',
                        Icons.food_bank,
                        Colors.green,
                      ),
                      SizedBox(height: 10),
                      _buildWarningItem(
                        'Su Tüketimi',
                        'Günlük su tüketimi normal seviyede',
                        Icons.water_drop,
                        Colors.green,
                      ),
                    ],
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
          fontSize: 18,
          fontWeight: FontWeight.bold,
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

  Widget _buildTavukSayisiChart() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final days = [
                    'Pzt',
                    'Sal',
                    'Çar',
                    'Per',
                    'Cum',
                    'Cmt',
                    'Paz'
                  ];
                  return Text(
                    days[value.toInt()],
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontFamily: "Tektur-Regular",
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontFamily: "Tektur-Regular",
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(7, (index) => FlSpot(index.toDouble(), 0)),
              isCurved: true,
              color: Colors.orange,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.orange.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYemTuketimChart() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final days = [
                    'Pzt',
                    'Sal',
                    'Çar',
                    'Per',
                    'Cum',
                    'Cmt',
                    'Paz'
                  ];
                  return Text(
                    days[value.toInt()],
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontFamily: "Tektur-Regular",
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontFamily: "Tektur-Regular",
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: 0,
                  color: Colors.orange,
                  width: 20,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSuTuketimChart() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final days = [
                    'Pzt',
                    'Sal',
                    'Çar',
                    'Per',
                    'Cum',
                    'Cmt',
                    'Paz'
                  ];
                  return Text(
                    days[value.toInt()],
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontFamily: "Tektur-Regular",
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontFamily: "Tektur-Regular",
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: 0,
                  color: Colors.blue,
                  width: 20,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSicaklikChart() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final days = [
                    'Pzt',
                    'Sal',
                    'Çar',
                    'Per',
                    'Cum',
                    'Cmt',
                    'Paz'
                  ];
                  return Text(
                    days[value.toInt()],
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontFamily: "Tektur-Regular",
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}°C',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontFamily: "Tektur-Regular",
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(7, (index) => FlSpot(index.toDouble(), 0)),
              isCurved: true,
              color: Colors.red,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.red.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKapiHareketleriChart() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 10,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value % 2 == 0) {
                    // Her 2 saatte bir göster
                    return Text(
                      '${value.toInt()}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontFamily: "Tektur-Regular",
                      ),
                    );
                  }
                  return SizedBox();
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontFamily: "Tektur-Regular",
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(24, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: 0,
                  color: Colors.green,
                  width: 12,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHealthStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 30),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: "Tektur-Regular",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: "Tektur-Regular",
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWarningItem(
    String title,
    String message,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: "Tektur-Regular",
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    fontFamily: "Tektur-Regular",
                    fontSize: 12,
                    color: Colors.grey[600],
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

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
                // Günlük Hayvan Hareketleri
                Text(
                  localizations.get('gunluk_hareketler'),
                  style: TextStyle(
                    fontFamily: "Tektur-Regular",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _buildMovementsChart(
                      statisticsService.getTodaysMovements()),
                ),
                SizedBox(height: 20),

                // Haftalık Hayvan Sayısı
                Text(
                  localizations.get('haftalik_hayvan_sayisi'),
                  style: TextStyle(
                    fontFamily: "Tektur-Regular",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _buildWeeklyCountChart(
                      statisticsService.getLastWeekCounts()),
                ),
                SizedBox(height: 20),

                // Hava Durumu Bilgileri
                if (statisticsService.getLatestWeather() != null) ...[
                  Text(
                    localizations.get('hava_durumu'),
                    style: TextStyle(
                      fontFamily: "Tektur-Regular",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildWeatherCard(
                      context, statisticsService.getLatestWeather()!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMovementsChart(List<AnimalMovement> movements) {
    final entryCounts = List.generate(24, (index) => 0);
    final exitCounts = List.generate(24, (index) => 0);

    for (var movement in movements) {
      final hour = movement.timestamp.hour;
      if (movement.type == 'entry') {
        entryCounts[hour]++;
      } else {
        exitCounts[hour]++;
      }
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 10,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value % 6 == 0) {
                    return Text(
                      '${value.toInt()}:00',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }
                  return const SizedBox();
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(24, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: entryCounts[index].toDouble(),
                  color: Colors.green,
                  width: 8,
                ),
                BarChartRodData(
                  toY: exitCounts[index].toDouble(),
                  color: Colors.red,
                  width: 8,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildWeeklyCountChart(Map<DateTime, int> counts) {
    final spots = counts.entries.map((e) {
      return FlSpot(
        e.key.millisecondsSinceEpoch.toDouble(),
        e.value.toDouble(),
      );
    }).toList();

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
                  final date =
                      DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Text(
                    '${date.day}/${date.month}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(BuildContext context, WeatherData weather) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildWeatherItem(
            context,
            Icons.thermostat,
            '${weather.temperature.toStringAsFixed(1)}°C',
            Colors.orange,
          ),
          _buildWeatherItem(
            context,
            Icons.water_drop,
            '${weather.humidity.toStringAsFixed(1)}%',
            Colors.blue,
          ),
          _buildWeatherItem(
            context,
            Icons.wb_sunny,
            '${weather.lightLevel.toStringAsFixed(1)}',
            Colors.yellow,
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherItem(
    BuildContext context,
    IconData icon,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontFamily: "Tektur-Regular",
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

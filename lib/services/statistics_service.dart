import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatisticsService extends ChangeNotifier {
  List<AnimalMovement> _movements = [];
  List<WeatherData> _weatherHistory = [];
  Map<DateTime, int> _dailyAnimalCounts = {};

  List<AnimalMovement> get movements => _movements;
  List<WeatherData> get weatherHistory => _weatherHistory;
  Map<DateTime, int> get dailyAnimalCounts => _dailyAnimalCounts;

  StatisticsService() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Hayvan hareketleri yükleniyor
    final movementData = prefs.getStringList('animal_movements') ?? [];
    _movements =
        movementData.map((data) => AnimalMovement.fromString(data)).toList();

    // Hava durumu geçmişi yükleniyor
    final weatherData = prefs.getStringList('weather_history') ?? [];
    _weatherHistory =
        weatherData.map((data) => WeatherData.fromString(data)).toList();

    // Günlük hayvan sayıları yükleniyor
    final countData = prefs.getStringList('daily_animal_counts') ?? [];
    _dailyAnimalCounts = Map.fromEntries(
      countData.map((data) {
        final parts = data.split(':');
        return MapEntry(
          DateTime.parse(parts[0]),
          int.parse(parts[1]),
        );
      }),
    );

    notifyListeners();
  }

  Future<void> addAnimalMovement(AnimalMovement movement) async {
    final prefs = await SharedPreferences.getInstance();
    _movements.insert(0, movement);

    if (_movements.length > 100) {
      _movements.removeLast();
    }

    await prefs.setStringList(
      'animal_movements',
      _movements.map((m) => m.toString()).toList(),
    );
    notifyListeners();
  }

  Future<void> addWeatherData(WeatherData data) async {
    final prefs = await SharedPreferences.getInstance();
    _weatherHistory.insert(0, data);

    if (_weatherHistory.length > 24) {
      _weatherHistory.removeLast();
    }

    await prefs.setStringList(
      'weather_history',
      _weatherHistory.map((w) => w.toString()).toList(),
    );
    notifyListeners();
  }

  Future<void> updateDailyAnimalCount(DateTime date, int count) async {
    final prefs = await SharedPreferences.getInstance();
    final key = DateTime(date.year, date.month, date.day);
    _dailyAnimalCounts[key] = count;

    // Son 30 günün verilerini tut
    final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
    _dailyAnimalCounts.removeWhere((date, _) => date.isBefore(thirtyDaysAgo));

    await prefs.setStringList(
      'daily_animal_counts',
      _dailyAnimalCounts.entries
          .map((e) => '${e.key.toIso8601String()}:${e.value}')
          .toList(),
    );
    notifyListeners();
  }

  List<AnimalMovement> getTodaysMovements() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _movements.where((m) => m.timestamp.isAfter(today)).toList();
  }

  WeatherData? getLatestWeather() {
    return _weatherHistory.isNotEmpty ? _weatherHistory.first : null;
  }

  Map<DateTime, int> getLastWeekCounts() {
    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 7));
    return Map.fromEntries(
      _dailyAnimalCounts.entries.where((e) => e.key.isAfter(weekAgo)).toList()
        ..sort((a, b) => a.key.compareTo(b.key)),
    );
  }
}

class AnimalMovement {
  final DateTime timestamp;
  final String type; // 'entry' veya 'exit'
  final bool isUnknown;

  AnimalMovement({
    required this.timestamp,
    required this.type,
    this.isUnknown = false,
  });

  @override
  String toString() => '$timestamp:$type:$isUnknown';

  factory AnimalMovement.fromString(String data) {
    final parts = data.split(':');
    return AnimalMovement(
      timestamp: DateTime.parse(parts[0]),
      type: parts[1],
      isUnknown: parts[2] == 'true',
    );
  }
}

class WeatherData {
  final DateTime timestamp;
  final double temperature;
  final double humidity;
  final double lightLevel;

  WeatherData({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.lightLevel,
  });

  @override
  String toString() => '$timestamp:$temperature:$humidity:$lightLevel';

  factory WeatherData.fromString(String data) {
    final parts = data.split(':');
    return WeatherData(
      timestamp: DateTime.parse(parts[0]),
      temperature: double.parse(parts[1]),
      humidity: double.parse(parts[2]),
      lightLevel: double.parse(parts[3]),
    );
  }
}

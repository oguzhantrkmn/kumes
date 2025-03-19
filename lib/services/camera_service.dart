import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraService extends ChangeNotifier {
  bool _isNightVisionEnabled = false;
  bool _isMotionDetectionEnabled = true;
  int _currentAnimalCount = 0;
  List<String> _alarmHistory = [];
  DateTime? _lastUnknownAnimalDetection;

  bool get isNightVisionEnabled => _isNightVisionEnabled;
  bool get isMotionDetectionEnabled => _isMotionDetectionEnabled;
  int get currentAnimalCount => _currentAnimalCount;
  List<String> get alarmHistory => _alarmHistory;
  DateTime? get lastUnknownAnimalDetection => _lastUnknownAnimalDetection;

  CameraService() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isNightVisionEnabled = prefs.getBool('night_vision') ?? false;
    _isMotionDetectionEnabled = prefs.getBool('motion_detection') ?? true;
    _currentAnimalCount = prefs.getInt('current_animal_count') ?? 0;
    _alarmHistory = prefs.getStringList('alarm_history') ?? [];
    final lastDetection = prefs.getString('last_unknown_detection');
    _lastUnknownAnimalDetection =
        lastDetection != null ? DateTime.parse(lastDetection) : null;
    notifyListeners();
  }

  Future<void> toggleNightVision() async {
    final prefs = await SharedPreferences.getInstance();
    _isNightVisionEnabled = !_isNightVisionEnabled;
    await prefs.setBool('night_vision', _isNightVisionEnabled);
    notifyListeners();
  }

  Future<void> toggleMotionDetection() async {
    final prefs = await SharedPreferences.getInstance();
    _isMotionDetectionEnabled = !_isMotionDetectionEnabled;
    await prefs.setBool('motion_detection', _isMotionDetectionEnabled);
    notifyListeners();
  }

  Future<void> updateAnimalCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    _currentAnimalCount = count;
    await prefs.setInt('current_animal_count', count);
    notifyListeners();
  }

  Future<void> addAlarmEvent(String event) async {
    final prefs = await SharedPreferences.getInstance();
    _alarmHistory.insert(0, "\${DateTime.now()}: \$event");
    if (_alarmHistory.length > 50) {
      _alarmHistory.removeLast();
    }
    await prefs.setStringList('alarm_history', _alarmHistory);
    notifyListeners();
  }

  Future<void> setUnknownAnimalDetection() async {
    final prefs = await SharedPreferences.getInstance();
    _lastUnknownAnimalDetection = DateTime.now();
    await prefs.setString('last_unknown_detection',
        _lastUnknownAnimalDetection!.toIso8601String());
    notifyListeners();
  }

  Future<void> clearAlarmHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _alarmHistory.clear();
    await prefs.setStringList('alarm_history', _alarmHistory);
    notifyListeners();
  }
}

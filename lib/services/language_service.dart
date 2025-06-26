import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'dil';
  String _currentLanguage = 'Türkçe';

  String get currentLanguage => _currentLanguage;

  LanguageService() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? 'Türkçe';
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    if (_currentLanguage == language) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
    _currentLanguage = language;
    notifyListeners();
  }
}

class AppLocalizations {
  final String currentLanguage;

  AppLocalizations(this.currentLanguage);

  String get(String key) {
    final translations = {
      'Türkçe': {
        'ayarlar': 'Ayarlar',
        'bildirimler': 'Bildirimler',
        'bildirimler_aciklama': 'Sistem bildirimlerini al',
        'karanlik_mod': 'Karanlık Mod',
        'karanlik_mod_aciklama': 'Karanlık tema kullan',
        'otomatik_kapi': 'Otomatik Kapı',
        'otomatik_kapi_aciklama': 'Güneşe göre kapıyı otomatik aç/kapat',
        'dil': 'Dil',
        'dil_aciklama': 'Uygulama dilini değiştir',
        'ayarlari_kaydet': 'Ayarları Kaydet',
        'ayarlar_kaydedildi': 'Ayarlar kaydedildi',
        'sicaklik': 'Sıcaklık',
        'sicaklik_kontrol': 'Sıcaklık Kontrolü',
        'mevcut_sicaklik': 'Mevcut Sıcaklık',
        'yem_su': 'Yem & Su',
        'yem_su_kontrol': 'Yem ve Su Kontrolü',
        'yem_seviyesi': 'Yem Seviyesi',
        'su_seviyesi': 'Su Seviyesi',
        'kayan_kapi': 'Kayan Kapı',
        'kapi_kontrol': 'Kapı Kontrolü',
        'kapi_durumu': 'Kapı Durumu',
        'acik': 'Açık',
        'kapali': 'Kapalı',
        'tavuk_sayisi': 'Tavuk Sayısı',
        'tavuk_kontrol': 'Tavuk Sayısı Kontrolü',
        'mevcut_tavuk': 'Mevcut Tavuk Sayısı',
        'artir': 'Artır',
        'azalt': 'Azalt',
        'kaydet': 'Kaydet',
        'kaydedildi': 'Kaydedildi',
        'kontrol_paneli': 'Kontrol Paneli',
        'canli_destek': 'Canlı Destek',
        'canli_destek_aciklama': 'WhatsApp üzerinden destek alın',
        'whatsapp_hata': 'WhatsApp açılamadı',
        'kamera_kontrol': 'Kamera Kontrol',
        'canli_yayin': 'Canlı Yayın',
        'dis_kamera': 'Dış Kamera',
        'mevcut_hayvan_sayisi': 'Mevcut Hayvan Sayısı',
        'son_yabanci_hayvan': 'Son Yabancı Hayvan Tespiti',
        'hareket_algilama': 'Hareket Algılama',
        'gece_gorus': 'Gece Görüşü',
        'alarm_gecmisi': 'Alarm Geçmişi',
        'gecmisi_temizle': 'Geçmişi Temizle',
        'istatistikler': 'İstatistikler',
        'gunluk_hareketler': 'Günlük Hayvan Hareketleri',
        'haftalik_hayvan_sayisi': 'Haftalık Hayvan Sayısı',
        'hava_durumu': 'Hava Durumu',
        'sicaklik_nem': 'Sıcaklık ve Nem',
        'isik_seviyesi': 'Işık Seviyesi',
        'gaz_kontrol': 'Gaz/Hava Kontrolü',
        'gaz_seviyesi': 'Gaz Seviyesi',
        'gaz_uyari_dusuk': 'Gaz seviyesi normal',
        'gaz_uyari_orta': 'Gaz seviyesi orta, dikkatli olun',
        'gaz_uyari_yuksek': 'Gaz seviyesi yüksek, riskli!',
        'son_7_gun_ortalama': 'Son 7 Gün Ortalaması',
        'gecmis': 'Geçmiş',
        'bugun': 'Bugün',
        'dun': 'Dün',
        'son_7_gun': 'Son 7 Gün',
        'tutorial_sicaklik_baslik': 'Sıcaklık',
        'tutorial_sicaklik_aciklama':
            'Kümesin sıcaklık durumunu buradan takip edebilirsiniz.',
        'tutorial_yem_su_baslik': 'Yem & Su',
        'tutorial_yem_su_aciklama':
            'Yem ve su seviyelerini anlık olarak görebilirsiniz.',
        'tutorial_kapi_baslik': 'Kayan Kapı',
        'tutorial_kapi_aciklama': 'Kapı durumunu kontrol edebilirsiniz.',
        'tutorial_tavuk_baslik': 'Tavuk Sayısı',
        'tutorial_tavuk_aciklama': 'Kümesinizdeki tavuk sayısını takip edin.',
        'tutorial_istatistik_baslik': 'İstatistikler',
        'tutorial_istatistik_aciklama':
            'Geçmişe yönelik istatistikleri inceleyin.',
        'tutorial_kamera_baslik': 'Dış Kamera',
        'tutorial_kamera_aciklama': 'Kümes dışını canlı izleyin.',
        'tutorial_gaz_baslik': 'Hava Kontrolü',
        'tutorial_gaz_aciklama': 'Gaz ve hava kalitesini takip edin.',
      },
      'English': {
        'ayarlar': 'Settings',
        'bildirimler': 'Notifications',
        'bildirimler_aciklama': 'Receive system notifications',
        'karanlik_mod': 'Dark Mode',
        'karanlik_mod_aciklama': 'Use dark theme',
        'otomatik_kapi': 'Automatic Door',
        'otomatik_kapi_aciklama':
            'Automatically open/close door based on sunlight',
        'dil': 'Language',
        'dil_aciklama': 'Change application language',
        'ayarlari_kaydet': 'Save Settings',
        'ayarlar_kaydedildi': 'Settings saved',
        'sicaklik': 'Temperature',
        'sicaklik_kontrol': 'Temperature Control',
        'mevcut_sicaklik': 'Current Temperature',
        'yem_su': 'Feed & Water',
        'yem_su_kontrol': 'Feed and Water Control',
        'yem_seviyesi': 'Feed Level',
        'su_seviyesi': 'Water Level',
        'kayan_kapi': 'Sliding Door',
        'kapi_kontrol': 'Door Control',
        'kapi_durumu': 'Door Status',
        'acik': 'Open',
        'kapali': 'Closed',
        'tavuk_sayisi': 'Chicken Count',
        'tavuk_kontrol': 'Chicken Count Control',
        'mevcut_tavuk': 'Current Chicken Count',
        'artir': 'Increase',
        'azalt': 'Decrease',
        'kaydet': 'Save',
        'kaydedildi': 'Saved',
        'kontrol_paneli': 'Control Panel',
        'canli_destek': 'Live Support',
        'canli_destek_aciklama': 'Get support via WhatsApp',
        'whatsapp_hata': 'Couldn\'t open WhatsApp',
        'kamera_kontrol': 'Camera Control',
        'canli_yayin': 'Live Stream',
        'dis_kamera': 'External Camera',
        'mevcut_hayvan_sayisi': 'Current Animal Count',
        'son_yabanci_hayvan': 'Last Unknown Animal Detection',
        'hareket_algilama': 'Motion Detection',
        'gece_gorus': 'Night Vision',
        'alarm_gecmisi': 'Alarm History',
        'gecmisi_temizle': 'Clear History',
        'istatistikler': 'Statistics',
        'gunluk_hareketler': 'Daily Animal Movements',
        'haftalik_hayvan_sayisi': 'Weekly Animal Count',
        'hava_durumu': 'Weather',
        'sicaklik_nem': 'Temperature & Humidity',
        'isik_seviyesi': 'Light Level',
        'gaz_kontrol': 'Gas/Air Control',
        'gaz_seviyesi': 'Gas Level',
        'gaz_uyari_dusuk': 'Gas level is normal',
        'gaz_uyari_orta': 'Gas level is moderate, be careful',
        'gaz_uyari_yuksek': 'Gas level is high, risky!',
        'son_7_gun_ortalama': 'Last 7 Days Average',
        'gecmis': 'History',
        'bugun': 'Today',
        'dun': 'Yesterday',
        'son_7_gun': 'Last 7 Days',
        'tutorial_sicaklik_baslik': 'Temperature',
        'tutorial_sicaklik_aciklama':
            'You can monitor the temperature status of the coop here.',
        'tutorial_yem_su_baslik': 'Feed & Water',
        'tutorial_yem_su_aciklama':
            'You can instantly see the feed and water levels.',
        'tutorial_kapi_baslik': 'Sliding Door',
        'tutorial_kapi_aciklama': 'You can control the door status.',
        'tutorial_tavuk_baslik': 'Chicken Count',
        'tutorial_tavuk_aciklama': 'Track the number of chickens in your coop.',
        'tutorial_istatistik_baslik': 'Statistics',
        'tutorial_istatistik_aciklama': 'Review historical statistics.',
        'tutorial_kamera_baslik': 'External Camera',
        'tutorial_kamera_aciklama': 'Watch the outside of the coop live.',
        'tutorial_gaz_baslik': 'Air Control',
        'tutorial_gaz_aciklama': 'Monitor gas and air quality.',
      },
    };

    return translations[currentLanguage]?[key] ??
        translations['Türkçe']![key] ??
        key;
  }
}

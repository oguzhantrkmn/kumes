/*
 * FİNAL KODU - HATA AYIKLAMA MODU
 * Firebase'den yem_mesafe kaldırıldı.
 * Seri Port'a detaylı sensör hata ayıklama bilgileri eklendi.
*/

// Gerekli Kütüphaneler
#include <ESP8266WiFi.h>
#include <Firebase_ESP_Client.h>
#include <DHT.h>
#include <time.h>

// WiFi ve Firebase Bilgileri
#define WIFI_SSID "oguzhan"
#define WIFI_PASSWORD "1905gs55"
#define API_KEY "AIzaSyCPJij63lL9L7lbCESOu1F0gf5-2QVEilA"
define DATABASE_URL "akillitavukkumesi-default-rtdb.europe-west1.firebasedatabase.app"

// Kap Yükseklikleri
const float YEM_KABI_YUKSEKLIGI_CM = 10.0;
const float SU_KABI_YUKSEKLIGI_CM  = 10.0;

// SENSÖR PİNLERİ (GPIO)
const int MQ4_PIN = A0;
const int DHT_PIN = 13;
const int YEM_TRIG_PIN = 14;
const int YEM_ECHO_PIN = 12;
const int SU_TRIG_PIN = 2;
const int SU_ECHO_PIN = 15;

// Firebase ve DHT Nesneleri
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
#define DHTTYPE DHT11
DHT dht(DHT_PIN, DHTTYPE);

void setup() {
  Serial.begin(115200);
  // setup() fonksiyonunun geri kalanı tamamen aynı, değişiklik yok...
  pinMode(YEM_TRIG_PIN, OUTPUT);
  pinMode(YEM_ECHO_PIN, INPUT);
  pinMode(SU_TRIG_PIN, OUTPUT);
  pinMode(SU_ECHO_PIN, INPUT);
  dht.begin();
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("WiFi'ye baglaniliyor");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi bağlantısı başarılı!");
  configTime(3 * 3600, 0, "pool.ntp.org", "time.nist.gov");
  Serial.print("NTP ile saat ayarlanıyor");
  while (time(nullptr) < 100000) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nSaat ayarlandı!");
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  config.signer.test_mode = true; 
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
  Serial.println("Firebase başlatıldı.");
}

void loop() {
  if (Firebase.ready()) {
    Serial.println("====================================");

    // --- Sensörleri Oku ---
    float nem = dht.readHumidity();
    float sicaklik = dht.readTemperature();
    int gazDegeri = analogRead(MQ4_PIN);
    Serial.printf("Ortam: %.2f C, %.2f %% | Gaz: %d\n", sicaklik, nem, gazDegeri);

    // --- YEM SEVİYESİ HESAPLAMASI ---
    digitalWrite(YEM_TRIG_PIN, LOW); delayMicroseconds(2);
    digitalWrite(YEM_TRIG_PIN, HIGH); delayMicroseconds(10);
    digitalWrite(YEM_TRIG_PIN, LOW);
    long sure_yem = pulseIn(YEM_ECHO_PIN, HIGH, 25000);
    float mesafe_yem = 0;
    float yem_doluluk_yuzdesi = 0;
    if (sure_yem > 0) {
      mesafe_yem = sure_yem * 0.0343 / 2;
      yem_doluluk_yuzdesi = 100.0 - (mesafe_yem / YEM_KABI_YUKSEKLIGI_CM * 100.0);
      if (yem_doluluk_yuzdesi < 0) yem_doluluk_yuzdesi = 0;
      if (yem_doluluk_yuzdesi > 100) yem_doluluk_yuzdesi = 100;
    }
    // YENİ DEBUG SATIRLARI
    Serial.printf(">>> YEM SENSORU - Sure: %ld, Mesafe: %.2f cm, Yuzde: %.2f %%\n", sure_yem, mesafe_yem, yem_doluluk_yuzdesi);

    // --- SU SEVİYESİ HESAPLAMASI ---
    digitalWrite(SU_TRIG_PIN, LOW); delayMicroseconds(2);
    digitalWrite(SU_TRIG_PIN, HIGH); delayMicroseconds(10);
    digitalWrite(SU_TRIG_PIN, LOW);
    long sure_su = pulseIn(SU_ECHO_PIN, HIGH, 25000);
    float mesafe_su = 0;
    float su_doluluk_yuzdesi = 0;
    if (sure_su > 0) {
      mesafe_su = sure_su * 0.0343 / 2;
      su_doluluk_yuzdesi = 100.0 - (mesafe_su / SU_KABI_YUKSEKLIGI_CM * 100.0);
      if (su_doluluk_yuzdesi < 0) su_doluluk_yuzdesi = 0;
      if (su_doluluk_yuzdesi > 100) su_doluluk_yuzdesi = 100;
    }
    // YENİ DEBUG SATIRLARI
    Serial.printf(">>> SU SENSORU   - Sure: %ld, Mesafe: %.2f cm, Yuzde: %.2f %%\n", sure_su, mesafe_su, su_doluluk_yuzdesi);

    // --- Tarih, Saat ve Firebase JSON Hazırlama ---
    time_t now = time(nullptr);
    struct tm * timeinfo = localtime(&now);
    char dateStr[11];
    snprintf(dateStr, sizeof(dateStr), "%02d-%02d-%04d", timeinfo->tm_mday, timeinfo->tm_mon + 1, timeinfo->tm_year + 1900);
    char timeStr[9];
    snprintf(timeStr, sizeof(timeStr), "%02d:%02d:%02d", timeinfo->tm_hour, timeinfo->tm_min, timeinfo->tm_sec);
    
    FirebaseJson json;
    json.set("temperature", sicaklik);
    json.set("humidity", nem);
    json.set("gazSeviyesi", gazDegeri);
    json.set("yemYuzdesi", yem_doluluk_yuzdesi);
    json.set("suYuzdesi", su_doluluk_yuzdesi);
    json.set("zaman", timeStr);
    // "yem_mesafe_cm" satırı kaldırıldı.

    // --- Veriyi Firebase'e Gönder ---
    String path = "/sensor_data/";
    path += dateStr; 
    
    Serial.print("Veriler Firebase'e gonderiliyor... ");
    if (Firebase.RTDB.pushJSON(&fbdo, path.c_str(), &json)) {
      Serial.println("[✓] BASARILI!");
    } else {
      Serial.print("[X] HATA: ");
      Serial.println(fbdo.errorReason());
    }
  } else {
    Serial.println("[X] Firebase hazır DEĞİL!");
  }
  delay(10000);
}
#include <ESP8266WiFi.h>
#include <Firebase_ESP_Client.h>
#include <DHT.h>
#include <time.h>

// WiFi bilgileri
#define WIFI_SSID "oguzhan"
#define WIFI_PASSWORD "1905gs55"

// Firebase bilgileri
#define API_KEY "AIzaSyCPJij63lL9L7lbCESOu1F0gf5-2QVEilA"
#define DATABASE_URL "akillitavukkumesi-default-rtdb.europe-west1.firebasedatabase.app"

// Ultrasonik sensör pinleri (HC-SR04)
#define TRIGGER_PIN 5  // GPIO5 (D1)
#define ECHO_PIN 4     // GPIO4 (D2)

// DHT sensör ayarları
#define DHTPIN 2       // GPIO2 (D4)
#define DHTTYPE DHT11  // veya kullandığın sensöre göre DHT22
#define YEM_KABI_YUKSEKLIK 20.0 // cm

// Firebase nesneleri
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(115200);

  // WiFi bağlantısı
  Serial.println("WiFi bağlantısı başlatılıyor...");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  int wifiCounter = 0;
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    wifiCounter++;
    if (wifiCounter > 40) {
      Serial.println("\n[HATA] WiFi bağlantısı sağlanamadı!");
      return;
    }
  }
  Serial.println("\nWiFi bağlantısı başarılı!");
  Serial.print("IP adresi: ");
  Serial.println(WiFi.localIP());

  // NTP ayarları
  configTime(3 * 3600, 0, "pool.ntp.org", "time.nist.gov"); // Türkiye için GMT+3
  Serial.println("NTP ile saat ayarlanıyor...");
  while (time(nullptr) < 100000) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nSaat ayarlandı!");

  // Firebase ayarları
  Serial.println("Firebase ayarları yapılıyor...");
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  // Test modunda giriş (auth olmadan bağlantı)
  config.signer.test_mode = true;

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
  Serial.println("Firebase başlatıldı.");

  // Ultrasonik sensör pin ayarları
  pinMode(TRIGGER_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  dht.begin();
}

void loop() {
  Serial.println("Firebase bağlantısı kontrol ediliyor...");

  if (Firebase.ready()) {
    Serial.println("[✓] Firebase hazır, sensör verileri alınıyor...");

    // Mesafe ölçümü
    digitalWrite(TRIGGER_PIN, LOW);
    delayMicroseconds(2);
    digitalWrite(TRIGGER_PIN, HIGH);
    delayMicroseconds(10);
    digitalWrite(TRIGGER_PIN, LOW);
    long duration = pulseIn(ECHO_PIN, HIGH);
    float distance_cm = duration * 0.034 / 2;

    // Sıcaklık ve nem ölçümü
    float sicaklik = dht.readTemperature();
    float nem = dht.readHumidity();

    // Yem yüzdesi hesaplama
    float yemYuzdesi = 100.0 * (YEM_KABI_YUKSEKLIK - distance_cm) / YEM_KABI_YUKSEKLIK;
    if (yemYuzdesi < 0) yemYuzdesi = 0;
    if (yemYuzdesi > 100) yemYuzdesi = 100;

    Serial.print("Ölçülen Mesafe: "); Serial.print(distance_cm); Serial.println(" cm");
    Serial.print("Sıcaklık: "); Serial.print(sicaklik); Serial.println(" C");
    Serial.print("Nem: "); Serial.print(nem); Serial.println(" %");
    Serial.print("Yem Yüzdesi: "); Serial.print(yemYuzdesi); Serial.println(" %");

    // Tarih bilgisini oluştur (gün/ay/yıl)
    time_t now = time(nullptr);
    struct tm * timeinfo = localtime(&now);
    char dateStr[11]; // "DD-MM-YYYY" + null
    snprintf(dateStr, sizeof(dateStr), "%02d-%02d-%04d", timeinfo->tm_mday, timeinfo->tm_mon + 1, timeinfo->tm_year + 1900);

    // Firebase'e veri gönder
    FirebaseJson json;
    json.set("temperature", sicaklik);
    json.set("humidity", nem);
    json.set("distance", distance_cm);
    json.set("yemYuzdesi", yemYuzdesi);
    json.set("timestamp", millis());

    String path = "/sensor_data/";
    path += dateStr;

    if (Firebase.RTDB.pushJSON(&fbdo, path.c_str(), &json)) {
      Serial.println("[✓] Tüm sensör verileri gönderildi!");
    } else {
      Serial.print("[X] Veri gönderilemedi: ");
      Serial.println(fbdo.errorReason());
    }
  } else {
    Serial.println("[X] Firebase hazır DEĞİL!");
  }

  delay(5000); // 30 saniyede bir ölçüm
}

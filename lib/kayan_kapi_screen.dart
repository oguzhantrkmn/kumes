import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/language_service.dart';

class KayanKapiScreen extends StatefulWidget {
  @override
  _KayanKapiScreenState createState() => _KayanKapiScreenState();
}

class _KayanKapiScreenState extends State<KayanKapiScreen> {
  bool _isLoading = true;
  bool _kapiDurumu = false;
  bool _otomatikKapi = false;
  TimeOfDay _kapanmaSaati = TimeOfDay(hour: 20, minute: 0);
  final List<Map<String, dynamic>> _kapiGecmisi = [];

  @override
  void initState() {
    super.initState();
    _loadKapiDurumu();
    _loadAyarlar();
    _kapiGecmisiniOlustur();
  }

  void _kapiGecmisiniOlustur() {
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      _kapiGecmisi.add({
        'tarih': '${date.day}.${date.month}.${date.year}',
        'durum': false,
        'saat': '20:00'
      });
    }
  }

  Future<void> _loadKapiDurumu() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _kapiDurumu = prefs.getBool('kapi_durumu') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _loadAyarlar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _otomatikKapi = prefs.getBool('otomatik_kapi') ?? false;
      final kapanmaSaatiStr = prefs.getString('kapanma_saati') ?? '20:00';
      final parts = kapanmaSaatiStr.split(':');
      _kapanmaSaati = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    });
  }

  Future<void> _toggleKapiDurumu() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final yeniDurum = !_kapiDurumu;
    await prefs.setBool('kapi_durumu', yeniDurum);

    // Kapı geçmişine ekle
    final now = DateTime.now();
    _kapiGecmisi.insert(0, {
      'tarih': '${now.day}.${now.month}.${now.year}',
      'durum': yeniDurum,
      'saat': '${now.hour}:${now.minute}'
    });
    if (_kapiGecmisi.length > 7) {
      _kapiGecmisi.removeLast();
    }

    setState(() {
      _kapiDurumu = yeniDurum;
      _isLoading = false;
    });

    Navigator.pop(context, true);
  }

  Future<void> _toggleOtomatikKapi() async {
    setState(() {
      _otomatikKapi = !_otomatikKapi;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('otomatik_kapi', _otomatikKapi);
  }

  Future<void> _selectKapanmaSaati() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _kapanmaSaati,
    );
    if (picked != null) {
      setState(() {
        _kapanmaSaati = picked;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'kapanma_saati',
        '${picked.hour}:${picked.minute}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final localizations = AppLocalizations(languageService.currentLanguage);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            localizations.get('kapi_kontrol'),
            style: TextStyle(fontFamily: "Tektur-Regular"),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Ana Kapı Kontrolü
                    Container(
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
                            Icons.door_front_door,
                            size: 80,
                            color: _kapiDurumu ? Colors.green : Colors.red,
                          ),
                          SizedBox(height: 20),
                          Text(
                            localizations.get('kapi_durumu'),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Tektur-Regular",
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _kapiDurumu
                                ? localizations.get('acik')
                                : localizations.get('kapali'),
                            style: TextStyle(
                              fontSize: 20,
                              color: _kapiDurumu ? Colors.green : Colors.red,
                              fontFamily: "Tektur-Regular",
                            ),
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _toggleKapiDurumu,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor:
                                  _kapiDurumu ? Colors.red : Colors.green,
                            ),
                            child: Text(
                              _kapiDurumu ? 'Kapıyı Kapat' : 'Kapıyı Aç',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: "Tektur-Regular",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Otomatik Kapı Ayarları
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
                            'Otomatik Kapı Ayarları',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Tektur-Regular",
                            ),
                          ),
                          SizedBox(height: 20),
                          SwitchListTile(
                            title: Text(
                              'Otomatik Kapı',
                              style: TextStyle(fontFamily: "Tektur-Regular"),
                            ),
                            subtitle: Text(
                              'Kapıyı belirlenen saatte otomatik kapat',
                              style: TextStyle(fontFamily: "Tektur-Regular"),
                            ),
                            value: _otomatikKapi,
                            onChanged: (value) => _toggleOtomatikKapi(),
                            activeColor: Colors.green,
                          ),
                          ListTile(
                            title: Text(
                              'Kapanma Saati',
                              style: TextStyle(fontFamily: "Tektur-Regular"),
                            ),
                            subtitle: Text(
                              '${_kapanmaSaati.hour}:${_kapanmaSaati.minute}',
                              style: TextStyle(fontFamily: "Tektur-Regular"),
                            ),
                            trailing: Icon(Icons.access_time),
                            onTap: _selectKapanmaSaati,
                            enabled: _otomatikKapi,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Kapı Geçmişi
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
                            'Kapı Geçmişi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Tektur-Regular",
                            ),
                          ),
                          SizedBox(height: 10),
                          ..._kapiGecmisi.map((veri) => ListTile(
                                leading: Icon(
                                  Icons.history,
                                  color:
                                      veri['durum'] ? Colors.green : Colors.red,
                                ),
                                title: Text(
                                  '${veri['tarih']}',
                                  style:
                                      TextStyle(fontFamily: "Tektur-Regular"),
                                ),
                                subtitle: Text(
                                  '${veri['saat']}',
                                  style:
                                      TextStyle(fontFamily: "Tektur-Regular"),
                                ),
                                trailing: Text(
                                  veri['durum'] ? 'Açık' : 'Kapalı',
                                  style: TextStyle(
                                    color: veri['durum']
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Tektur-Regular",
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

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
                                'Açık Süre',
                                '0 saat',
                                Icons.timer,
                                Colors.green,
                              ),
                              _buildIstatistikKarti(
                                'Günlük Açılış',
                                '0 kez',
                                Icons.door_front_door,
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

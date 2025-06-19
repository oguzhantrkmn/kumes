import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akıllı Kümes'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: StreamBuilder(
          stream: _database.child('sensor_data/temperature').onValue,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Bir hata oluştu');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
              return const Text('Veri bulunamadı');
            }

            final temperature =
                double.parse(snapshot.data!.snapshot.value.toString());

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sıcaklık Değeri:',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  '$temperature °C',
                  style: const TextStyle(
                      fontSize: 48, fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

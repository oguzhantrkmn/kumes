import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:async';

class RtspStreamView extends StatefulWidget {
  final String url;
  const RtspStreamView({super.key, this.url = 'http://192.168.0.32:8081'});

  @override
  State<RtspStreamView> createState() => _RtspStreamViewState();
}

class _RtspStreamViewState extends State<RtspStreamView> {
  late http.Client _client;
  StreamController<Uint8List>? _streamController;

  @override
  void initState() {
    super.initState();
    _client = http.Client();
    _streamController = StreamController<Uint8List>();
    _startStream();
  }

  void _startStream() async {
    try {
      final request = http.Request('GET', Uri.parse(widget.url));
      final response = await _client.send(request);

      List<int> bytes = [];
      bool inImage = false;

      await for (var chunk in response.stream) {
        for (var byte in chunk) {
          if (!inImage) {
            // JPEG başlangıcı
            if (byte == 0xFF) inImage = true;
            bytes = [byte];
          } else {
            bytes.add(byte);
            // JPEG bitişi
            if (bytes.length > 2 &&
                bytes[bytes.length - 2] == 0xFF &&
                bytes[bytes.length - 1] == 0xD9) {
              // Sadece en son kareyi göster
              if (_streamController?.isClosed == false) {
                _streamController?.add(Uint8List.fromList(bytes));
              }
              inImage = false;
              bytes = [];
            }
          }
        }
      }
    } catch (e) {
      _streamController?.addError(e);
    }
  }

  @override
  void dispose() {
    _client.close();
    _streamController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: StreamBuilder<Uint8List>(
        stream: _streamController?.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover, // Tüm çerçeveyi doldur
              gaplessPlayback: true,
              width: double.infinity,
              height: double.infinity,
            );
          } else if (snapshot.hasError) {
            return const Center(child: Icon(Icons.error));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

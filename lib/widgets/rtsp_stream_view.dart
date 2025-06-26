import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class RtspStreamView extends StatefulWidget {
  final String url;
  const RtspStreamView(
      {super.key, this.url = 'rtsp://172.20.10.3:8554/unicast'});

  @override
  State<RtspStreamView> createState() => _RtspStreamViewState();
}

class _RtspStreamViewState extends State<RtspStreamView> {
  late VlcPlayerController _videoPlayerController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeVlcPlayer();
  }

  void _initializeVlcPlayer() {
    _videoPlayerController = VlcPlayerController.network(
      widget.url,
      autoPlay: true,
    );

    // Yükleme durumunu kontrol et
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          VlcPlayer(
            controller: _videoPlayerController,
            aspectRatio: 16 / 9,
            placeholder: Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/lottie/camera.json',
                      width: 80,
                      height: 80,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'RTSP Stream Bağlanıyor...',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Tektur-Regular",
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/lottie/camera.json',
                      width: 80,
                      height: 80,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'RTSP Stream Yükleniyor...',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Tektur-Regular",
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'VLC Player ile bağlanıyor',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: "Tektur-Regular",
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

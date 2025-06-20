import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class RtspStreamView extends StatefulWidget {
  const RtspStreamView({super.key});

  @override
  _RtspStreamViewState createState() => _RtspStreamViewState();
}

class _RtspStreamViewState extends State<RtspStreamView> {
  late VlcPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VlcPlayerController.network(
      'rtsp://192.168.1.116:8554/live',
      hwAcc: HwAcc.auto,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: 1920,
        height: 1080,
        child: VlcPlayer(
          controller: _controller,
          aspectRatio: 16 / 9,
          placeholder: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

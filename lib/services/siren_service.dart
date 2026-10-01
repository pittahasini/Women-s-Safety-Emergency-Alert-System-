import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SirenService {
  static final AudioPlayer player = AudioPlayer();

  static Future<void> startSiren() async {
    try {
      debugPrint("===== SIREN START =====");

      await player.setReleaseMode(ReleaseMode.loop);

      await player.play(
        AssetSource("audio/siren.mp3"),
      );

      debugPrint("===== SIREN PLAYING =====");
    } catch (e) {
      debugPrint("===== SIREN ERROR =====");
      debugPrint(e.toString());
    }
  }

  static Future<void> stopSiren() async {
    await player.stop();
    debugPrint("===== SIREN STOPPED =====");
  }
}
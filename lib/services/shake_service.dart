import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeService {
  static StreamSubscription? _subscription;

  static void start(Function onShake) {
    _subscription = accelerometerEvents.listen((event) {
      double gForce =
      (event.x * event.x +
          event.y * event.y +
          event.z * event.z);

      if (gForce > 250) {
        print("📳 Phone Shaken!");
        onShake();
      }
    });
  }

  static void stop() {
    _subscription?.cancel();
  }
}
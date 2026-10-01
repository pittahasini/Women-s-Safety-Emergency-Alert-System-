import 'dart:async';

class JourneyTimerService {
  static Timer? timer;

  static void start({
    required int minutes,
    required Function onTimeout,
  }) {
    timer?.cancel();

    timer = Timer(Duration(minutes: minutes), () {
      onTimeout();
    });
  }

  static void stop() {
    timer?.cancel();
  }
}
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';


class SOSService {
  // Call Police
  static Future<void> makeCall(String number) async {

    final Uri uri = Uri(
      scheme: 'tel',
      path: number,
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

  }

  // Get Current GPS Location
  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      print("GPS is OFF");
      return null;
    }

    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print("Location Permission Denied");
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("Latitude: ${position.latitude}");
      print("Longitude: ${position.longitude}");

      return position;
    } catch (e) {
      print("GPS Error: $e");
      return null;
    }
  }
  static Future<void> callPolice() async {

    final Uri uri = Uri(
      scheme: 'tel',
      path: '100',
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  // Open Google Maps
  static Future<void> openGoogleMaps(
      double latitude,
      double longitude) async {

    final Uri mapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude",
    );

    print("Opening Maps: $mapsUrl");

    await launchUrl(
      mapsUrl,
      mode: LaunchMode.externalApplication,
    );
  }
  // Send SOS SMS
  static Future<void> sendSOS(
      List<String> numbers,
      double latitude,
      double longitude,
      ) async {

    String message = '''
🚨 EMERGENCY!

I need immediate help.

My location:
https://maps.google.com/?q=$latitude,$longitude

Sent from Guardian AI
''';


    final Uri smsUri = Uri(
      scheme: 'sms',
      path: numbers.join(','),
      queryParameters: {
        'body': message,
      },
    );


    await launchUrl(
      smsUri,
      mode: LaunchMode.externalApplication,
    );
  }
}
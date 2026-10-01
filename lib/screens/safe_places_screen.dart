import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SafePlacesScreen extends StatelessWidget {
  const SafePlacesScreen({super.key});

  final List<Map<String, String>> safePlaces = const [
    {
      "name": "Hasanparthy Police Station",
      "type": "Police Station",
      "lat": "17.9965",
      "lng": "79.5946",
    },
    {
      "name": "MGM Hospital",
      "type": "Hospital",
      "lat": "17.9784",
      "lng": "79.6008",
    },
    {
      "name": "Indian Oil Petrol Pump",
      "type": "Petrol Pump",
      "lat": "17.9915",
      "lng": "79.5965",
    },
    {
      "name": "Apollo Pharmacy",
      "type": "Medical Store",
      "lat": "17.9870",
      "lng": "79.6010",
    },
    {
      "name": "SRITW College",
      "type": "Safe Campus",
      "lat": "18.0490",
      "lng": "79.5468",
    },
  ];

  Future<void> openMap(String lat, String lng) async {
    final Uri uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  IconData getIcon(String type) {
    switch (type) {
      case "Hospital":
        return Icons.local_hospital;

      case "Police Station":
        return Icons.local_police;

      case "Petrol Pump":
        return Icons.local_gas_station;

      case "Medical Store":
        return Icons.medical_services;

      default:
        return Icons.location_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Safe Places"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: ListView.builder(
        itemCount: safePlaces.length,
        itemBuilder: (context, index) {

          final place = safePlaces[index];

          return Card(
            margin: const EdgeInsets.all(10),

            child: ListTile(

              leading: Icon(
                getIcon(place["type"]!),
                color: Colors.green,
                size: 35,
              ),

              title: Text(place["name"]!),

              subtitle: Text(place["type"]!),

              trailing: const Icon(Icons.arrow_forward_ios),

              onTap: () {
                openMap(
                  place["lat"]!,
                  place["lng"]!,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
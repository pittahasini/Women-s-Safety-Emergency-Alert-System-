import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/safe_places_screen.dart';
import 'models/contact_model.dart';
import 'screens/contacts_screen.dart';
import 'services/sos_service.dart';
import 'package:geolocator/geolocator.dart';
import 'services/ai_service.dart';
import 'services/voice_sos_service.dart';
import 'screens/self_defense_screen.dart';
import 'services/shake_service.dart';
import 'services/siren_service.dart';
import 'screens/language_screen.dart';
import 'services/journey_timer_service.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(ContactModelAdapter());

  await Hive.openBox<ContactModel>('contacts');

  runApp(const GuardianAI());
}

class GuardianAI extends StatelessWidget {
  const GuardianAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guardian AI',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),
      home: const HomeDashboard(),
    );
  }
}

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {

  bool demoMode = false;

  Future<void> checkRisk() async {

    String risk = demoMode
        ? "HIGH"
        : AIService.predictRisk(
      hour: DateTime.now().hour,
      crimeRate: AIService.getCrimeRate("Hasanparthy"),
      speed: AIService.randomSpeed(),
    );

    if (risk == "HIGH") {

      Position? position =
      await SOSService.getCurrentPosition();

      if (position == null) return;

      final box =
      Hive.box<ContactModel>('contacts');

      List<String> numbers = [];

      for (var c in box.values) {
        numbers.add(c.phone);
      }

      if (numbers.isNotEmpty) {

        await SOSService.sendSOS(
          numbers,
          position.latitude,
          position.longitude,
        );

      }

      await SOSService.openGoogleMaps(
        position.latitude,
        position.longitude,
      );
// 📞 Call Police
      await SOSService.makeCall("100");
// 🔊 Start Siren
      await SirenService.startSiren();



      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("🚨 HIGH RISK"),
          content: const Text(
            "AI detected danger.\nSOS Activated Automatically.\nSiren is Active.",
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () async {
                await SirenService.stopSiren();

                await VoiceSOSService.startListening(() async {
                  await triggerSOS();
                });

                Navigator.pop(context);
              },
              icon: const Icon(Icons.volume_off),
              label: const Text("STOP SIREN"),
            ),
          ],
        ),
      );
    }
  }
  Future<void> triggerSOS() async {
    await VoiceSOSService.stopListening();
    Position? position = await SOSService.getCurrentPosition();

    if (position == null) return;

    final box = Hive.box<ContactModel>('contacts');

    List<String> numbers = [];

    for (var contact in box.values) {
      numbers.add(contact.phone);
    }

    // Send SOS SMS
    if (numbers.isNotEmpty) {
      await SOSService.sendSOS(
        numbers,
        position.latitude,
        position.longitude,
      );
    }

    // Open Maps
    await SOSService.openGoogleMaps(
      position.latitude,
      position.longitude,
    );

    // Call Police
    await SOSService.makeCall("100");
    print("Before Siren");
    // 🚨 Start Siren AFTER calling police
    await SirenService.startSiren();
    print("After Siren");
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🚨 Emergency SOS Activated"),
      ),
    );

    // Optional: Show dialog with Stop Siren button
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("🚨 Emergency Activated"),
        content: const Text(
          "SOS sent successfully.\nPolice contacted.\nEmergency siren is active.",
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () async {
              await SirenService.stopSiren();

              await VoiceSOSService.startListening(() async {
                await triggerSOS();
              });

              Navigator.pop(context);
            },
            icon: const Icon(Icons.volume_off),
            label: const Text("STOP SIREN"),
          ),
        ],
      ),
    );
  }
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkRisk();
    });

    // Voice SOS
    VoiceSOSService.startListening(() async {
      print("🔥 Voice Detected");
      await triggerSOS();
    });

    // Shake SOS
    ShakeService.start(() async {
      print("🔥 SHAKE DETECTED");
      await triggerSOS();
    });
  }

  @override
  Widget build(BuildContext context) {
    String risk = demoMode
        ? "HIGH"
        : AIService.predictRisk(
      hour: DateTime.now().hour,
      crimeRate: AIService.getCrimeRate("Hasanparthy"),
      speed: AIService.randomSpeed(),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🛡️ Guardian AI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              'Welcome to Guardian AI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Your offline-first personal safety companion',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 20),
            Card(
              child: SwitchListTile(
                title: const Text(
                  "🎭 Demo Mode",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  "Turn ON to simulate High Risk",
                ),
                value: demoMode,
                onChanged: (value) async {
                  setState(() {
                    demoMode = value;
                  });

                  await checkRisk();
                },
              ),
            ),

            const SizedBox(height: 20),
            // SAFETY STATUS
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield,
                        color: Colors.green,
                        size: 35,
                      ),
                    ),

                    const SizedBox(width: 15),

                     Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Safety Status',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          risk == "HIGH"
                              ? "High Risk Detected"
                              : risk == "MEDIUM"
                              ? "Stay Alert"
                              : "You are currently safe",
                          style: TextStyle(
                            color: risk == "HIGH"
                                ? Colors.red
                                : risk == "MEDIUM"
                                ? Colors.orange
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // SOS BUTTON
            SizedBox(
              width: double.infinity,
              height: 85,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  // Show loading message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("📍 Getting your current location..."),
                    ),
                  );

                  // Get current location
                  Position? position = await SOSService.getCurrentPosition();

                  if (position == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("❌ Unable to get location"),
                      ),
                    );
                    return;
                  }

                  // Read emergency contacts
                  final box = Hive.box<ContactModel>('contacts');

                  List<String> numbers = [];

                  for (var contact in box.values) {
                    numbers.add(contact.phone);
                  }

                  if (numbers.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("⚠️ No emergency contacts found"),
                      ),
                    );
                    return;
                  }

// Send SOS SMS


                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          demoMode
                              ? '🚨 HIGH RISK DETECTED'
                              : '🚨 SOS Activated',
                        ),

                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              demoMode
                                  ? "⚠️ AI detected HIGH RISK.\nMove to the nearest safe place."
                                  : "📍 Current Location Found!",
                            ),

                            const SizedBox(height: 15),

                            Text("Latitude : ${position.latitude}"),

                            Text("Longitude : ${position.longitude}"),

                            if (demoMode) ...[
                              const SizedBox(height: 20),

                              const Divider(),

                              const Text(
                                "Nearest Safe Place",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              const ListTile(
                                leading: Icon(
                                  Icons.local_police,
                                  color: Colors.blue,
                                ),
                                title: Text(
                                  "Hasanparthy Police Station",
                                ),
                                subtitle: Text(
                                  "Approx. 800 meters",
                                ),
                              ),
                            ],
                          ],
                        ),

                        actions: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.local_police),
                            label: const Text("CALL POLICE"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              await SOSService.makeCall("100");
                            },
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.support_agent),
                            label: const Text("SHE TEAM"),
                            onPressed: () async {
                              await SOSService.makeCall("181");
                            },
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.local_hospital),
                            label: const Text("AMBULANCE"),
                            onPressed: () async {
                              await SOSService.makeCall("108");
                            },
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.contacts),
                            label: const Text("EMERGENCY CONTACTS"),
                            onPressed: () {

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ContactsScreen(),
                                ),
                              );

                            },
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.sms),
                            label: const Text('SEND SOS SMS'),
                            onPressed: () async {

                              if (numbers.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please add emergency contacts first',
                                    ),
                                  ),
                                );
                                return;
                              }

                              await SOSService.sendSOS(
                                numbers,
                                position.latitude,
                                position.longitude,
                              );
                            },
                          ),

                          ElevatedButton.icon(
                            icon: const Icon(Icons.map),
                            label: const Text('OPEN MAP'),
                            onPressed: () {
                              SOSService.openGoogleMaps(
                                position.latitude,
                                position.longitude,
                              );
                            },
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.place),
                            label: const Text("SAFE PLACES"),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SafePlacesScreen(),
                                ),
                              );
                            },
                          ),

                        ],
                      );
                    },
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("✅ SOS sent successfully"),
                    ),
                  );
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning, size: 32),
                    SizedBox(height: 4),
                    Text(
                      "QUICK SOS",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'AI Risk Prediction',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // RISK LEVEL
            Card(
              elevation: 3,

              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                ),
                title: const Text(
                  'Current Risk Level',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Random Forest AI prediction',
                ),
                trailing: Text(
                  risk,
                  style: TextStyle(
                    color: risk == "HIGH"
                        ? Colors.red
                        : risk == "MEDIUM"
                        ? Colors.orange
                        : Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),

            const Text(
              'Quick Access',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SafePlacesScreen(),
                      ),
                    );
                  },
                  child: _featureCard(
                    Icons.place,
                    "Safe Places",
                    "Nearby Help",
                    Colors.green,
                  ),
                ),


                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactsScreen(),
                      ),
                    );
                  },
                  child: _featureCard(
                    Icons.contacts,
                    'Emergency Contacts',
                    'Trusted People',
                    Colors.orange,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SelfDefenseScreen(),
                      ),
                    );
                  },
                  child: _featureCard(
                    Icons.security,
                    "Self Defence",
                    "Safety Tips",
                    Colors.purple,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LanguageScreen(),
                      ),
                    );
                  },
                  child: _featureCard(
                    Icons.language,
                    "Voice Language",
                    "Choose Language",
                    Colors.blue,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    JourneyTimerService.start(
                      minutes: 30,
                      onTimeout: () async {
                        await triggerSOS();
                      },
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("🕒 Journey Timer Started (30 minutes)"),
                      ),
                    );
                  },
                  child: _featureCard(
                    Icons.timer,
                    "Journey Timer",
                    "Travel Safely",
                    Colors.teal,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    JourneyTimerService.stop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("✅ Journey Completed Safely"),
                      ),
                    );
                  },
                  child: _featureCard(
                    Icons.check_circle,
                    "I'm Safe",
                    "Stop Timer",
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Offline Protection Active',
              style: TextStyle(
                color: Colors.indigo,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Critical safety features can continue working without internet.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'SOS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    ShakeService.stop();
    super.dispose();
  }

  static Widget _featureCard(
      IconData icon,
      String title,
      String subtitle,
      Color color,
      ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 35,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
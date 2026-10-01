import 'package:flutter/material.dart';

class SelfDefenseScreen extends StatelessWidget {
  const SelfDefenseScreen({super.key});

  final List<Map<String, String>> tips = const [

    {
      "title":"Carry Pepper Spray",
      "desc":"Keep pepper spray easily accessible while travelling."
    },

    {
      "title":"Share Live Location",
      "desc":"Share your trip with trusted family members."
    },

    {
      "title":"Stay in Crowded Areas",
      "desc":"Avoid isolated roads especially during night."
    },

    {
      "title":"Emergency Numbers",
      "desc":"Police 100 | Ambulance 108 | She Team 181"
    },

    {
      "title":"Basic Self Defence",
      "desc":"Aim for eyes, nose or knees if attacked and run immediately."
    },

    {
      "title":"Trust Your Instinct",
      "desc":"If something feels wrong, leave immediately."
    },

  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Self Defence Tips"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),

      body: ListView.builder(

        itemCount: tips.length,

        itemBuilder: (context,index){

          final tip = tips[index];

          return Card(

            margin: const EdgeInsets.all(10),

            child: ListTile(

              leading: const Icon(
                Icons.shield,
                color: Colors.purple,
              ),

              title: Text(tip["title"]!),

              subtitle: Text(tip["desc"]!),

            ),

          );

        },

      ),

    );

  }
}
import 'package:flutter/material.dart';
import '../services/voice_sos_service.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {

  String selected = "en_US";

  final Map<String,String> languages = {
    "English":"en_US",
    "Hindi":"hi_IN",
    "Telugu":"te_IN",
    "Tamil":"ta_IN",
    "Kannada":"kn_IN",
    "Malayalam":"ml_IN",
    "Bengali":"bn_IN",
    "Marathi":"mr_IN",
    "Gujarati":"gu_IN",
    "Punjabi":"pa_IN",
    "Urdu":"ur_PK",
    "French":"fr_FR",
    "Spanish":"es_ES",
    "German":"de_DE",
    "Italian":"it_IT",
    "Portuguese":"pt_PT",
    "Russian":"ru_RU",
    "Japanese":"ja_JP",
    "Korean":"ko_KR",
    "Chinese":"zh_CN",
    "Arabic":"ar_SA",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voice SOS Language")),
      body: ListView(
        children: languages.entries.map((e){

          return RadioListTile<String>(
            title: Text(e.key),
            value: e.value,
            groupValue: selected,
            onChanged: (v){
              setState(() {
                selected = v!;
              });

              VoiceSOSService.setLanguage(v!);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${e.key} Selected"),
                ),
              );
            },
          );

        }).toList(),
      ),
    );
  }
}
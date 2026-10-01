import 'package:speech_to_text/speech_to_text.dart';

class VoiceSOSService {
  static final SpeechToText speech = SpeechToText();

  static bool _enabled = false;
  static bool _triggered = false;

  // Default language
  static String selectedLocale = "en_US";

  // Change language from settings
  static void setLanguage(String locale) {
    selectedLocale = locale;
  }

  static Future<void> startListening(Function onSOS) async {
    if (_enabled) return;

    _enabled = true;

    bool available = await speech.initialize(
      onStatus: (status) async {
        print("STATUS: $status");

        if (!_enabled) return;

        if (status == "done" || status == "notListening") {
          await Future.delayed(const Duration(milliseconds: 500));

          if (_enabled && !_triggered) {
            _enabled = false;
            startListening(onSOS);
          }
        }
      },
      onError: (error) async {
        print("ERROR: ${error.errorMsg}");

        if (!_enabled) return;

        await Future.delayed(const Duration(seconds: 1));

        if (_enabled && !_triggered) {
          _enabled = false;
          startListening(onSOS);
        }
      },
    );

    if (!available) {
      _enabled = false;
      return;
    }

    await speech.listen(
      localeId: selectedLocale,
      partialResults: true,
      listenMode: ListenMode.dictation,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        String words = result.recognizedWords.toLowerCase();

        print("HEARD: $words");

        if (_triggered) return;

        if (_containsSOSWord(words)) {
          _triggered = true;
          _enabled = false;

          speech.stop();

          onSOS();
        }
      },
    );
  }

  static bool _containsSOSWord(String words) {
    List<String> sosWords = [

      // English
      "help",
      "save me",
      "emergency",
      "danger",
      "please help",

      // Hindi
      "बचाओ",
      "मदद",
      "मुझे बचाओ",
      "आपातकाल",

      // Telugu
      "కాపాడు",
      "సహాయం",
      "నన్ను కాపాడు",
      "ఎమర్జెన్సీ",

      // Tamil
      "காப்பாற்றுங்கள்",
      "உதவி",
      "என்னை காப்பாற்றுங்கள்",

      // Kannada
      "ಸಹಾಯ",
      "ನನ್ನನ್ನು ಉಳಿಸಿ",

      // Malayalam
      "സഹായം",
      "എന്നെ രക്ഷിക്കൂ",

      // Bengali
      "বাঁচাও",
      "সাহায্য",

      // Marathi
      "मदत",
      "वाचवा",

      // Gujarati
      "મદદ",
      "બચાવો",

      // Punjabi
      "ਮਦਦ",
      "ਬਚਾਓ",

      // Urdu
      "مدد",
      "بچاؤ",

      // Arabic
      "نجدة",
      "ساعدني",

      // French
      "aidez-moi",
      "urgence",

      // Spanish
      "ayuda",
      "emergencia",

      // German
      "hilfe",
      "notfall",

      // Italian
      "aiuto",
      "emergenza",

      // Portuguese
      "socorro",
      "emergência",

      // Russian
      "помогите",
      "спасите",

      // Japanese
      "助けて",

      // Korean
      "도와주세요",

      // Chinese
      "救命",
      "帮帮我"
    ];

    for (String word in sosWords) {
      if (words.contains(word.toLowerCase())) {
        return true;
      }
    }

    return false;
  }

  static Future<void> stopListening() async {
    _enabled = false;
    _triggered = false;

    if (speech.isListening) {
      await speech.stop();
    }
  }
}
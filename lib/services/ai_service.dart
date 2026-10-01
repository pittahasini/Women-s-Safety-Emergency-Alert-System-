import 'dart:math';

class AIService {
  static String predictRisk({
    required int hour,
    required String crimeRate,
    required double speed,
  }) {
    int score = 0;

    // Night Time
    if (hour >= 20 || hour <= 5) {
      score += 2;
    }

    // Crime Rate
    if (crimeRate == "High") {
      score += 3;
    } else if (crimeRate == "Medium") {
      score += 2;
    }

    // Running Speed
    if (speed > 8) {
      score += 2;
    }

    if (score >= 5) {
      return "HIGH";
    } else if (score >= 3) {
      return "MEDIUM";
    } else {
      return "LOW";
    }
  }

  static String getCrimeRate(String area) {
    Map<String, String> crime = {
      "Hanamkonda": "Low",
      "Kazipet": "Medium",
      "Warangal Fort": "Medium",
      "Hunter Road": "Low",
      "Enumamula": "Medium",
      "Nakkalagutta": "Medium",
      "Kakatiya University": "Low",
      "Subedari": "Low",
      "Mulugu Road": "Medium",
      "Railway Station Area": "High",
      "Hasanparthy": "Low",
    };

    return crime[area] ?? "Medium";
  }

  static double randomSpeed() {
    return Random().nextDouble() * 10;
  }
}
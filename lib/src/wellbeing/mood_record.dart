enum MoodValence { veryLow, low, neutral, good, veryGood }

enum MoodEnergy { low, medium, high }

enum MoodEmotion { calm, happy, tired, anxious, frustrated, sad, other }

enum MoodContext { work, sleep, family, health, social, weather, exercise }

extension MoodValue on MoodValence {
  String get value => switch (this) {
    MoodValence.veryLow => 'very_low',
    MoodValence.low => 'low',
    MoodValence.neutral => 'neutral',
    MoodValence.good => 'good',
    MoodValence.veryGood => 'very_good',
  };

  static MoodValence fromValue(String value) => switch (value) {
    'very_low' => MoodValence.veryLow,
    'low' => MoodValence.low,
    'good' => MoodValence.good,
    'very_good' => MoodValence.veryGood,
    _ => MoodValence.neutral,
  };
}

class MoodRecord {
  const MoodRecord({
    required this.id,
    required this.recordedAt,
    required this.valence,
    this.energy,
    this.emotion,
    this.context,
    this.note,
  });

  final String id;
  final DateTime recordedAt;
  final MoodValence valence;
  final MoodEnergy? energy;
  final MoodEmotion? emotion;
  final MoodContext? context;
  final String? note;
}

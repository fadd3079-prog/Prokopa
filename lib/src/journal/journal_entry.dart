enum JournalEntryType { free, guided }

enum JournalEntryStatus { draft, saved }

extension JournalEntryTypeValue on JournalEntryType {
  String get value => this == JournalEntryType.free ? 'free' : 'guided';

  static JournalEntryType fromValue(String value) =>
      value == 'guided' ? JournalEntryType.guided : JournalEntryType.free;
}

extension JournalEntryStatusValue on JournalEntryStatus {
  String get value => this == JournalEntryStatus.draft ? 'draft' : 'saved';

  static JournalEntryStatus fromValue(String value) =>
      value == 'saved' ? JournalEntryStatus.saved : JournalEntryStatus.draft;
}

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.body,
    required this.tags,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.title,
    this.mood,
    this.energy,
    this.guidedResponses = const {},
    this.promptIndex = 0,
  });

  final String id;
  final DateTime date;
  final JournalEntryType type;
  final String body;
  final String? title;
  final String? mood;
  final String? energy;
  final List<String> tags;
  final Map<String, String> guidedResponses;
  final int promptIndex;
  final JournalEntryStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntry copyWith({
    String? body,
    String? title,
    String? mood,
    String? energy,
    List<String>? tags,
    Map<String, String>? guidedResponses,
    int? promptIndex,
    JournalEntryStatus? status,
    DateTime? updatedAt,
  }) => JournalEntry(
    id: id,
    date: date,
    type: type,
    body: body ?? this.body,
    title: title ?? this.title,
    mood: mood ?? this.mood,
    energy: energy ?? this.energy,
    tags: tags ?? this.tags,
    guidedResponses: guidedResponses ?? this.guidedResponses,
    promptIndex: promptIndex ?? this.promptIndex,
    status: status ?? this.status,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

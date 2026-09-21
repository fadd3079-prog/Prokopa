enum AppAppearance { light, dark, system }

extension AppAppearanceValue on AppAppearance {
  String get value => switch (this) {
    AppAppearance.light => 'light',
    AppAppearance.dark => 'dark',
    AppAppearance.system => 'system',
  };

  static AppAppearance fromValue(String value) => switch (value) {
    'light' => AppAppearance.light,
    'dark' => AppAppearance.dark,
    _ => AppAppearance.system,
  };
}

class LocalProfile {
  const LocalProfile({
    required this.id,
    required this.name,
    required this.avatar,
    required this.appearance,
    required this.createdAt,
    this.focus,
  });

  final String id;
  final String name;
  final String avatar;
  final AppAppearance appearance;
  final DateTime createdAt;
  final String? focus;

  LocalProfile copyWith({
    String? name,
    String? avatar,
    AppAppearance? appearance,
    String? focus,
  }) {
    return LocalProfile(
      id: id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      appearance: appearance ?? this.appearance,
      createdAt: createdAt,
      focus: focus ?? this.focus,
    );
  }
}

/// A learner-facing string with one entry per language code, e.g.
/// `{'en': 'Cash reserve ratio', 'hi': 'नकद आरक्षित अनुपात'}`.
///
/// Every string shown to a learner is a [LocalizedString] so the platform is
/// multilingual from day one (epic E1.4). The validator enforces that all
/// declared languages are present before content can be published.
class LocalizedString {
  final Map<String, String> values;

  const LocalizedString(this.values);

  /// Accepts either a map (`{'en': '...'}`) or a bare string (treated as `en`).
  factory LocalizedString.fromJson(Object? json) {
    if (json is String) return LocalizedString({'en': json});
    if (json is Map) {
      return LocalizedString(
        json.map((k, v) => MapEntry(k.toString(), v.toString())),
      );
    }
    throw FormatException('Invalid LocalizedString: $json');
  }

  String? operator [](String lang) => values[lang];

  /// Resolve to [lang], falling back to [fallback] then to any available value.
  String resolve(String lang, {String fallback = 'en'}) =>
      values[lang] ??
      values[fallback] ??
      (values.isNotEmpty ? values.values.first : '');

  bool hasLanguage(String lang) => (values[lang] ?? '').trim().isNotEmpty;

  Iterable<String> get languages => values.keys;

  bool get isEmpty => values.values.every((v) => v.trim().isEmpty);

  Map<String, String> toJson() => Map.of(values);

  @override
  bool operator ==(Object other) =>
      other is LocalizedString && _mapEquals(values, other.values);

  @override
  int get hashCode =>
      Object.hashAllUnordered(values.entries.map((e) => Object.hash(e.key, e.value)));

  @override
  String toString() => 'LocalizedString($values)';
}

bool _mapEquals(Map<String, String> a, Map<String, String> b) {
  if (a.length != b.length) return false;
  for (final e in a.entries) {
    if (b[e.key] != e.value) return false;
  }
  return true;
}

class SupabaseConfig {
  static const _rawUrl = String.fromEnvironment('SUPABASE_URL');
  static const _rawAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static final url = _normalizeUrl(_required('SUPABASE_URL', _rawUrl));

  static String get anonKey => _required('SUPABASE_ANON_KEY', _rawAnonKey);

  static String _required(String name, String value) {
    if (value.trim().isEmpty) {
      throw StateError(
        'Missing $name. Run Flutter with --dart-define=$name=your-value.',
      );
    }
    return value;
  }

  static String _normalizeUrl(String value) {
    return value
        .trim()
        .replaceFirst(RegExp(r'/rest/v1/?$'), '')
        .replaceFirst(RegExp(r'/$'), '');
  }
}

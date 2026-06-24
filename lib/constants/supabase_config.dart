class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://kfoilzgakhuzaerwmhik.supabase.co/rest/v1/',
  );

  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtmb2lsemdha2h1emFlcndtaGlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIxOTAwMTksImV4cCI6MjA5Nzc2NjAxOX0.aQhfTJcLVxPCSQitqsgDNIsCwcG0Qx-Sck-5h0hcDJU',
  );
}

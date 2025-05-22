import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: "https://jagtmsjkgzmpivbqlddo.supabase.co",
      anonKey:
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphZ3Rtc2prZ3ptcGl2YnFsZGRvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc5MjM2NDQsImV4cCI6MjA2MzQ5OTY0NH0.v6VXrk9BFAt5EQBHcTmmKQEW9lvvNL-Pk9ekrEzz_Ao",
    );
  }
}



import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: "https://sfcierrntjwfwtpyebcv.supabase.co",
      anonKey:
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNmY2llcnJudGp3Znd0cHllYmN2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc5NDU3NzksImV4cCI6MjA2MzUyMTc3OX0.TRoL21PI-WSGPHL_HFUlB1FRWzteAgLNLj2qcwHYyGw",
    );
  }
}



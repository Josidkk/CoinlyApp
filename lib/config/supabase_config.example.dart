import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // IMPORTANTE: Reemplaza estos valores con tus credenciales de Supabase
  // Puedes encontrarlas en: https://app.supabase.com/project/_/settings/api

  static const String supabaseUrl = 'https://tu-proyecto.supabase.co';
  static const String supabaseAnonKey = 'tu-anon-key-aqui';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}

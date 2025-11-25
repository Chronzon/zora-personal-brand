import 'package:supabase_flutter/supabase_flutter.dart';

class GeminiService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> generateContent(
      String action, Map<String, dynamic> payload, String languageCode) async {
    try {
      final response = await _supabase.functions.invoke(
        'process-ai',
        body: {
          'action': action,
          'payload': payload,
          'language': languageCode,
        },
      );

      final data = response.data;
      if (data != null && data['result'] != null) {
        return data['result'];
      } else if (data != null && data['error'] != null) {
        throw Exception("AI Error: ${data['error']}");
      }

      return null;
    } catch (e) {
      print("Error calling Edge Function: $e");
      rethrow;
    }
  }
}

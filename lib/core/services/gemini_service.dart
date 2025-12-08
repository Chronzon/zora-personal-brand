import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:personal_branding_app/core/utils/result.dart';
import 'package:personal_branding_app/core/errors/failures.dart';
import 'package:personal_branding_app/core/errors/exceptions.dart';
import 'package:personal_branding_app/core/errors/error_handler.dart';
import 'i_ai_service.dart';

class GeminiService implements IAIService {
  final SupabaseClient _supabase;
  static const int _maxRetries = 3;
  static const Duration _timeout = Duration(seconds: 45); // Sedikit lebih lama untuk AI

  GeminiService(this._supabase);

  @override
  Future<Result<Map<String, dynamic>, Failure>> processAI({
    required String action,
    required Map<String, dynamic> payload,
    required String languageCode,
    int retryCount = 0,
  }) async {
    try {
      final response = await _supabase.functions
          .invoke(
            'process-ai',
            body: {
              'action': action,
              'payload': payload,
              'language': languageCode,
            },
          )
          .timeout(
            _timeout,
            onTimeout: () {
              throw NetworkException(
                'AI Request timed out after ${_timeout.inSeconds} seconds',
                code: 'TIMEOUT',
              );
            },
          );

      // Cek status HTTP dari Function
      if (response.status != 200) {
        return ResultFailure(_handleErrorResponse(response));
      }

      final data = response.data as Map<String, dynamic>?;

      if (data == null || data.isEmpty) {
        throw AIServiceException(
          'AI returned empty response',
          code: 'INVALID_RESPONSE',
        );
      }

      // Cek jika body response mengandung error flag dari AI logic
      if (data.containsKey('error')) {
         // Handle custom error response structure from Edge Function
         return ResultFailure(AIServiceFailure(message: data['error'].toString()));
      }

      return Success(data);

    } on NetworkException catch (e) {
      return ResultFailure(ErrorHandler.handleException(e));
    } on AIServiceException catch (e) {
      // Retry logic (Recursive)
      if (e.code == 'SERVICE_DOWN' && retryCount < _maxRetries) {
        await Future.delayed(Duration(seconds: (retryCount + 1) * 2));
        return processAI(
          action: action,
          payload: payload,
          languageCode: languageCode,
          retryCount: retryCount + 1,
        );
      }
      return ResultFailure(ErrorHandler.handleException(e));
    } catch (e, stackTrace) {
      return ResultFailure(ErrorHandler.handleException(e, stackTrace: stackTrace));
    }
  }

  Failure _handleErrorResponse(FunctionResponse response) {
    if (response.status == 504) return NetworkFailure.timeout();
    if (response.status >= 500) return ServerFailure.internal();
    return UnknownFailure(message: "AI Service Error: ${response.status}");
  }
}
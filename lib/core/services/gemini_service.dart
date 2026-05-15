import 'package:personal_branding_app/core/network/api_client.dart';
import 'package:personal_branding_app/core/utils/result.dart';
import 'package:personal_branding_app/core/errors/failures.dart';
import 'package:personal_branding_app/core/errors/exceptions.dart';
import 'package:personal_branding_app/core/errors/error_handler.dart';
import 'i_ai_service.dart';

class GeminiService implements IAIService {
  final ApiClient _apiClient;
  static const int _maxRetries = 3;
  static const Duration _timeout =
      Duration(seconds: 120); // Real AI providers can take longer than mocks.

  GeminiService(this._apiClient);

  @override
  Future<Result<Map<String, dynamic>, Failure>> processAI({
    required String action,
    required Map<String, dynamic> payload,
    required String languageCode,
    int retryCount = 0,
  }) async {
    try {
      final data = await _apiClient.post('/process-ai', body: {
        'action': action,
        'payload': payload,
        'language': languageCode,
      }).timeout(
        _timeout,
        onTimeout: () {
          throw NetworkException(
            'AI Request timed out after ${_timeout.inSeconds} seconds',
            code: 'TIMEOUT',
          );
        },
      );

      if (data is! Map<String, dynamic> || data.isEmpty) {
        throw AIServiceException(
          'AI returned empty response',
          code: 'INVALID_RESPONSE',
        );
      }

      // Cek jika body response mengandung error flag dari AI logic
      if (data.containsKey('error')) {
        // Handle custom error response structure from Edge Function
        return ResultFailure(
            AIServiceFailure(message: data['error'].toString()));
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
      return ResultFailure(
          ErrorHandler.handleException(e, stackTrace: stackTrace));
    }
  }
}

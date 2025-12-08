import '../utils/result.dart';
import '../errors/failures.dart';

abstract class IAIService {
  Future<Result<Map<String, dynamic>, Failure>> processAI({
    required String action,
    required Map<String, dynamic> payload,
    required String languageCode,
  });
}
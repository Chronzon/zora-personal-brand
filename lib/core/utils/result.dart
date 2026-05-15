abstract class Result<S, F> {
  const Result();

  bool get isSuccess => this is Success<S, F>;
  bool get isFailure => this is ResultFailure<S, F>;

  S get success => (this as Success<S, F>).value;
  F get failure => (this as ResultFailure<S, F>).error;

  /// Execute function if success
  Result<T, F> map<T>(T Function(S) mapper) {
    if (isSuccess) {
      return Success(mapper(success));
    }
    return ResultFailure(failure);
  }

  /// Execute async function if success
  Future<Result<T, F>> mapAsync<T>(Future<T> Function(S) mapper) async {
    if (isSuccess) {
      final result = await mapper(success);
      return Success(result);
    }
    return ResultFailure(failure);
  }

  /// Execute function based on result
  T fold<T>({
    required T Function(S) onSuccess,
    required T Function(F) onFailure,
  }) {
    if (isSuccess) {
      return onSuccess(success);
    }
    return onFailure(failure);
  }

  /// Execute async function based on result
  Future<T> foldAsync<T>({
    required Future<T> Function(S) onSuccess,
    required Future<T> Function(F) onFailure,
  }) {
    if (isSuccess) {
      return onSuccess(success);
    }
    return onFailure(failure);
  }
}

class Success<S, F> extends Result<S, F> {
  final S value;
  const Success(this.value);

  @override
  String toString() => 'Success($value)';
}

class ResultFailure<S, F> extends Result<S, F> {
  final F error;
  const ResultFailure(this.error);

  @override
  String toString() => 'ResultFailure($error)';
}

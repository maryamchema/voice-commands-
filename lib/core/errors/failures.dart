abstract class Failure {
  final String message;
  final StackTrace stackTrace;

  Failure(this.message, [this.stackTrace = StackTrace.empty]);
}

class CacheFailure extends Failure {
  CacheFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace ?? StackTrace.current);
}

class SpeechRecognitionFailure extends Failure {
  SpeechRecognitionFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace ?? StackTrace.current);
}

class LLMProcessingFailure extends Failure {
  LLMProcessingFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace ?? StackTrace.current);
}

class ValidationFailure extends Failure {
  ValidationFailure(String message) : super(message);
}

class RepositoryFailure extends Failure {
  final StackTrace stackTrace;

  RepositoryFailure(String message, this.stackTrace) : super(message);
}

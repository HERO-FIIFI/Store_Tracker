/// A unified failure model for the application
/// 
/// Differences from exceptions:
/// 1. Failures represent expected error cases
/// 2. Exceptions are for unexpected/programmatic errors
/// 3. Failures are part of the domain model
abstract class Failure {
  final String message;
  final String? code; // For analytics/tracking
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  const Failure({
    required this.message,
    this.code,
    this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Short description for UI display
  String get shortMessage => message;

  /// Detailed description for debugging
  String get debugMessage => '[${timestamp.toIso8601String()}] $message';

  /// Creates a failure from an exception
  factory Failure.fromException(Exception e) {
    if (e is BaseException) {
      return _mapExceptionToFailure(e);
    }
    return UnexpectedFailure(
      message: 'An unexpected error occurred',
      originalException: e,
    );
  }

  static Failure _mapExceptionToFailure(BaseException e) {
    return switch (e) {
      InsufficientStockException() => StockFailure.insufficientStock(
          productId: e.productId,
          requested: e.requested,
          available: e.available,
        ),
      NegativeAmountException() => ValidationFailure.negativeValue(
          value: e.invalidAmount,
        ),
      NoInternetException() => NetworkFailure.noInternet(),
      ApiTimeoutException() => NetworkFailure.timeout(
          duration: e.timeout,
        ),
      _ => UnexpectedFailure(
          message: e.message,
          originalException: e,
        ),
    };
  }
}

// ---------------------------------------------------------------------------
// Core Failure Types
// ---------------------------------------------------------------------------

/// For completely unexpected errors
class UnexpectedFailure extends Failure {
  final dynamic originalException;
  final StackTrace? stackTrace;

  UnexpectedFailure({
    super.message = 'An unexpected error occurred',
    this.originalException,
    this.stackTrace,
    super.code = 'UNEXPECTED',
  });

  @override
  String get debugMessage => 
      '${super.debugMessage}\nOriginal: $originalException\n$stackTrace';
}

/// For failures that need temporary user action
class RecoverableFailure extends Failure {
  final VoidCallback? recoveryAction;
  final String recoveryPrompt;

  const RecoverableFailure({
    required super.message,
    this.recoveryAction,
    this.recoveryPrompt = 'Try again',
    super.code,
  });
}

// ---------------------------------------------------------------------------
// Domain Failures (Business Logic)
// ---------------------------------------------------------------------------

/// Stock/inventory related failures
class StockFailure extends Failure {
  static const _domainCode = 'STOCK';

  StockFailure._({
    required super.message,
    required String subCode,
    super.details,
  }) : super(code: '${_domainCode}_$subCode');

  factory StockFailure.insufficientStock({
    required String productId,
    required int requested,
    required int available,
  }) = _InsufficientStockFailure;

  factory StockFailure.expiredItem({
    required String productId,
    required DateTime expiryDate,
  }) = _ExpiredItemFailure;
}

class _InsufficientStockFailure extends StockFailure {
  _InsufficientStockFailure({
    required String productId,
    required int requested,
    required int available,
  }) : super._(
          message: 'Only $available items available (requested: $requested)',
          subCode: 'INSUFFICIENT',
          details: {
            'productId': productId,
            'requested': requested,
            'available': available,
          },
        );
}

class _ExpiredItemFailure extends StockFailure {
  _ExpiredItemFailure({
    required String productId,
    required DateTime expiryDate,
  }) : super._(
          message: 'Product expired on ${expiryDate.yMd}',
          subCode: 'EXPIRED',
          details: {
            'productId': productId,
            'expiryDate': expiryDate.toIso8601String(),
          },
        );
}

/// Sales/transaction related failures
class SalesFailure extends Failure {
  static const _domainCode = 'SALES';

  SalesFailure._({
    required super.message,
    required String subCode,
    super.details,
  }) : super(code: '${_domainCode}_$subCode');

  factory SalesFailure.invalidTransaction({
    required String reason,
    required Map<String, dynamic> transactionData,
  }) = _InvalidTransactionFailure;
}

// ---------------------------------------------------------------------------
// Infrastructure Failures
// ---------------------------------------------------------------------------

class NetworkFailure extends Failure {
  static const _domainCode = 'NETWORK';

  NetworkFailure._({
    required super.message,
    required String subCode,
    super.details,
  }) : super(code: '${_domainCode}_$subCode');

  factory NetworkFailure.noInternet() = _NoInternetFailure;
  factory NetworkFailure.timeout({required Duration duration}) = _TimeoutFailure;
}

class _NoInternetFailure extends NetworkFailure {
  _NoInternetFailure()
      : super._(
          message: 'No internet connection',
          subCode: 'NO_INTERNET',
          details: {'retryable': true},
        );
}

class _TimeoutFailure extends NetworkFailure {
  _TimeoutFailure({required Duration duration})
      : super._(
          message: 'Request timed out after ${duration.inSeconds}s',
          subCode: 'TIMEOUT',
          details: {
            'duration': duration.inSeconds,
            'retryable': true,
          },
        );
}

class StorageFailure extends Failure {
  static const _domainCode = 'STORAGE';

  StorageFailure._({
    required super.message,
    required String subCode,
    super.details,
  }) : super(code: '${_domainCode}_$subCode');

  factory StorageFailure.quotaExceeded({required int used, required int limit}) =
      _StorageQuotaExceededFailure;
}

// ---------------------------------------------------------------------------
// Presentation Failures
// ---------------------------------------------------------------------------

class ValidationFailure extends Failure {
  static const _domainCode = 'VALIDATION';

  ValidationFailure._({
    required super.message,
    required String subCode,
    super.details,
  }) : super(code: '${_domainCode}_$subCode');

  factory ValidationFailure.negativeValue({required double value}) =
      _NegativeValueFailure;

  factory ValidationFailure.invalidEmail({required String email}) =
      _InvalidEmailFailure;
}

// ---------------------------------------------------------------------------
// Extensions & Utilities
// ---------------------------------------------------------------------------

extension FailureExtensions on Failure {
  /// Whether the failure can be recovered from
  bool get isRecoverable => this is RecoverableFailure;

  /// Converts to a user-friendly message with optional context
  String toUserMessage({bool debug = false}) {
    return debug ? debugMessage : shortMessage;
  }
}

extension DateTimeExtensions on DateTime {
  String get yMd => '$year-$month-$day';
}

/// Helper for Either pattern (functional error handling)
typedef Result<T> = Either<Failure, T>;

/// Helper for failure-aware functions
mixin FailureHandler {
  Future<Result<T>> handleFailures<T>(Future<T> Function() callback) async {
    try {
      return Right(await callback());
    } on BaseException catch (e) {
      return Left(Failure.fromException(e));
    } catch (e, stackTrace) {
      return Left(
        UnexpectedFailure(
          originalException: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
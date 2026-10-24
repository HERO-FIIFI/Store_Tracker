/// Application-specific exceptions hierarchy
/// 
/// Structure:
/// 1. BaseException (root)
/// 2. Domain exceptions (business logic failures)
/// 3. Infrastructure exceptions (technical failures)
/// 4. Presentation exceptions (UI-related failures)
abstract class BaseException implements Exception {
  final String message;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  const BaseException({
    required this.message,
    this.stackTrace,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  String get formattedTime => 
      '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';

  @override
  String toString() => '$runtimeType: $message\n${stackTrace ?? 'No stack trace'}';
}

// -----------------------------------------------------------------------------
// Domain Exceptions (Business Logic Failures)
// -----------------------------------------------------------------------------

/// Thrown when business rules are violated
class BusinessRuleException extends BaseException {
  const BusinessRuleException({
    required super.message,
    super.stackTrace,
  });
}

class InsufficientStockException extends BusinessRuleException {
  final String productId;
  final int requested;
  final int available;

  InsufficientStockException({
    required this.productId,
    required this.requested,
    required this.available,
    super.stackTrace,
  }) : super(
          message: 'Insufficient stock for product $productId. '
                   'Requested: $requested, Available: $available',
        );
}

class NegativeAmountException extends BusinessRuleException {
  final double invalidAmount;

  NegativeAmountException(this.invalidAmount, {super.stackTrace})
      : super(
          message: 'Negative amount not allowed: $invalidAmount',
        );
}

class DuplicateProductException extends BusinessRuleException {
  final String productName;

  DuplicateProductException(this.productName, {super.stackTrace})
      : super(
          message: 'Product "$productName" already exists',
        );
}

// -----------------------------------------------------------------------------
// Auth & User Management Exceptions
// -----------------------------------------------------------------------------

class AuthException extends BaseException {
  const AuthException({
    required super.message,
    super.stackTrace,
  });
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException({super.stackTrace})
      : super(message: 'Invalid email or password');
}

class AccountLockedException extends AuthException {
  AccountLockedException({super.stackTrace})
      : super(message: 'Account temporarily locked');
}

class EmailNotVerifiedException extends AuthException {
  EmailNotVerifiedException({super.stackTrace})
      : super(message: 'Email not verified');
}

// -----------------------------------------------------------------------------
// Infrastructure Exceptions (Technical Failures)
// -----------------------------------------------------------------------------

/// Thrown when network operations fail
class NetworkException extends BaseException {
  const NetworkException({
    required super.message,
    super.stackTrace,
  });
}

class NoInternetException extends NetworkException {
  NoInternetException({super.stackTrace})
      : super(message: 'No internet connection');
}

class ApiTimeoutException extends NetworkException {
  final Duration timeout;

  ApiTimeoutException(this.timeout, {super.stackTrace})
      : super(
          message: 'Request timed out after ${timeout.inSeconds} seconds',
        );
}

/// Thrown when Firebase operations fail
class FirebaseException extends BaseException {
  final String code;

  const FirebaseException({
    required this.code,
    required super.message,
    super.stackTrace,
  });

  factory FirebaseException.fromFirebase(FirebaseException firebaseError) {
    return FirebaseException(
      code: firebaseError.code,
      message: _firebaseErrorMessages[firebaseError.code] ?? 
              firebaseError.message,
      stackTrace: firebaseError.stackTrace,
    );
  }

  static const _firebaseErrorMessages = {
    'permission-denied': 'Operation not permitted',
    'not-found': 'Requested document not found',
    // Add more Firebase error code mappings
  };
}

/// Thrown when local storage operations fail
class StorageException extends BaseException {
  const StorageException({
    required super.message,
    super.stackTrace,
  });
}

class CacheWriteException extends StorageException {
  CacheWriteException({super.stackTrace})
      : super(message: 'Failed to write to local cache');
}

// -----------------------------------------------------------------------------
// Presentation Exceptions (UI-Related Failures)
// -----------------------------------------------------------------------------

class InvalidInputException extends BaseException {
  final String fieldName;

  InvalidInputException({
    required this.fieldName,
    required super.message,
    super.stackTrace,
  });
}

class RouteException extends BaseException {
  final String routeName;

  RouteException({
    required this.routeName,
    super.stackTrace,
  }) : super(message: 'Route $routeName not found');
}

// -----------------------------------------------------------------------------
// Exception Utilities
// -----------------------------------------------------------------------------

extension ExceptionExtensions on Exception {
  /// Converts any exception to a user-friendly message
  String toUserMessage() {
    return switch (this) {
      BaseException() => message,
      FirebaseException() => FirebaseException.fromFirebase(this).message,
      _ => 'An unexpected error occurred',
    };
  }
}

/// Helper for creating error-aware functions
mixin ExceptionHandler {
  Future<T> handleExceptions<T>(Future<T> Function() callback) async {
    try {
      return await callback();
    } on BaseException catch (e) {
      // Already handled exceptions
      rethrow;
    } on FirebaseException catch (e) {
      throw FirebaseException.fromFirebase(e);
    } catch (e, stackTrace) {
      throw BaseException(
        message: 'Unexpected error: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }
}
/// Advanced logging utility with:
/// - Multiple log levels
/// - Crash reporting
/// - Analytics integration
/// - Sensitive data filtering
library logger;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:stack_trace/stack_trace.dart';

// Import your analytics/crash reporting services
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:sentry/sentry.dart';

class AppLogger {
  static final _logger = Logger('StoreTracker');

  static bool _isInitialized = false;
  static LogLevel _minLogLevel = kDebugMode ? LogLevel.verbose : LogLevel.warning;
  static final Set<String> _sensitiveKeywords = {
    'password',
    'token',
    'secret',
    'creditcard',
    'ssn',
  };

  /// Initialize logger with optional crash reporting
  static void initialize({
    LogLevel minLevel = LogLevel.info,
    bool enableCrashReporting = true,
    bool enableAnalyticsLogging = false,
  }) {
    if (_isInitialized) return;

    _minLogLevel = minLevel;
    _isInitialized = true;

    // Setup logging framework
    Logger.root.level = _logLevelToLoggingLevel(minLevel);
    Logger.root.onRecord.listen(_logHandler);

    if (enableCrashReporting) {
      _setupCrashReporting();
    }

    if (enableAnalyticsLogging) {
      _setupAnalyticsLogging();
    }
  }

  /// Set minimum log level
  static void setMinLogLevel(LogLevel level) {
    _minLogLevel = level;
    Logger.root.level = _logLevelToLoggingLevel(level);
  }

  /// Log verbose message (for detailed debugging)
  static void v(String message, [dynamic data, StackTrace? stackTrace]) {
    _log(LogLevel.verbose, message, data, stackTrace);
  }

  /// Log debug message (for general debugging)
  static void d(String message, [dynamic data, StackTrace? stackTrace]) {
    _log(LogLevel.debug, message, data, stackTrace);
  }

  /// Log info message (for notable events)
  static void i(String message, [dynamic data, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, data, stackTrace);
  }

  /// Log warning message (for potential issues)
  static void w(String message, [dynamic data, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, data, stackTrace);
  }

  /// Log error message (for handled exceptions)
  static void e(String message, [dynamic data, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, data, stackTrace);
  }

  /// Log critical error (for app crashes)
  static void c(String message, [dynamic data, StackTrace? stackTrace]) {
    _log(LogLevel.critical, message, data, stackTrace);
  }

  /// Track event with analytics
  static void trackEvent(String eventName, [Map<String, dynamic>? params]) {
    if (!_isInitialized) return;
    
    final sanitizedParams = _sanitizeData(params);
    _logger.info('EVENT: $eventName - $sanitizedParams');
    
    // Send to analytics service
    // AnalyticsService.track(eventName, sanitizedParams);
  }

  static void _log(
    LogLevel level,
    String message,
    dynamic data,
    StackTrace? stackTrace,
  ) {
    if (!_isInitialized || level.index < _minLogLevel.index) return;

    final sanitizedMessage = _sanitizeMessage(message);
    final sanitizedData = _sanitizeData(data);

    Logger.root.log(
      _logLevelToLoggingLevel(level),
      sanitizedMessage,
      sanitizedData,
      stackTrace ?? Trace.current(),
    );
  }

  static void _logHandler(LogRecord record) {
    final message = '${record.level.name}: ${record.time}: ${record.message}';
    final error = record.error;
    final stackTrace = record.stackTrace;

    // Print to console
    debugPrint(message);
    if (error != null) debugPrint('Error: $error');
    if (stackTrace != null) debugPrint('Stack: $stackTrace');

    // Send to crash reporting for errors
    if (record.level >= Level.SEVERE) {
      _reportError(record.error, stackTrace);
    }
  }

  static void _setupCrashReporting() {
    // Initialize crash reporting service
    // FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    // Sentry.init(...);
  }

  static void _setupAnalyticsLogging() {
    // Setup analytics service
  }

  static void _reportError(dynamic error, StackTrace? stackTrace) {
    if (error == null) return;

    // Filter out sensitive data
    final cleanError = error is String ? _sanitizeMessage(error) : error;
    
    // Send to crash reporting
    // FirebaseCrashlytics.instance.recordError(cleanError, stackTrace);
    // Sentry.captureException(cleanError, stackTrace: stackTrace);
  }

  static String _sanitizeMessage(String message) {
    if (message.isEmpty) return message;
    
    // Replace sensitive data
    for (final keyword in _sensitiveKeywords) {
      if (message.toLowerCase().contains(keyword)) {
        return message.replaceAll(RegExp(keyword, caseSensitive: false), '***');
      }
    }
    return message;
  }

  static dynamic _sanitizeData(dynamic data) {
    if (data is! Map) return data;
    
    final cleanData = <String, dynamic>{};
    for (final entry in (data as Map).entries) {
      final key = entry.key.toString();
      final value = entry.value;
      
      if (_sensitiveKeywords.any((kw) => key.toLowerCase().contains(kw))) {
        cleanData[key] = '***';
      } else if (value is String) {
        cleanData[key] = _sanitizeMessage(value);
      } else {
        cleanData[key] = value;
      }
    }
    return cleanData;
  }

  static Level _logLevelToLoggingLevel(LogLevel level) {
    return switch (level) {
      LogLevel.verbose => Level.FINEST,
      LogLevel.debug => Level.FINE,
      LogLevel.info => Level.INFO,
      LogLevel.warning => Level.WARNING,
      LogLevel.error => Level.SEVERE,
      LogLevel.critical => Level.SHOUT,
    };
  }
}

enum LogLevel {
  verbose, // Detailed debug information
  debug,   // General debug information
  info,    // Notable events
  warning, // Potential issues
  error,   // Handled exceptions
  critical,// Crash-level errors
}

// ---------------------------------------------------------------------------
// Usage Examples
// ---------------------------------------------------------------------------

/*
// Initialize early in app startup
void main() {
  AppLogger.initialize(
    minLevel: kDebugMode ? LogLevel.verbose : LogLevel.warning,
    enableCrashReporting: true,
  );
  
  runApp(MyApp());
}

// Typical usage:
class ProductRepository {
  Future<void> saveProduct(Product product) async {
    AppLogger.d('Saving product', {'id': product.id, 'name': product.name});
    
    try {
      await _api.saveProduct(product);
      AppLogger.i('Product saved successfully');
    } catch (e, stack) {
      AppLogger.e('Failed to save product', e, stack);
      rethrow;
    }
  }
}

// Tracking events:
AppLogger.trackEvent('product_view', {
  'product_id': '123',
  'category': 'electronics'
});
*/
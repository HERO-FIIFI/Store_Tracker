import 'dart:async';
import 'dart:io' show InternetAddress, SocketException;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Network status information
enum NetworkStatus {
  connected,
  disconnected,
  connecting,
}

/// Provides real-time network connectivity information and checks
/// 
/// Features:
/// 1. Real-time connectivity monitoring
/// 2. Active connection verification
/// 3. Platform-specific optimization
/// 4. Battery-efficient polling
class NetworkInfo {
  final Connectivity _connectivity;
  StreamController<NetworkStatus>? _statusController;
  Timer? _pollingTimer;
  NetworkStatus _lastStatus = NetworkStatus.disconnected;

  NetworkInfo({Connectivity? connectivity}) 
    : _connectivity = connectivity ?? Connectivity();

  /// Initialize network monitoring
  void initialize() {
    _statusController = StreamController<NetworkStatus>.broadcast(
      onListen: _startMonitoring,
      onCancel: _stopMonitoring,
    );
  }

  /// Stream of network status changes
  Stream<NetworkStatus> get onStatusChanged => 
      _statusController?.stream ?? Stream.empty();

  /// Current network status
  NetworkStatus get currentStatus => _lastStatus;

  /// Check if device has active internet connection (not just network access)
  Future<bool> get isConnected async {
    try {
      // First check if we have any network connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Then verify we can reach a remote server
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (e) {
      if (kDebugMode) print('Network check error: $e');
      return false;
    }
  }

  /// Start monitoring network status
  void _startMonitoring() {
    // Immediate check
    _checkConnection();

    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((result) {
      _checkConnection();
    });

    // Fallback polling for Android (some devices miss connectivity events)
    if (!kIsWeb && Platform.isAndroid) {
      _pollingTimer = Timer.periodic(
        const Duration(seconds: 15), 
        (_) => _checkConnection(),
      );
    }
  }

  /// Stop monitoring network status
  void _stopMonitoring() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Perform connection check and notify listeners
  Future<void> _checkConnection() async {
    final wasConnected = _lastStatus == NetworkStatus.connected;
    final nowConnected = await isConnected;

    if (wasConnected && nowConnected) return; // No change

    _lastStatus = nowConnected 
        ? NetworkStatus.connected 
        : NetworkStatus.disconnected;

    _statusController?.add(_lastStatus);
  }

  /// Dispose resources
  void dispose() {
    _stopMonitoring();
    _statusController?.close();
    _statusController = null;
  }

  /// Helper method to execute a function with retry on connection failure
  Future<T> executeWithRetry<T>(
    Future<T> Function() action, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    for (var attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        if (!await isConnected) {
          throw SocketException('No internet connection');
        }
        return await action();
      } catch (e) {
        if (attempt == maxRetries) rethrow;
        await Future.delayed(retryDelay * attempt);
      }
    }
    throw StateError('Unreachable code');
  }
}

// ---------------------------------------------------------------------------
// Extension Methods
// ---------------------------------------------------------------------------

extension NetworkStatusExtensions on NetworkStatus {
  bool get isConnected => this == NetworkStatus.connected;
  bool get isDisconnected => this == NetworkStatus.disconnected;

  String get displayName => switch (this) {
        NetworkStatus.connected => 'Connected',
        NetworkStatus.disconnected => 'Disconnected',
        NetworkStatus.connecting => 'Connecting...',
      };
}

// ---------------------------------------------------------------------------
// Usage Example
// ---------------------------------------------------------------------------

/*
// Initialize in your main app
final networkInfo = NetworkInfo();
networkInfo.initialize();

// Listen to changes
networkInfo.onStatusChanged.listen((status) {
  print('Network status changed to: ${status.displayName}');
});

// Check connectivity
if (await networkInfo.isConnected) {
  // Fetch data
}

// Dispose when done
networkInfo.dispose();
*/
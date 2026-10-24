import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceInputService {
  static final stt.SpeechToText _speech = stt.SpeechToText();
  static bool _initialized = false;

  /// Initialize speech recognition
  static Future<bool> initialize() async {
    if (_initialized) return true;

    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      return false;
    }

    // Initialize speech to text
    _initialized = await _speech.initialize(
      onError: (error) => print('Speech recognition error: $error'),
      onStatus: (status) => print('Speech recognition status: $status'),
    );

    return _initialized;
  }

  /// Check if speech recognition is available
  static Future<bool> isAvailable() async {
    if (!_initialized) {
      await initialize();
    }
    return _initialized;
  }

  /// Start listening for voice input
  static Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onPartialResult,
  }) async {
    if (!_initialized) {
      final success = await initialize();
      if (!success) {
        throw Exception('Failed to initialize speech recognition');
      }
    }

    if (_speech.isListening) {
      await _speech.stop();
    }

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        } else if (onPartialResult != null) {
          onPartialResult(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: onPartialResult != null,
      localeId: 'en_US',
    );
  }

  /// Stop listening
  static Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  /// Check if currently listening
  static bool get isListening => _speech.isListening;

  /// Parse numeric values from speech
  static double? parseNumericInput(String text) {
    // Remove common words
    final cleaned = text.toLowerCase()
        .replaceAll('dollars', '')
        .replaceAll('dollar', '')
        .replaceAll('pesos', '')
        .replaceAll('peso', '')
        .replaceAll('naira', '')
        .replaceAll('point', '.')
        .replaceAll('comma', '.')
        .trim();

    // Try to extract number
    final numberPattern = RegExp(r'\d+\.?\d*');
    final match = numberPattern.firstMatch(cleaned);

    if (match != null) {
      return double.tryParse(match.group(0)!);
    }

    // Handle word numbers
    return _parseWordNumbers(text);
  }

  /// Parse word numbers (e.g., "twenty five" -> 25)
  static double? _parseWordNumbers(String text) {
    final words = text.toLowerCase().split(' ');
    final wordToNumber = {
      'zero': 0,
      'one': 1,
      'two': 2,
      'three': 3,
      'four': 4,
      'five': 5,
      'six': 6,
      'seven': 7,
      'eight': 8,
      'nine': 9,
      'ten': 10,
      'eleven': 11,
      'twelve': 12,
      'thirteen': 13,
      'fourteen': 14,
      'fifteen': 15,
      'sixteen': 16,
      'seventeen': 17,
      'eighteen': 18,
      'nineteen': 19,
      'twenty': 20,
      'thirty': 30,
      'forty': 40,
      'fifty': 50,
      'sixty': 60,
      'seventy': 70,
      'eighty': 80,
      'ninety': 90,
      'hundred': 100,
      'thousand': 1000,
    };

    double total = 0;
    double current = 0;

    for (final word in words) {
      final value = wordToNumber[word];
      if (value != null) {
        if (value == 100 || value == 1000) {
          current = current == 0 ? value.toDouble() : current * value;
        } else {
          current += value.toDouble();
        }
      } else if (word == 'and') {
        continue;
      } else {
        // Check for decimal point
        if (word == 'point' || word == 'dot') {
          total += current;
          current = 0;
        }
      }
    }

    total += current;
    return total > 0 ? total : null;
  }

  /// Get available locales
  static Future<List<String>> getLocales() async {
    if (!_initialized) {
      await initialize();
    }
    final locales = await _speech.locales();
    return locales.map((l) => l.localeId).toList();
  }

  /// Cancel and cleanup
  static Future<void> cancel() async {
    await _speech.cancel();
  }
}

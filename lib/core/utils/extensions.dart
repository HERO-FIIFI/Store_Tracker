/// Collection of useful extensions for the Store Tracker app
library extensions;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// ---------------------------------------------------------------------------
// DateTime Extensions
// ---------------------------------------------------------------------------

extension DateTimeExtensions on DateTime {
  /// Formats date as "yyyy-MM-dd"
  String get yMd => DateFormat('yyyy-MM-dd').format(this);

  /// Formats date as "MMM d, yyyy"
  String get mmmDy => DateFormat('MMM d, yyyy').format(this);

  /// Formats date with time as "MMM d, yyyy h:mm a"
  String get mmmDyHm => DateFormat('MMM d, yyyy h:mm a').format(this);

  /// Returns only the date portion (time set to 00:00:00)
  DateTime get dateOnly => DateTime(year, month, day);

  /// Returns true if the date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns true if the date is in the current year
  bool get isCurrentYear {
    return year == DateTime.now().year;
  }

  /// Adds duration while handling daylight savings
  DateTime addSafe(Duration duration) {
    return add(duration).toLocal();
  }
}

// ---------------------------------------------------------------------------
// String Extensions
// ---------------------------------------------------------------------------

extension StringExtensions on String {
  /// Capitalizes first letter of each word
  String get capitalize {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Returns true if string is a valid numeric value
  bool get isNumeric {
    if (isEmpty) return false;
    return double.tryParse(this) != null;
  }

  /// Parses string as double or returns null
  double? get asDouble {
    return double.tryParse(this);
  }

  /// Parses string as int or returns null
  int? get asInt {
    return int.tryParse(this);
  }

  /// Truncates string with ellipsis if longer than [maxLength]
  String truncateWithEllipsis(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Returns initials from a name string
  String get initials {
    if (isEmpty) return '';
    final parts = split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }
}

// ---------------------------------------------------------------------------
// Number Extensions
// ---------------------------------------------------------------------------

extension NumExtensions on num {
  /// Formats number as currency
  String toCurrency({String symbol = '\$', int decimalDigits = 2}) {
    return NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    ).format(this);
  }

  /// Formats number with commas
  String get withCommas {
    return NumberFormat.decimalPattern().format(this);
  }

  /// Converts to a percentage string (0.85 → "85%")
  String toPercentage({int decimalDigits = 0}) {
    return '${(this * 100).toStringAsFixed(decimalDigits)}%';
  }

  /// Returns a sized box with width equal to the number
  SizedBox get widthBox => SizedBox(width: toDouble());

  /// Returns a sized box with height equal to the number
  SizedBox get heightBox => SizedBox(height: toDouble());
}

// ---------------------------------------------------------------------------
// List Extensions
// ---------------------------------------------------------------------------

extension ListExtensions<T> on List<T> {
  /// Returns a new list with unique elements
  List<T> get unique => toSet().toList();

  /// Groups elements by a key function
  Map<K, List<T>> groupBy<K>(K Function(T) keyFunction) {
    final map = <K, List<T>>{};
    for (final element in this) {
      final key = keyFunction(element);
      map.putIfAbsent(key, () => []).add(element);
    }
    return map;
  }

  /// Returns the element at [index] or null if out of bounds
  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Joins elements with comma and "and" for the last item
  String joinWithAnd([String separator = ', ']) {
    if (isEmpty) return '';
    if (length == 1) return first.toString();
    return '${sublist(0, length - 1).join(separator)} and ${last}';
  }
}

// ---------------------------------------------------------------------------
// Widget Extensions
// ---------------------------------------------------------------------------

extension WidgetExtensions on Widget {
  /// Wraps widget in a Center widget
  Widget get centered => Center(child: this);

  /// Wraps widget in a Padding widget
  Widget paddingAll(double value) {
    return Padding(
      padding: EdgeInsets.all(value),
      child: this,
    );
  }

  /// Wraps widget in a GestureDetector with onTap handler
  Widget onTap(VoidCallback onTap, {bool opaque = true}) {
    return GestureDetector(
      behavior: opaque ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
      onTap: onTap,
      child: this,
    );
  }

  /// Wraps widget in a tooltip
  Widget withTooltip(String message,
      {Decoration? decoration,
      double? height,
      bool? preferBelow,
      EdgeInsetsGeometry? padding,
      TextStyle? textStyle,
      Duration? waitDuration,
      EdgeInsetsGeometry? margin}) {
    return Tooltip(
      message: message,
      decoration: decoration,
      height: height,
      preferBelow: preferBelow,
      padding: padding,
      textStyle: textStyle,
      waitDuration: waitDuration,
      margin: margin,
      child: this,
    );
  }
}

// ---------------------------------------------------------------------------
// BuildContext Extensions
// ---------------------------------------------------------------------------

extension ContextExtensions on BuildContext {
  /// Returns screen size
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Returns screen width
  double get screenWidth => screenSize.width;

  /// Returns screen height
  double get screenHeight => screenSize.height;

  /// Returns text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Returns color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Returns true if dark mode is enabled
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Pushes a new route
  Future<T?> push<T>(Widget page) {
    return Navigator.push(
      this,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Shows a snackbar
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    return ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Iterable Extensions
// ---------------------------------------------------------------------------

extension IterableExtensions<E> on Iterable<E> {
  /// Maps each element and its index to a new value
  Iterable<T> mapIndexed<T>(T Function(E element, int index) f) sync* {
    var index = 0;
    for (final element in this) {
      yield f(element, index);
      index++;
    }
  }

  /// Finds first element matching the predicate or null
  E? firstWhereOrNull(bool Function(E) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  /// Sum of all elements as doubles
  double sumAsDouble(double Function(E) selector) {
    return fold(0.0, (sum, element) => sum + selector(element));
  }
}

// ---------------------------------------------------------------------------
// Color Extensions
// ---------------------------------------------------------------------------

extension ColorExtensions on Color {
  /// Darkens the color by [percent] (0-100)
  Color darken([int percent = 10]) {
    assert(percent >= 0 && percent <= 100);
    final f = 1 - percent / 100;
    return Color.fromARGB(
      alpha,
      (red * f).round(),
      (green * f).round(),
      (blue * f).round(),
    );
  }

  /// Lightens the color by [percent] (0-100)
  Color lighten([int percent = 10]) {
    assert(percent >= 0 && percent <= 100);
    final p = percent / 100;
    return Color.fromARGB(
      alpha,
      red + ((255 - red) * p).round(),
      green + ((255 - green) * p).round(),
      blue + ((255 - blue) * p).round(),
    );
  }

  /// Returns contrast color (black or white)
  Color get contrastColor {
    final luminance = (0.299 * red + 0.587 * green + 0.114 * blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

// ---------------------------------------------------------------------------
// TextEditingController Extensions
// ---------------------------------------------------------------------------

extension TextEditingControllerExtensions on TextEditingController {
  /// Selects all text in the controller
  void selectAll() {
    if (text.isEmpty) return;
    selection = TextSelection(
      baseOffset: 0,
      extentOffset: text.length,
    );
  }

  /// Clears the text in the controller
  void clear() {
    text = '';
  }
}

// ---------------------------------------------------------------------------
// File Size Extensions (for storage)
// ---------------------------------------------------------------------------

extension FileSizeExtensions on int {
  /// Formats bytes as human-readable file size
  String get asFileSize {
    if (this <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    final digitGroups = (log(this) / log(1024)).floor();
    return '${NumberFormat.decimalPattern().format(this / pow(1024, digitGroups))} ${units[digitGroups]}';
  }
}
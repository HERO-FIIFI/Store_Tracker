/// Centralized formatting utilities for consistent display across the app
/// 
/// Features:
/// - Number/currency formatting
/// - Date/time formatting
/// - String manipulation
/// - Unit conversions
/// - Locale-aware formatting
library formatters;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ---------------------------------------------------------------------------
// Currency & Number Formatting
// ---------------------------------------------------------------------------

/// Formats currency with locale awareness
/// Example: 1500 → "$1,500.00" (en_US) or "1.500,00 €" (de_DE)
String formatCurrency(
  double amount, {
  String? locale,
  int decimalDigits = 2,
  String? symbol,
}) {
  return NumberFormat.currency(
    locale: locale,
    decimalDigits: decimalDigits,
    symbol: symbol,
  ).format(amount);
}

/// Compact currency format for limited space
/// Example: 1500 → "$1.5K"
String formatCompactCurrency(double amount, {String? locale}) {
  return NumberFormat.compactCurrency(locale: locale).format(amount);
}

/// Percentage formatter (0.15 → "15%")
String formatPercentage(
  double decimal, {
  int decimalDigits = 0,
  bool withSign = false,
}) {
  final percent = decimal * 100;
  final sign = withSign && percent > 0 ? '+' : '';
  return '$sign${NumberFormat.decimalPattern().format(percent)}%';
}

// ---------------------------------------------------------------------------
// Date & Time Formatting
// ---------------------------------------------------------------------------

/// Standard date format (Mar 15, 2023)
String formatDate(DateTime date, {String? locale}) {
  return DateFormat.yMMMd(locale).format(date);
}

/// Short date format (15/03/2023)
String formatShortDate(DateTime date, {String? locale}) {
  return DateFormat.yMd(locale).format(date);
}

/// Date with time (Mar 15, 2023 2:30 PM)
String formatDateTime(DateTime date, {String? locale}) {
  return DateFormat.yMMMd().add_jm().format(date);
}

/// Relative time format (2 hours ago, 3 days ago)
String formatRelativeTime(DateTime date, {String? locale}) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 365) {
    final years = (difference.inDays / 365).floor();
    return Intl.plural(
      years,
      locale: locale,
      zero: 'This year',
      one: '1 year ago',
      other: '$years years ago',
    );
  } else if (difference.inDays > 30) {
    final months = (difference.inDays / 30).floor();
    return Intl.plural(
      months,
      locale: locale,
      zero: 'This month',
      one: '1 month ago',
      other: '$months months ago',
    );
  } else if (difference.inDays > 0) {
    return Intl.plural(
      difference.inDays,
      locale: locale,
      zero: 'Today',
      one: '1 day ago',
      other: '${difference.inDays} days ago',
    );
  } else if (difference.inHours > 0) {
    return Intl.plural(
      difference.inHours,
      locale: locale,
      zero: 'Less than an hour',
      one: '1 hour ago',
      other: '${difference.inHours} hours ago',
    );
  } else if (difference.inMinutes > 0) {
    return Intl.plural(
      difference.inMinutes,
      locale: locale,
      zero: 'Just now',
      one: '1 minute ago',
      other: '${difference.inMinutes} minutes ago',
    );
  } else {
    return 'Just now';
  }
}

// ---------------------------------------------------------------------------
// String Formatting
// ---------------------------------------------------------------------------

/// Capitalizes first letter of each word
String capitalize(String input) {
  if (input.isEmpty) return input;
  return input.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

/// Ellipsis for long text with max length
String ellipsis(String input, int maxLength) {
  if (input.length <= maxLength) return input;
  return '${input.substring(0, maxLength)}...';
}

/// Formats a list as comma-separated string
String formatList(List<String> items, {int? maxItems}) {
  if (maxItems != null && items.length > maxItems) {
    final shown = items.take(maxItems);
    return '${shown.join(', ')} +${items.length - maxItems} more';
  }
  return items.join(', ');
}

// ---------------------------------------------------------------------------
// Unit Conversion & Formatting
// ---------------------------------------------------------------------------

/// Formats weight with unit
String formatWeight(double kg, {bool withUnit = true}) {
  final formatted = NumberFormat.decimalPattern().format(kg);
  return withUnit ? '$formatted kg' : formatted;
}

/// Formats quantity with proper pluralization
String formatQuantity(int count, String singular, [String? plural]) {
  return Intl.plural(
    count,
    zero: 'No $singular',
    one: '1 $singular',
    other: '$count ${plural ?? '${singular}s'}',
  );
}

// ---------------------------------------------------------------------------
// Context-Aware Formatters (requires BuildContext)
// ---------------------------------------------------------------------------

extension FormattingExtensions on BuildContext {
  /// Gets locale-aware currency formatter
  NumberFormat get currencyFormatter =>
      NumberFormat.currency(locale: Localizations.localeOf(this).toString());

  /// Formats date based on device locale
  String formatLocalizedDate(DateTime date) =>
      DateFormat.yMMMd(Localizations.localeOf(this).toString()).format(date);

  /// Formats time based on device 12/24 hour preference
  String formatLocalizedTime(TimeOfDay time) {
    final materialLocalizations = MaterialLocalizations.of(this);
    return materialLocalizations.formatTimeOfDay(time);
  }
}

// ---------------------------------------------------------------------------
// Custom Formatters (Domain-Specific)
// ---------------------------------------------------------------------------

/// Formats inventory stock status
String formatStockStatus(int quantity, int? threshold) {
  return switch (quantity) {
    0 => 'Out of Stock',
    _ when threshold != null && quantity <= threshold => 'Low Stock ($quantity)',
    _ => 'In Stock ($quantity)',
  };
}

/// Formats profit/loss with color indication
TextSpan formatProfitLoss(double amount, {NumberFormat? formatter}) {
  final fmt = formatter ?? NumberFormat.currency();
  final isProfit = amount >= 0;
  
  return TextSpan(
    text: '${isProfit ? '+' : ''}${fmt.format(amount)}',
    style: TextStyle(
      color: isProfit ? Colors.green : Colors.red,
      fontWeight: FontWeight.bold,
    ),
  );
}
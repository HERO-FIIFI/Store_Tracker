/// Centralized validation utilities for consistent input validation
/// 
/// Features:
/// - Form field validators
/// - Business rule validation
/// - Type-safe validation results
/// - Composable validators
library validators;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ---------------------------------------------------------------------------
// Validation Result Model
// ---------------------------------------------------------------------------

/// Type-safe validation result
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  
  const ValidationResult.valid() 
    : isValid = true, 
      errorMessage = null;
      
  const ValidationResult.invalid(this.errorMessage) 
    : isValid = false;

  @override
  String toString() => isValid ? 'Valid' : 'Invalid: $errorMessage';
}

// ---------------------------------------------------------------------------
// Core Validators
// ---------------------------------------------------------------------------

/// Validates text is not empty
ValidationResult validateRequired(String? value, {String fieldName = 'This field'}) {
  if (value == null || value.trim().isEmpty) {
    return ValidationResult.invalid('$fieldName is required');
  }
  return const ValidationResult.valid();
}

/// Validates text length is within range
ValidationResult validateLength(
  String? value, {
  int min = 0,
  int? max,
  String fieldName = 'Field',
}) {
  if (value == null) return ValidationResult.invalid('$fieldName is required');
  
  final length = value.trim().length;
  
  if (min > 0 && length < min) {
    return ValidationResult.invalid('$fieldName must be at least $min characters');
  }
  
  if (max != null && length > max) {
    return ValidationResult.invalid('$fieldName cannot exceed $max characters');
  }
  
  return const ValidationResult.valid();
}

/// Validates numeric input
ValidationResult validateNumber(
  String? value, {
  double? min,
  double? max,
  String fieldName = 'Value',
}) {
  if (value == null || value.isEmpty) {
    return const ValidationResult.valid(); // Skip if not required
  }
  
  final number = double.tryParse(value);
  if (number == null) {
    return ValidationResult.invalid('$fieldName must be a valid number');
  }
  
  if (min != null && number < min) {
    return ValidationResult.invalid('$fieldName must be at least $min');
  }
  
  if (max != null && number > max) {
    return ValidationResult.invalid('$fieldName cannot exceed $max');
  }
  
  return const ValidationResult.valid();
}

/// Validates email format
ValidationResult validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return const ValidationResult.valid(); // Skip if not required
  }
  
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
  
  if (!emailRegex.hasMatch(value.trim())) {
    return const ValidationResult.invalid('Please enter a valid email address');
  }
  
  return const ValidationResult.valid();
}

/// Validates date is in correct format and range
ValidationResult validateDate(
  String? value, {
  DateFormat? format,
  DateTime? minDate,
  DateTime? maxDate,
}) {
  if (value == null || value.isEmpty) {
    return const ValidationResult.valid(); // Skip if not required
  }
  
  try {
    final dateFormat = format ?? DateFormat('yyyy-MM-dd');
    final date = dateFormat.parseStrict(value);
    
    if (minDate != null && date.isBefore(minDate)) {
      return ValidationResult.invalid('Date cannot be before ${dateFormat.format(minDate)}');
    }
    
    if (maxDate != null && date.isAfter(maxDate)) {
      return ValidationResult.invalid('Date cannot be after ${dateFormat.format(maxDate)}');
    }
    
    return const ValidationResult.valid();
  } on FormatException {
    return const ValidationResult.invalid('Please enter a valid date (YYYY-MM-DD)');
  }
}

// ---------------------------------------------------------------------------
// Domain-Specific Validators (Store Tracker)
// ---------------------------------------------------------------------------

/// Validates product SKU format
ValidationResult validateProductSku(String? value) {
  const skuPattern = r'^[A-Z]{2,4}\d{3,6}$';
  return _validatePattern(
    value,
    pattern: skuPattern,
    errorMessage: 'SKU must be 2-4 letters followed by 3-6 numbers',
    fieldName: 'SKU',
  );
}

/// Validates barcode format (UPC/EAN)
ValidationResult validateBarcode(String? value) {
  const upcPattern = r'^\d{12,13}$';
  return _validatePattern(
    value,
    pattern: upcPattern,
    errorMessage: 'Barcode must be 12 or 13 digits',
    fieldName: 'Barcode',
  );
}

/// Validates inventory count
ValidationResult validateStockQuantity(String? value) {
  return validateNumber(
    value,
    min: 0,
    max: 9999,
    fieldName: 'Quantity',
  );
}

/// Validates price amount
ValidationResult validatePrice(String? value) {
  final result = validateNumber(
    value,
    min: 0,
    max: 999999,
    fieldName: 'Price',
  );
  
  if (!result.isValid) return result;
  
  if (value != null) {
    final decimalPlaces = value.contains('.') ? value.split('.')[1].length : 0;
    if (decimalPlaces > 2) {
      return ValidationResult.invalid('Price can have max 2 decimal places');
    }
  }
  
  return const ValidationResult.valid();
}

// ---------------------------------------------------------------------------
// Composite Validators
// ---------------------------------------------------------------------------

/// Combines multiple validators
ValidationResult validateAll(
  String? value,
  List<ValidationResult Function(String?)> validators,
) {
  for (final validator in validators) {
    final result = validator(value);
    if (!result.isValid) return result;
  }
  return const ValidationResult.valid();
}

/// Validates based on a condition
ValidationResult validateWhen(
  bool condition,
  ValidationResult Function() validator,
) {
  return condition ? validator() : const ValidationResult.valid();
}

// ---------------------------------------------------------------------------
// Helper Methods
// ---------------------------------------------------------------------------

ValidationResult _validatePattern(
  String? value, {
  required String pattern,
  required String errorMessage,
  String fieldName = 'Field',
  bool isRequired = true,
}) {
  if (value == null || value.isEmpty) {
    return isRequired 
      ? ValidationResult.invalid('$fieldName is required')
      : const ValidationResult.valid();
  }
  
  if (!RegExp(pattern).hasMatch(value)) {
    return ValidationResult.invalid(errorMessage);
  }
  
  return const ValidationResult.valid();
}

// ---------------------------------------------------------------------------
// Form Field Validator Adapters
// ---------------------------------------------------------------------------

/// Adapts ValidationResult to Flutter's FormFieldValidator
FormFieldValidator<T> toFormFieldValidator<T>(
  ValidationResult Function(String?) validator, {
  bool validateEmpty = false,
}) {
  return (value) {
    final result = validator(value?.toString());
    return result.isValid ? null : result.errorMessage;
  };
}

/// Creates a validator that only runs when the condition is true
FormFieldValidator<T> conditionalValidator<T>(
  bool condition,
  FormFieldValidator<T> validator,
) {
  return (value) => condition ? validator(value) : null;
}

// ---------------------------------------------------------------------------
// Usage Examples
// ---------------------------------------------------------------------------

/*
// In your form fields:
TextFormField(
  validator: toFormFieldValidator((value) => validateAll(value, [
    validateRequired,
    (v) => validateLength(v, min: 3, max: 50),
  ])),
)

// For business rules:
final priceValidation = validatePrice(priceInput);
if (!priceValidation.isValid) {
  showError(priceValidation.errorMessage!);
}

// Composite validation:
final skuValidation = validateAll(skuInput, [
  validateRequired,
  validateProductSku,
  (v) => validateLength(v, max: 10),
]);
*/
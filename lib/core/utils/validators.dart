import 'package:flutter/widgets.dart';
import '../l10n/l10n.dart';

class Validators {
  Validators._();

  /// Returns a validator function that uses localized error messages.
  /// Usage: validator: Validators.phone(context)
  static String? Function(String?) phone(BuildContext context) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return context.l10n.validatorPhoneRequired;
      }
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.length < 10 || digits.length > 15) {
        return context.l10n.validatorPhoneInvalid;
      }
      return null;
    };
  }

  /// Normalises any accepted phone format to 07XXXXXXXXX.
  static String normalizePhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00964') && digits.length >= 13) {
      return '0${digits.substring(5)}';
    }
    if (digits.startsWith('964') && digits.length >= 13) {
      return '0${digits.substring(3)}';
    }
    if (digits.length == 10 && !digits.startsWith('0')) {
      return '0$digits';
    }
    return digits;
  }

  static String? Function(String?) password(BuildContext context) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return context.l10n.validatorPasswordRequired;
      }
      if (value.length < 6) return context.l10n.validatorPasswordTooShort;
      return null;
    };
  }

  static String? Function(String?) confirmPassword(
      BuildContext context, TextEditingController originalCtrl) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return context.l10n.validatorConfirmPasswordRequired;
      }
      if (value != originalCtrl.text) return context.l10n.validatorPasswordsMismatch;
      return null;
    };
  }

  static String? Function(String?) required(BuildContext context,
      {required String fieldName}) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return context.l10n.validatorRequired(fieldName);
      }
      return null;
    };
  }

  static String? Function(String?) name(BuildContext context) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return context.l10n.validatorNameRequired;
      }
      if (value.trim().length < 3) return context.l10n.validatorNameTooShort;
      return null;
    };
  }

  static String? Function(String?) email(BuildContext context) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) return null;
      final emailRegex =
          RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(value.trim())) {
        return context.l10n.validatorEmailInvalid;
      }
      return null;
    };
  }

  static String? Function(String?) year(BuildContext context) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return context.l10n.validatorYearRequired;
      }
      final y = int.tryParse(value.trim());
      if (y == null || y < 1990 || y > 2030) {
        return context.l10n.validatorYearInvalid;
      }
      return null;
    };
  }
}

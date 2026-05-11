import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/l10n.dart';

class Helpers {
  Helpers._();

  static String formatDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);
  static String formatTime(DateTime time) => DateFormat('hh:mm a').format(time);
  static String formatDateTime(DateTime dt) => DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  static String formatCurrency(int amount) =>
      'IQD ${NumberFormat('#,###').format(amount)}';

  static String greetingByTime(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.l10n.greetingMorning;
    if (hour < 17) return context.l10n.greetingAfternoon;
    return context.l10n.greetingEvening;
  }

  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : null,
      ),
    );
  }
}

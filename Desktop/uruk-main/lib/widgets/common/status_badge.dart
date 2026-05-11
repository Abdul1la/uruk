import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../models/accident_report_model.dart';
import '../../models/appointment_model.dart';
import '../../models/payment_model.dart';
import '../../models/user_model.dart';

class StatusBadge extends StatelessWidget {
  final Color bg;
  final Color fg;
  final _BadgeType _type;

  const StatusBadge._({required this.bg, required this.fg, required _BadgeType type})
      : _type = type;

  factory StatusBadge.reportStatus(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return StatusBadge._(
            bg: AppColors.warningLight, fg: AppColors.warning, type: _BadgeType.pending);
      case ReportStatus.underReview:
        return StatusBadge._(
            bg: AppColors.infoLight, fg: AppColors.info, type: _BadgeType.underReview);
      case ReportStatus.approved:
        return StatusBadge._(
            bg: AppColors.primarySurface, fg: AppColors.primary, type: _BadgeType.approved);
      case ReportStatus.inRepair:
        return StatusBadge._(
            bg: AppColors.infoLight, fg: AppColors.info, type: _BadgeType.inRepair);
      case ReportStatus.completed:
        return StatusBadge._(
            bg: AppColors.successLight, fg: AppColors.success, type: _BadgeType.completed);
      case ReportStatus.rejected:
        return StatusBadge._(
            bg: AppColors.errorLight, fg: AppColors.error, type: _BadgeType.rejected);
    }
  }

  factory StatusBadge.appointmentStatus(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return StatusBadge._(
            bg: AppColors.primarySurface, fg: AppColors.primary, type: _BadgeType.scheduled);
      case AppointmentStatus.changeRequested:
        return StatusBadge._(
            bg: AppColors.warningLight,
            fg: AppColors.warning,
            type: _BadgeType.changeRequested);
      case AppointmentStatus.confirmed:
        return StatusBadge._(
            bg: AppColors.successLight, fg: AppColors.success, type: _BadgeType.confirmed);
      case AppointmentStatus.completed:
        return StatusBadge._(
            bg: AppColors.successLight, fg: AppColors.success, type: _BadgeType.completed);
      case AppointmentStatus.cancelled:
        return StatusBadge._(
            bg: AppColors.errorLight, fg: AppColors.error, type: _BadgeType.cancelled);
    }
  }

  factory StatusBadge.paymentStatus(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return StatusBadge._(
            bg: AppColors.successLight, fg: AppColors.success, type: _BadgeType.paid);
      case PaymentStatus.unpaid:
        return StatusBadge._(
            bg: AppColors.errorLight, fg: AppColors.error, type: _BadgeType.unpaid);
      case PaymentStatus.overdue:
        return StatusBadge._(
            bg: AppColors.errorLight, fg: AppColors.error, type: _BadgeType.overdue);
    }
  }

  factory StatusBadge.subscriptionType(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.none:
        return StatusBadge._(
            bg: AppColors.divider, fg: AppColors.textSecondary, type: _BadgeType.noPlan);
      case SubscriptionType.standard:
        return StatusBadge._(
            bg: AppColors.primarySurface,
            fg: AppColors.primary,
            type: _BadgeType.standard);
      case SubscriptionType.shared:
        return StatusBadge._(
            bg: const Color(0xFFF3E8FF),
            fg: const Color(0xFF7C3AED),
            type: _BadgeType.shared);
      case SubscriptionType.vip:
        return StatusBadge._(
            bg: AppColors.warningLight, fg: AppColors.warning, type: _BadgeType.vip);
    }
  }

  String _label(AppLocalizations l) {
    switch (_type) {
      case _BadgeType.pending:       return l.statusPending;
      case _BadgeType.underReview:   return l.statusUnderReview;
      case _BadgeType.approved:      return l.statusApproved;
      case _BadgeType.inRepair:      return l.statusInRepair;
      case _BadgeType.completed:     return l.statusCompleted;
      case _BadgeType.rejected:      return l.statusRejected;
      case _BadgeType.scheduled:     return l.statusScheduled;
      case _BadgeType.confirmed:     return l.statusConfirmed;
      case _BadgeType.changeRequested: return l.statusChangeRequested;
      case _BadgeType.cancelled:     return l.statusCancelled;
      case _BadgeType.unpaid:        return l.statusUnpaid;
      case _BadgeType.paid:          return l.statusPaid;
      case _BadgeType.overdue:       return l.statusOverdue;
      case _BadgeType.noPlan:        return l.statusNoPlan;
      case _BadgeType.standard:      return l.statusStandard;
      case _BadgeType.shared:        return l.statusShared;
      case _BadgeType.vip:           return l.statusVip;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        _label(context.l10n),
        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

enum _BadgeType {
  pending, underReview, approved, inRepair, completed, rejected,
  scheduled, confirmed, changeRequested, cancelled,
  unpaid, paid, overdue,
  noPlan, standard, shared, vip,
}

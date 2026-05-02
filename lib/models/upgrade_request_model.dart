import 'user_model.dart';

enum UpgradeRequestStatus { pending, approved, rejected }

class UpgradeRequest {
  final String id;
  final String userId;
  final String carId;

  // ── Current plan ──────────────────────────────────────────────────────────
  final SubscriptionType currentPlan;
  final int currentPlanPriceIQD;     // monthly price
  final int remainingMonths;          // months left on current subscription
  final int creditIQD;               // remainingMonths × currentPlanPriceIQD

  // ── Requested plan ────────────────────────────────────────────────────────
  final SubscriptionType requestedPlan;
  final int requestedPlanPriceIQD;   // monthly price of the new plan
  final int requestedMonths;          // payment period user wants for new plan
  final int newCostIQD;              // requestedPlanPriceIQD × requestedMonths
  final int amountDueIQD;            // max(0, newCostIQD - creditIQD)
  final String? proofImageUrl;       // optional payment-proof image URL

  final UpgradeRequestStatus status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? adminNote;

  const UpgradeRequest({
    required this.id,
    required this.userId,
    required this.carId,
    required this.currentPlan,
    required this.currentPlanPriceIQD,
    required this.remainingMonths,
    required this.creditIQD,
    required this.requestedPlan,
    required this.requestedPlanPriceIQD,
    required this.requestedMonths,
    required this.newCostIQD,
    required this.amountDueIQD,
    this.proofImageUrl,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.adminNote,
  });

  bool get isPending  => status == UpgradeRequestStatus.pending;
  bool get isApproved => status == UpgradeRequestStatus.approved;
  bool get isRejected => status == UpgradeRequestStatus.rejected;
}

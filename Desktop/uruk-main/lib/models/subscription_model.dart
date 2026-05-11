import 'user_model.dart';

/// A single payment-period tier showing how many repairs/month are allowed.
class RepairTier {
  final String label;      // e.g. 'شهري'
  final int months;        // 1, 3, 6, 12
  final int repairsPerMonth;

  const RepairTier({
    required this.label,
    required this.months,
    required this.repairsPerMonth,
  });

  factory RepairTier.fromJson(Map<String, dynamic> json) => RepairTier(
        label: (json['label'] ?? SubscriptionPlan.periodLabel(json['months'] as int? ?? 1)).toString(),
        months: json['months'] as int? ?? 1,
        repairsPerMonth: json['repairsPerMonth'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'months': months,
        'repairsPerMonth': repairsPerMonth,
      };
}

class SubscriptionPlan {
  final String id;
  final SubscriptionType type;
  final String name;
  final int priceIQD;
  final String coverageNote;     // who is covered
  final List<String> coveredParts; // body parts included
  final List<RepairTier> repairTiers;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.type,
    required this.name,
    required this.priceIQD,
    required this.coverageNote,
    required this.coveredParts,
    required this.repairTiers,
    this.isPopular = false,
  });

  /// The monthly price IQD (kept for backward compat).
  int get monthlyPriceIQD => priceIQD;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['type'] ?? 'standard').toString();
    final type = SubscriptionType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => SubscriptionType.standard,
    );
    final tiersRaw = (json['repairTiers'] as List?) ?? const [];
    return SubscriptionPlan(
      id: (json['id'] ?? typeStr).toString(),
      type: type,
      name: (json['name'] ?? '').toString(),
      priceIQD: json['priceIQD'] as int? ?? 0,
      coverageNote: (json['coverageNote'] ?? '').toString(),
      coveredParts: (json['coveredParts'] as List?)?.map((e) => e.toString()).toList() ??
          List<String>.from(_coveredParts),
      repairTiers: tiersRaw
          .whereType<Map<String, dynamic>>()
          .map(RepairTier.fromJson)
          .toList(),
      isPopular: json['isPopular'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'name': name,
        'priceIQD': priceIQD,
        'coverageNote': coverageNote,
        'coveredParts': coveredParts,
        'repairTiers': repairTiers.map((t) => t.toJson()).toList(),
        'isPopular': isPopular,
      };

  static const List<RepairTier> _standardTiers = [
    RepairTier(label: 'دفع شهري',          months: 1,  repairsPerMonth: 1),
    RepairTier(label: 'دفع ٣ أشهر مقدماً', months: 3,  repairsPerMonth: 2),
    RepairTier(label: 'دفع ٦ أشهر مقدماً', months: 6,  repairsPerMonth: 3),
    RepairTier(label: 'دفع سنة مقدماً',    months: 12, repairsPerMonth: 4),
  ];

  static const List<RepairTier> _sharedTiers = [
    RepairTier(label: 'دفع شهري',          months: 1,  repairsPerMonth: 1),
    RepairTier(label: 'دفع ٣ أشهر مقدماً', months: 3,  repairsPerMonth: 2),
    RepairTier(label: 'دفع ٦ أشهر مقدماً', months: 6,  repairsPerMonth: 3),
    RepairTier(label: 'دفع سنة مقدماً',    months: 12, repairsPerMonth: 4),
  ];

  static const List<RepairTier> _vipTiers = [
    RepairTier(label: 'دفع شهري',          months: 1,  repairsPerMonth: 3),
    RepairTier(label: 'دفع ٣ أشهر مقدماً', months: 3,  repairsPerMonth: 5),
    RepairTier(label: 'دفع ٦ أشهر مقدماً', months: 6,  repairsPerMonth: 7),
    RepairTier(label: 'دفع سنة مقدماً',    months: 12, repairsPerMonth: 10),
  ];

  static const List<String> _coveredParts = [
    'الدعامية الأمامية',
    'الدعامية الخلفية',
    'الأبواب',
    'جاملخ الاماميات',
    'جاملخ الخلفيات',
  ];

  /// Arabic label for a given payment period.
  static String periodLabel(int months) {
    switch (months) {
      case 3:  return '٣ أشهر مقدماً';
      case 6:  return '٦ أشهر مقدماً';
      case 12: return 'سنة مقدماً';
      default: return 'دفع شهري';
    }
  }

  /// Look up allowed repairs per month for a given plan type + payment period.
  /// Falls back to the monthly tier if an exact match is not found.
  static int repairsForPeriod(SubscriptionType type, int months) {
    SubscriptionPlan? plan;
    for (final p in plans) {
      if (p.type == type) { plan = p; break; }
    }
    if (plan == null) return 0;
    for (final t in plan.repairTiers) {
      if (t.months == months) return t.repairsPerMonth;
    }
    return plan.repairTiers.first.repairsPerMonth;
  }

  /// Built-in fallback (used before the first backend fetch succeeds).
  static const List<SubscriptionPlan> _defaultPlans = [
    SubscriptionPlan(
      id: 'standard',
      type: SubscriptionType.standard,
      name: 'ستاندارد',
      priceIQD: 35000,
      coverageNote: 'تشمل سيارة المشترك فقط',
      coveredParts: _coveredParts,
      repairTiers: _standardTiers,
    ),
    SubscriptionPlan(
      id: 'shared',
      type: SubscriptionType.shared,
      name: 'المزدوج',
      priceIQD: 60000,
      coverageNote: 'تشمل سيارة المشترك وسيارة الطرف الآخر المتضرر',
      coveredParts: _coveredParts,
      repairTiers: _sharedTiers,
      isPopular: true,
    ),
    SubscriptionPlan(
      id: 'vip',
      type: SubscriptionType.vip,
      name: 'VIP',
      priceIQD: 150000,
      coverageNote: 'تشمل سيارة المشترك وسيارة الطرف الآخر المتضرر',
      coveredParts: _coveredParts,
      repairTiers: _vipTiers,
    ),
  ];

  /// Mutable runtime list, replaced after the backend call completes.
  static List<SubscriptionPlan> _plans = List<SubscriptionPlan>.from(_defaultPlans);

  /// Current plans (dynamic — can be refreshed from the backend).
  static List<SubscriptionPlan> get plans => List.unmodifiable(_plans);

  /// Replace the plans list — called by AppProvider after fetching from backend.
  static void setPlans(List<SubscriptionPlan> newPlans) {
    if (newPlans.isEmpty) return;
    _plans = List<SubscriptionPlan>.from(newPlans);
  }

  /// Revert to the bundled defaults.
  static void resetPlans() {
    _plans = List<SubscriptionPlan>.from(_defaultPlans);
  }
}

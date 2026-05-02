import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/accident_report_model.dart';
import '../../models/draft_report_model.dart';
import '../../models/user_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/draft_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/status_badge.dart';

class AccidentHistoryScreen extends StatefulWidget {
  const AccidentHistoryScreen({super.key});

  @override
  State<AccidentHistoryScreen> createState() => _AccidentHistoryScreenState();
}

class _AccidentHistoryScreenState extends State<AccidentHistoryScreen> {
  void _newReport() {
    final car = context.read<AppProvider>().selectedCar ??
        context.read<AuthProvider>().user?.car;
    if (car == null || car.subscription == SubscriptionType.none) {
      final l = context.l10n;
      showDialog(
        context: context,
        builder: (dlgCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.block_outlined, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(l.accidentNoSubscriptionTitle)),
            ],
          ),
          content: Text(l.accidentNoSubscriptionContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgCtx),
              child: Text(l.commonOk),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dlgCtx);
                context.push('/subscription');
              },
              child: Text(l.accidentNoSubscriptionAction),
            ),
          ],
        ),
      );
      return;
    }
    context.push('/accidents/report');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<AppProvider>().loadAccidents(user.id);
        context.read<DraftProvider>().loadDrafts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final drafts = context.watch<DraftProvider>().drafts;
    final l = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.accidentHistoryTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _newReport,
            tooltip: l.accidentHistoryNewReportTooltip,
          ),
        ],
      ),
      body: app.loadingAccidents
          ? const Center(child: CircularProgressIndicator())
          : (app.accidents.isEmpty && drafts.isEmpty)
              ? _EmptyState(onNewReport: _newReport)
              : CustomScrollView(
                  slivers: [
                    // ── Drafts section ────────────────���───────────────────
                    if (drafts.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            children: [
                              const Icon(Icons.bookmark_outline,
                                  color: AppColors.warning, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                l.accidentHistoryDraftsSectionTitle,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppColors.textPrimary),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.warning
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${drafts.length}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: _DraftCard(draft: drafts[i]),
                          ),
                          childCount: drafts.length,
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 8)),
                      if (app.accidents.isNotEmpty)
                        const SliverToBoxAdapter(
                          child: Divider(indent: 16, endIndent: 16),
                        ),
                    ],

                    // ── Submitted reports ─────────────────────────────���───
                    if (app.accidents.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Container(
                          margin:
                              const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              _StatChip(
                                label: l.accidentHistoryTotal,
                                value: '${app.accidents.length}',
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              _StatChip(
                                label: l.accidentHistoryCompleted,
                                value:
                                    '${app.accidents.where((r) => r.status == ReportStatus.completed).length}',
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 12),
                              _StatChip(
                                label: l.accidentHistoryUnderReview,
                                value:
                                    '${app.accidents.where((r) => r.status == ReportStatus.pending || r.status == ReportStatus.underReview).length}',
                                color: AppColors.warning,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child:
                                  _ReportCard(report: app.accidents[i]),
                            ),
                            childCount: app.accidents.length,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newReport,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l.accidentHistoryNewReportFab,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ── Draft Card ─────────────────────────��─────────────────────────────────���────

class _DraftCard extends StatelessWidget {
  final DraftReport draft;
  const _DraftCard({required this.draft});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return Dismissible(
      key: Key(draft.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(l.accidentHistoryDeleteDraftTitle),
            content: Text(l.accidentHistoryDeleteDraftContent),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogCtx, false),
                  child: Text(l.commonCancel)),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogCtx, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error),
                child: Text(l.commonDelete,
                    style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) =>
          context.read<DraftProvider>().deleteDraft(draft.id),
      child: GestureDetector(
        onTap: () => context.push('/accidents/report', extra: draft),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.4), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bookmark_outline,
                        color: AppColors.warning, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          draft.location.isEmpty
                              ? l.draftLocationUnknown
                              : draft.location,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          l.draftLastModified(
                              Helpers.formatDateTime(draft.savedAt)),
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(l.draftBadge,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.warning,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              if (draft.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  draft.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  if (draft.photoPaths.isNotEmpty) ...[
                    const Icon(Icons.photo_library_outlined,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                        l.accidentHistoryPhotosCount(
                            draft.photoPaths.length),
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary)),
                    const SizedBox(width: 10),
                  ],
                  if (draft.latitude != null) ...[
                    const Icon(Icons.pin_drop_outlined,
                        size: 13, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(l.draftCoordinatesSet,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.primary)),
                    const SizedBox(width: 10),
                  ],
                  const Spacer(),
                  Text(l.draftSwipeToDelete,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right,
                      size: 16, color: AppColors.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat Chip ─────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color)),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}

// ── Report Card ────────────────────────────────────────────────────────────���──

class _ReportCard extends StatelessWidget {
  final AccidentReport report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return GestureDetector(
      onTap: () => context.push('/accidents/${report.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.car_crash_outlined,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.location,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textPrimary)),
                      Text(Helpers.formatDateTime(report.submittedAt),
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                StatusBadge.reportStatus(report.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              report.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.photo_library_outlined,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                    l.accidentHistoryPhotosCount(
                        report.photoUrls.length),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                if (report.otherPartyInvolved) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.people_outline,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(l.accidentHistoryOtherPartyInvolved,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
                const Spacer(),
                const Icon(Icons.chevron_right,
                    size: 18, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ────────────────────────────────��─────────────────────────────���

class _EmptyState extends StatelessWidget {
  final VoidCallback onNewReport;
  const _EmptyState({required this.onNewReport});
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                  color: AppColors.primarySurface, shape: BoxShape.circle),
              child: const Icon(Icons.car_crash_outlined,
                  size: 50, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(l.accidentHistoryEmpty,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              l.accidentHistoryEmptyDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5),
            ),
            const SizedBox(height: 28),
            AppButton(
              label: l.accidentHistorySubmitButton,
              onPressed: onNewReport,
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }
}

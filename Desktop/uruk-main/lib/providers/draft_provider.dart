import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/draft_report_model.dart';

class DraftProvider extends ChangeNotifier {
  static const _prefsKey = 'accident_drafts_v1';

  List<DraftReport> _drafts = [];
  List<DraftReport> get drafts => _drafts;

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_prefsKey) ?? [];
    _drafts = jsonList
        .map((s) {
          try {
            return DraftReport.fromJsonString(s);
          } catch (_) {
            return null;
          }
        })
        .whereType<DraftReport>()
        .toList();
    notifyListeners();
  }

  // ── Save / upsert ─────────────────────────────────────────────────────────

  Future<DraftReport> saveDraft({
    String? existingId,
    required String location,
    double? latitude,
    double? longitude,
    required String description,
    required DateTime accidentDate,
    required bool otherPartyInvolved,
    required List<String> photoPaths,
  }) async {
    final now = DateTime.now();
    final draft = DraftReport(
      id: existingId ?? 'dft_${now.millisecondsSinceEpoch}',
      location: location,
      latitude: latitude,
      longitude: longitude,
      description: description,
      accidentDate: accidentDate,
      otherPartyInvolved: otherPartyInvolved,
      photoPaths: photoPaths,
      savedAt: now,
    );

    final idx = _drafts.indexWhere((d) => d.id == draft.id);
    if (idx >= 0) {
      _drafts[idx] = draft;
    } else {
      _drafts.insert(0, draft);
    }
    await _persist();
    notifyListeners();
    return draft;
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteDraft(String id) async {
    _drafts.removeWhere((d) => d.id == id);
    await _persist();
    notifyListeners();
  }

  // ── Persist ───────────────────────────────────────────────────────────────

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      _drafts.map((d) => d.toJsonString()).toList(),
    );
  }
}

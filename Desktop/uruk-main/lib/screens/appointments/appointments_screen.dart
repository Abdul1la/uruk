import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/appointment_model.dart';
import '../../models/oil_change_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/status_badge.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<AppProvider>().loadAppointments(user.id);
        context.read<AppProvider>().loadOilChangeBookings(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final l = context.l10n;

    // Only show oil changes that have been scheduled by admin (date set).
    final scheduledOilChanges = app.oilChangeBookings
        .where((o) => o.scheduledDate != null)
        .toList();
    final isEmpty = app.appointments.isEmpty && scheduledOilChanges.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l.appointmentsTitle)),
      body: app.loadingAppointments
          ? const Center(child: CircularProgressIndicator())
          : isEmpty
              ? _EmptyState()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...app.appointments.map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _AppointmentCard(appointment: a),
                        )),
                    ...scheduledOilChanges.map((o) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _OilChangeAppointmentCard(booking: o),
                        )),
                  ],
                ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  const _AppointmentCard({required this.appointment});

  bool get _isUpcoming =>
      appointment.scheduledDate.isAfter(DateTime.now()) &&
      appointment.status != AppointmentStatus.cancelled &&
      appointment.status != AppointmentStatus.completed;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isUpcoming ? AppColors.primary : AppColors.divider,
          width: _isUpcoming ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isUpcoming ? AppColors.primarySurface : AppColors.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Icon(
                  _isUpcoming ? Icons.calendar_month : Icons.history,
                  color: _isUpcoming ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isUpcoming ? l.appointmentsUpcoming : l.appointmentsPast,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: _isUpcoming ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
                StatusBadge.appointmentStatus(appointment.status),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(Helpers.formatDate(appointment.scheduledDate),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.access_time_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(appointment.timeSlot,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                ]),

                // Branch name
                if (appointment.branchName != null) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${l.appointmentsBranch}: ${appointment.branchName}',
                        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      ),
                    ),
                  ]),
                ],

                // Navigate button
                if (appointment.hasLocation) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showNavigationOptions(context, appointment),
                      icon: const Icon(Icons.navigation_outlined, size: 18),
                      label: Text(l.appointmentsNavigate),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],

                if (appointment.maintenanceNote != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.info, size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(appointment.maintenanceNote!,
                              style: const TextStyle(fontSize: 12, color: AppColors.info, height: 1.4)),
                        ),
                      ],
                    ),
                  ),
                ],

                if (appointment.userNote != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.edit_note, color: AppColors.warning, size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l.appointmentsYourNote(appointment.userNote!),
                            style: const TextStyle(fontSize: 12, color: AppColors.warning, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (_isUpcoming && appointment.status != AppointmentStatus.changeRequested) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _requestChange(context),
                    icon: const Icon(Icons.edit_calendar_outlined, size: 16),
                    label: Text(l.appointmentsChangeTime),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 42),
                    ),
                  ),
                ],
                if (appointment.status == AppointmentStatus.changeRequested) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.pending_outlined, color: AppColors.warning, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(l.appointmentsChangeRequestSent,
                              style: const TextStyle(fontSize: 12, color: AppColors.warning)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNavigationOptions(BuildContext context, AppointmentModel appt) {
    final l = context.l10n;
    final lat = appt.locationLat!;
    final lng = appt.locationLng!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(l.appointmentsChooseNav,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.map, color: AppColors.primary),
              title: Text(l.appointmentsGoogleMaps),
              onTap: () {
                Navigator.pop(context);
                final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
                launchUrl(url, mode: LaunchMode.externalApplication);
              },
            ),
            ListTile(
              leading: const Icon(Icons.navigation, color: Color(0xFF33CCFF)),
              title: Text(l.appointmentsWaze),
              onTap: () {
                Navigator.pop(context);
                final url = Uri.parse('https://waze.com/ul?ll=$lat,$lng&navigate=yes');
                launchUrl(url, mode: LaunchMode.externalApplication);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _requestChange(BuildContext context) {
    final l = context.l10n;
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l.appointmentsDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.appointmentsDialogContent,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l.appointmentsDialogHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(l.commonCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final note = noteCtrl.text.trim();
              if (note.isEmpty) return;
              final messenger = ScaffoldMessenger.of(context);
              final app = context.read<AppProvider>();
              Navigator.of(dialogCtx).pop();
              await app.requestAppointmentChange(appointment.id, note);
              messenger.showSnackBar(
                SnackBar(content: Text(l.appointmentsRequestSentSnackbar)),
              );
            },
            child: Text(l.commonSendRequest),
          ),
        ],
      ),
    );
  }
}

// ── Oil Change Appointment Card ──────────────────────────────────────────────

class _OilChangeAppointmentCard extends StatelessWidget {
  final OilChangeBooking booking;
  const _OilChangeAppointmentCard({required this.booking});

  bool get _isUpcoming =>
      booking.scheduledDate != null &&
      booking.scheduledDate!.isAfter(DateTime.now()) &&
      booking.status != OilChangeStatus.cancelled &&
      booking.status != OilChangeStatus.completed;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isUpcoming ? const Color(0xFF065F46) : AppColors.divider,
          width: _isUpcoming ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFD1FAE5),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.build_circle_outlined, color: Color(0xFF065F46), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.oilChangeServiceName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF065F46),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(Helpers.formatDate(booking.scheduledDate!),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                ]),
                if (booking.timeSlot != null) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.access_time_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(booking.timeSlot!,
                        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                  ]),
                ],
                if (booking.branchName != null) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${l.appointmentsBranch}: ${booking.branchName}',
                        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      ),
                    ),
                  ]),
                ],
                if (booking.hasLocation) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showOilNavigationOptions(context, booking),
                      icon: const Icon(Icons.navigation_outlined, size: 18),
                      label: Text(l.appointmentsNavigate),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF065F46),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
                if (booking.notes != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.edit_note, color: AppColors.warning, size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            booking.notes!,
                            style: const TextStyle(fontSize: 12, color: AppColors.warning, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOilNavigationOptions(BuildContext context, OilChangeBooking b) {
    final l = context.l10n;
    final lat = b.locationLat!;
    final lng = b.locationLng!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(l.appointmentsChooseNav,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.map, color: AppColors.primary),
              title: Text(l.appointmentsGoogleMaps),
              onTap: () {
                Navigator.pop(context);
                final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
                launchUrl(url, mode: LaunchMode.externalApplication);
              },
            ),
            ListTile(
              leading: const Icon(Icons.navigation, color: Color(0xFF33CCFF)),
              title: Text(l.appointmentsWaze),
              onTap: () {
                Navigator.pop(context);
                final url = Uri.parse('https://waze.com/ul?ll=$lat,$lng&navigate=yes');
                launchUrl(url, mode: LaunchMode.externalApplication);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_month_outlined, size: 64, color: AppColors.primary),
            const SizedBox(height: 20),
            Text(l.appointmentsEmpty, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              l.appointmentsEmptyDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

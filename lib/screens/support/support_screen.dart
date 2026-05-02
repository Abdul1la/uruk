import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common/back_button_handler.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final l = context.l10n;
    final info = app.supportInfo;

    return BackButtonHandler(
      fallbackRoute: '/home',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(l.supportTitle)),
        body: info == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.support_agent, color: Colors.white, size: 48),
                        const SizedBox(height: 12),
                        Text(l.supportNeedHelp,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(height: 6),
                        Text(l.supportDesc,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Contact methods
                  _ContactTile(
                    icon: Icons.phone_outlined,
                    color: AppColors.success,
                    title: l.supportCallUs,
                    value: info.phone,
                    onTap: () => _launch('tel:${info.phone}'),
                  ),
                  const SizedBox(height: 10),

                  _ContactTile(
                    icon: Icons.email_outlined,
                    color: AppColors.info,
                    title: l.supportEmailUs,
                    value: info.email,
                    onTap: () => _launch('mailto:${info.email}'),
                  ),
                  const SizedBox(height: 10),

                  if (info.whatsapp != null) ...[
                    _ContactTile(
                      icon: Icons.chat_outlined,
                      color: const Color(0xFF25D366),
                      title: l.supportWhatsApp,
                      value: info.whatsapp!,
                      onTap: () => _launch('https://wa.me/${info.whatsapp!.replaceAll(RegExp(r'[^0-9]'), '')}'),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Info section
                  const SizedBox(height: 10),
                  _InfoSection(
                    children: [
                      if (info.workingHours != null)
                        _InfoRow(icon: Icons.access_time_outlined, label: l.supportWorkingHours, value: info.workingHours!),
                      if (info.address != null)
                        _InfoRow(icon: Icons.location_on_outlined, label: l.supportAddress, value: info.address!),
                    ],
                  ),

                  // Social media
                  if (info.instagram != null || info.facebook != null || info.telegram != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
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
                              const Icon(Icons.share_outlined, color: AppColors.primary, size: 18),
                              const SizedBox(width: 8),
                              Text(l.supportFollowUs,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primary)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              if (info.instagram != null)
                                _SocialChip(label: 'Instagram', icon: Icons.camera_alt_outlined, color: const Color(0xFFE1306C),
                                    onTap: () => _launch('https://instagram.com/${info.instagram}')),
                              if (info.facebook != null)
                                _SocialChip(label: 'Facebook', icon: Icons.facebook_outlined, color: const Color(0xFF1877F2),
                                    onTap: () => _launch('https://facebook.com/${info.facebook}')),
                              if (info.telegram != null)
                                _SocialChip(label: 'Telegram', icon: Icons.send_outlined, color: const Color(0xFF0088CC),
                                    onTap: () => _launch('https://t.me/${info.telegram}')),
                              if (info.website != null)
                                _SocialChip(label: info.website!, icon: Icons.language_outlined, color: AppColors.primary,
                                    onTap: () => _launch('https://${info.website}')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
                ],
              ),
            ),
            Icon(Icons.chevron_left, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final List<Widget> children;
  const _InfoSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}

class _SocialChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SocialChip({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

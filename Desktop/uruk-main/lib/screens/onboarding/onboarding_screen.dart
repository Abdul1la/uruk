import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/back_button_handler.dart';
import '../../widgets/common/uruk_logo.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void initState() {
    super.initState();
    // Fetch admin-managed onboarding override on first paint so we don't
    // block the screen waiting for the network.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadOnboardingPages();
    });
  }

  void _next(int pageCount) {
    if (_page < pageCount - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final adminPages = context.watch<AppProvider>().onboardingPages;

    // Built-in defaults (used when the admin hasn't customized onboarding).
    final defaults = [
      _OnboardPage(
        icon: Icons.shield_outlined,
        title: l.onboard1Title,
        desc: l.onboard1Desc,
      ),
      _OnboardPage(
        icon: Icons.camera_alt_outlined,
        title: l.onboard2Title,
        desc: l.onboard2Desc,
      ),
      _OnboardPage(
        icon: Icons.history_outlined,
        title: l.onboard3Title,
        desc: l.onboard3Desc,
      ),
    ];

    // Merge: for each slide pick admin override (when present), else default.
    final pages = List.generate(defaults.length, (i) {
      if (i < adminPages.length) {
        final a = adminPages[i];
        return _OnboardPage(
          icon: defaults[i].icon,
          title: a.title.isNotEmpty ? a.title : defaults[i].title,
          desc: a.desc.isNotEmpty ? a.desc : defaults[i].desc,
          imageUrl: a.imageUrl,
        );
      }
      return defaults[i];
    });

    final isLast = _page == pages.length - 1;

    return BackButtonHandler(
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const UrukLogo(fontSize: 22),
                  if (!isLast)
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(l.onboardSkip),
                    ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: pages.length,
                itemBuilder: (_, i) => _PageContent(page: pages[i]),
              ),
            ),

            // Dots + button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _page ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _page ? AppColors.primary : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: isLast ? l.onboardGetStarted : l.commonNext,
                    onPressed: () => _next(pages.length),
                    icon: isLast ? Icons.arrow_forward : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l.onboardAlreadyHaveAccount,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text(l.onboardSignIn),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _PageContent extends StatelessWidget {
  final _OnboardPage page;
  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (page.imageUrl != null && page.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: page.imageUrl!,
                width: 220,
                height: 220,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 220,
                  height: 220,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 220,
                  height: 220,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Icon(page.icon, size: 70, color: AppColors.primary),
                ),
              ),
            )
          else
            Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(page.icon, size: 70, color: AppColors.primary),
            ),
          const SizedBox(height: 40),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardPage {
  final IconData icon;
  final String title;
  final String desc;
  final String? imageUrl;
  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.desc,
    this.imageUrl,
  });
}

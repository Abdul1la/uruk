import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../models/ad_banner_model.dart';
import '../../models/user_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/back_button_handler.dart';
import '../../widgets/common/uruk_logo.dart';

class GarageScreen extends StatefulWidget {
  const GarageScreen({super.key});

  @override
  State<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> {
  int _bannerIndex = 0;
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadAdBanners();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectCar(CarInfo car) {
    context.read<AppProvider>().setSelectedCar(car);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final app = context.watch<AppProvider>();
    final user = auth.user;
    final l = context.l10n;

    return BackButtonHandler(
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
              child: _GarageHeader(user: user, unreadCount: app.unreadCount)),

          if (app.adBanners.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _AdBannerCarousel(
                  banners: app.adBanners,
                  currentIndex: _bannerIndex,
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _bannerIndex = i),
                ),
              ),
            ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l.garageMyCarsSectionTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    l.garageCarsCount(user?.cars.length ?? 0),
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),

          if (user != null && user.cars.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: _CarCard(
                      car: user.cars[i], onTap: () => _selectCar(user.cars[i])),
                ),
                childCount: user.cars.length,
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    l.garageNoCarYet,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              child: _AddCarButton(onTap: () => context.push('/add-car/new')),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _GarageHeader extends StatelessWidget {
  final UserModel? user;
  final int unreadCount;
  const _GarageHeader({this.user, required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 14, 20, 20),
      child: Row(
        children: [
          const UrukLogoHorizontal(size: 26),
          const Spacer(),
          // ── Contact-us pill (same as home_screen) ────────────────
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => context.push('/support'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l.supportCallUs,
                style: const TextStyle(
                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white, size: 24),
            onPressed: () => context.push('/profile'),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white, size: 24),
                onPressed: () => context.push('/notifications'),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Ad Banner Carousel ────────────────────────────────────────────────────────

class _AdBannerCarousel extends StatelessWidget {
  final List<AdBanner> banners;
  final int currentIndex;
  final PageController controller;
  final ValueChanged<int> onPageChanged;

  const _AdBannerCarousel({
    required this.banners,
    required this.currentIndex,
    required this.controller,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: controller,
            onPageChanged: onPageChanged,
            itemCount: banners.length,
            itemBuilder: (_, i) => _BannerCard(banner: banners[i]),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == currentIndex ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == currentIndex ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final AdBanner banner;
  const _BannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    // If the admin uploaded an image or video, use it as the background and
    // overlay the text on top. Otherwise render the classic icon + color card.
    final card = banner.hasMedia
        ? _MediaBanner(banner: banner)
        : _IconBanner(banner: banner);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: banner.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: card,
    );
  }
}

/// Classic layout: icon tile on the side, text + optional action chip.
class _IconBanner extends StatelessWidget {
  final AdBanner banner;
  const _IconBanner({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(banner.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(child: _BannerText(banner: banner, onDark: true)),
          if (banner.actionLabel != null) ...[
            const SizedBox(width: 10),
            _ActionChip(label: banner.actionLabel!),
          ],
        ],
      ),
    );
  }
}

/// Image or video fills the card as background; text + action chip
/// overlay on top with a dark gradient for readability.
class _MediaBanner extends StatelessWidget {
  final AdBanner banner;
  const _MediaBanner({required this.banner});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Media layer
          if (banner.mediaType == AdBannerMediaType.video && banner.mediaUrl != null)
            _BannerVideo(url: banner.mediaUrl!)
          else if (banner.mediaUrl != null)
            CachedNetworkImage(
              imageUrl: banner.mediaUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: banner.backgroundColor),
              errorWidget: (_, __, ___) => Container(color: banner.backgroundColor),
            ),
          // Dark gradient overlay so white text stays readable on any image
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
          // Text overlay
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _BannerText(banner: banner, onDark: true)),
                if (banner.actionLabel != null) ...[
                  const SizedBox(width: 10),
                  _ActionChip(label: banner.actionLabel!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Auto-playing muted looped video fit-cover. Disposes its controller when
/// the banner scrolls out.
class _BannerVideo extends StatefulWidget {
  final String url;
  const _BannerVideo({required this.url});

  @override
  State<_BannerVideo> createState() => _BannerVideoState();
}

class _BannerVideoState extends State<_BannerVideo> {
  VideoPlayerController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final c = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await c.initialize();
      await c.setLooping(true);
      await c.setVolume(0);
      await c.play();
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() {
        _controller = c;
        _ready = true;
      });
    } catch (_) {
      // Controller failed to load — the UI falls back to the solid bg color.
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready || _controller == null) return const SizedBox.shrink();
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _controller!.value.size.width,
        height: _controller!.value.size.height,
        child: VideoPlayer(_controller!),
      ),
    );
  }
}

class _BannerText extends StatelessWidget {
  final AdBanner banner;
  final bool onDark;
  const _BannerText({required this.banner, required this.onDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          banner.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.3,
            shadows: onDark
                ? const [Shadow(color: Colors.black38, blurRadius: 6)]
                : null,
          ),
        ),
        if (banner.subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            banner.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
              height: 1.4,
              shadows: onDark
                  ? const [Shadow(color: Colors.black38, blurRadius: 6)]
                  : null,
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  const _ActionChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── Car Card ──────────────────────────────────────────────────────────────────

class _CarCard extends StatelessWidget {
  final CarInfo car;
  final VoidCallback onTap;
  const _CarCard({required this.car, required this.onTap});

  Color get _subColor {
    switch (car.subscription) {
      case SubscriptionType.standard:
        return AppColors.primary;
      case SubscriptionType.shared:
        return const Color(0xFF7C3AED);
      case SubscriptionType.vip:
        return AppColors.warning;
      case SubscriptionType.none:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    final subLabel = switch (car.subscription) {
      SubscriptionType.standard => l.garageSubActive(l.statusStandard),
      SubscriptionType.shared => l.garageSubActive(l.statusShared),
      SubscriptionType.vip => l.garageSubActive(l.statusVip),
      SubscriptionType.none => l.garageNoSubscription,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: car.imageUrl != null && car.imageUrl!.isNotEmpty
                  ? Image.network(
                      car.imageUrl!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _CarColorBox(car: car),
                    )
                  : _CarColorBox(car: car),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${car.make} ${car.model}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${car.year} • ${car.color}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    car.plateNumber,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: car.subscription == SubscriptionType.none
                          ? AppColors.divider
                          : _subColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      subLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _subColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_left,
                color: AppColors.textSecondary, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Car Color Fallback Box ────────────────────────────────────────────────────

class _CarColorBox extends StatelessWidget {
  final CarInfo car;
  const _CarColorBox({required this.car});

  Color get _color {
    switch (car.color) {
      case 'أبيض': return Colors.white;
      case 'أسود': return const Color(0xFF1F2937);
      case 'رمادي': return const Color(0xFF9CA3AF);
      case 'أحمر': return const Color(0xFFDC2626);
      case 'أزرق': return const Color(0xFF1A3A8F);
      case 'فضي': return const Color(0xFFD1D5DB);
      case 'بيج': return const Color(0xFFD2B48C);
      case 'بني': return const Color(0xFF92400E);
      case 'ذهبي': return const Color(0xFFD97706);
      default: return AppColors.primarySurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWhite = car.color == 'أبيض';
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: _color.withValues(alpha: isWhite ? 1 : 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isWhite ? AppColors.divider : _color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Icon(
        Icons.directions_car_rounded,
        size: 38,
        color: isWhite ? AppColors.textSecondary : _color.withValues(alpha: 0.85),
      ),
    );
  }
}

// ── Add Car Button ────────────────────────────────────────────────────────────

class _AddCarButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddCarButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              context.l10n.garageAddCarButton,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

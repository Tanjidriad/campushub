import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/config/routes/app_router.dart';
import 'package:book_user_app/core/constants/app_icons.dart';
import 'package:book_user_app/features/chat/presentation/bloc/conversations_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_event.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({super.key});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabPulseController;
  late Animation<double> _fabPulse;

  @override
  void initState() {
    super.initState();
    _fabPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fabPulse = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.09), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.09, end: 1.0), weight: 55),
    ]).animate(
      CurvedAnimation(parent: _fabPulseController, curve: Curves.easeOut),
    );
    _runFabIntroPulse();
  }

  Future<void> _runFabIntroPulse() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final done = prefs.getBool('campushub_fab_intro_pulse_done') ?? false;
    if (done) return;
    await prefs.setBool('campushub_fab_intro_pulse_done', true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    await _fabPulseController.forward();
  }

  @override
  void dispose() {
    _fabPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String location = GoRouterState.of(context).uri.toString();

    int activeIndex = 0;
    if (location == AppRouter.home) {
      activeIndex = 0;
    } else if (location == AppRouter.wishlist) {
      activeIndex = 1;
    } else if (location == AppRouter.createListingPhotos ||
        location == AppRouter.createListingDetails ||
        location == AppRouter.createListingPrice) {
      activeIndex = 2;
    } else if (location == AppRouter.chat) {
      activeIndex = 3;
    } else if (location == AppRouter.profile ||
        location == AppRouter.editProfile) {
      activeIndex = 4;
    }

    final selectedColor = AppColors.of(context).success;
    final unselectedColor = AppColors.of(context).textSecondary;
    final colors = AppColors.of(context);

    return Container(
      height: 55 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: colors.card.withOpacity(0.94),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(color: colors.border.withOpacity(0.5)),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem(
                  context: context,
                  index: 0,
                  activeIndex: activeIndex,
                  title: l10n.home,
                  svgPath: AppIcons.homeIcon,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                  onTap: () => context.go(AppRouter.home),
                ),
                _buildNavItem(
                  context: context,
                  index: 1,
                  activeIndex: activeIndex,
                  title: l10n.saved,
                  svgPath: AppIcons.favouriteIcon,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                  onTap: _openSavedAndSync,
                ),
                const SizedBox(width: 80),
                _buildChatNavItem(
                  context: context,
                  index: 3,
                  activeIndex: activeIndex,
                  title: l10n.chat,
                  svgPath: AppIcons.chatIcon,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                  onTap: () => context.go(AppRouter.chat),
                ),
                _buildNavItem(
                  context: context,
                  index: 4,
                  activeIndex: activeIndex,
                  title: l10n.profile,
                  svgPath: AppIcons.profileIcon,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                  onTap: () => context.go(AppRouter.profile),
                ),
              ],
            ),
          ),
          Positioned(
            top: -28,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: Semantics(
                label: l10n.createNewListing,
                button: true,
                child: ScaleTransition(
                  scale: _fabPulse,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.push(AppRouter.createListingPhotos),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: selectedColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.of(context).card,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.of(
                                  context,
                                ).success.withOpacity(0.28),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.add,
                            color: AppColors.of(context).card,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.add,
                          style: TextStyle(
                            color: activeIndex == 2
                                ? selectedColor
                                : unselectedColor,
                            fontSize: 10,
                            fontWeight: activeIndex == 2
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSavedAndSync() async {
    await context.push(AppRouter.wishlist);
    if (!mounted) return;
    ListingsBloc? listingsBloc;
    try {
      listingsBloc = context.read<ListingsBloc>();
    } catch (_) {
      listingsBloc = null;
    }
    // Home uses ListingsBloc; refresh after returning from Saved so hearts sync.
    listingsBloc?.add(const ListingsRefreshRequested());
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int activeIndex,
    required String title,
    required String svgPath,
    required Color selectedColor,
    required Color unselectedColor,
    required VoidCallback onTap,
  }) {
    final isSelected = activeIndex == index;
    final color = isSelected ? selectedColor : unselectedColor;

    return Semantics(
      label: '$title tab',
      button: true,
      selected: isSelected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: neighborsWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                height: 3,
                width: isSelected ? 22 : 0,
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 5),
              AnimatedScale(
                scale: isSelected ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: SvgPicture.asset(
                  svgPath,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  width: 24,
                  height: 24,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                child: Text(title),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const double neighborsWidth = 65;

  Widget _buildChatNavItem({
    required BuildContext context,
    required int index,
    required int activeIndex,
    required String title,
    required String svgPath,
    required Color selectedColor,
    required Color unselectedColor,
    required VoidCallback onTap,
  }) {
    final isSelected = activeIndex == index;
    final color = isSelected ? selectedColor : unselectedColor;
    final selectedColorForPill = selectedColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: neighborsWidth,
        child: BlocBuilder<ConversationsBloc, ConversationsState>(
          builder: (context, state) {
            final bloc = context.read<ConversationsBloc>();
            final userId = bloc.currentUserId ?? '';
            final unreadCount = state.getTotalUnreadFor(userId);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  height: 3,
                  width: isSelected ? 22 : 0,
                  decoration: BoxDecoration(
                    color: selectedColorForPill,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 5),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedScale(
                      scale: isSelected ? 1.08 : 1.0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      child: SvgPicture.asset(
                        svgPath,
                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                        width: 24,
                        height: 24,
                      ),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: -6,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.of(context).error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: TextStyle(
                                color: AppColors.of(context).card,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  child: Text(title),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

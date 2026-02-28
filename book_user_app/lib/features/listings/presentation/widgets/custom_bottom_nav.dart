import 'package:book_user_app/config/routes/app_router.dart';
import 'package:book_user_app/core/constants/app_icons.dart';
import 'package:book_user_app/features/chat/presentation/bloc/conversations_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    // Map current location to tab index
    int activeIndex = 0; // Default Home
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

    const selectedColor = Color(0xFF15833B); // Action Green
    const unselectedColor = Colors.grey;

    return Container(
      // Accommodate safe area at the bottom for modern phones
      height: 55 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main Nav Items Row
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
                  title: "Home",
                  svgPath: AppIcons.homeIcon,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                  onTap: () => context.go(AppRouter.home),
                ),
                _buildNavItem(
                  context: context,
                  index: 1,
                  activeIndex: activeIndex,
                  title: "Saved",
                  svgPath: AppIcons.favouriteIcon,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                  onTap: () => context.push(AppRouter.wishlist),
                ),
                // Empty space for the center FAB
                const SizedBox(width: 80),
                _buildChatNavItem(
                  context: context,
                  index: 3,
                  activeIndex: activeIndex,
                  title: "Chat",
                  svgPath: AppIcons.chatIcon,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                  onTap: () => context.go(AppRouter.chat),
                ),
                _buildNavItem(
                  context: context,
                  index: 4,
                  activeIndex: activeIndex,
                  title: "Profile",
                  svgPath: AppIcons.profileIcon,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                  onTap: () => context.go(AppRouter.profile),
                ),
              ],
            ),
          ),
          // Prominent Center FAB ("Add" Button) - Static Green, Doesn't move
          Positioned(
            top:
                -28, // Elevate it slightly like style15 persistent_bottom_nav_bar
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
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
                        color: selectedColor, // Always green
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ), // Optional border to separate it from the bar
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3315833B), // Soft green shadow
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Add",
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
        ],
      ),
    );
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 65, // Constrain width for balanced spacing
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgPath,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              width: 24,
              height: 24,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 65,
        child: BlocBuilder<ConversationsBloc, ConversationsState>(
          builder: (context, state) {
            final bloc = context.read<ConversationsBloc>();
            final userId = bloc.currentUserId ?? '';
            final unreadCount = state.getTotalUnreadFor(userId);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SvgPicture.asset(
                      svgPath,
                      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                      width: 24,
                      height: 24,
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
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
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
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

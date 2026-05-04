import 'package:book_user_app/core/constants/api_constants.dart';
import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:book_user_app/features/auth/presentation/widgets/onboarding_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  int _currentIndex = 0;

  Future<void> _navigateToLogin() async {
    // Mark onboarding as seen
    await _secureStorage.write(
      key: StorageKeys.hasSeenOnboarding,
      value: 'true',
    );
    if (mounted) context.go('/login');
  }

  late List<OnboardingContent> _contents;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _contents = [
      OnboardingContent(
        isSplash: true,
        image: "assets/images/onboarding/onboarding_1.jpg",
        title: l10n.onboardingTitle1,
        description: l10n.onboardingDescription1,
      ),
      OnboardingContent(
        image: "assets/images/onboarding/onboarding_2.jpg",
        title: l10n.onboardingTitle2,
        description: l10n.onboardingDescription2,
        steps: [
          OnboardingStep(
            icon: 'search',
            title: l10n.onboardingStepSearchFilter,
            description: l10n.onboardingStepSearchFilterDesc,
          ),
          OnboardingStep(
            icon: 'message',
            title: l10n.onboardingStepChatSecurely,
            description: l10n.onboardingStepChatSecurelyDesc,
          ),
          OnboardingStep(
            icon: 'location',
            title: l10n.onboardingStepMeetOnCampus,
            description: l10n.onboardingStepMeetOnCampusDesc,
          ),
        ],
      ),
      OnboardingContent(
        image: "assets/images/onboarding/onboarding_3.jpg",
        title: l10n.onboardingTitle3,
        description: l10n.onboardingDescription3,
        steps: [
          OnboardingStep(
            icon: 'camera',
            title: l10n.onboardingStepSnapPhoto,
            description: l10n.onboardingStepSnapPhotoDesc,
          ),
          OnboardingStep(
            icon: 'tag',
            title: l10n.onboardingStepSetPrice,
            description: l10n.onboardingStepSetPriceDesc,
          ),
          OnboardingStep(
            icon: 'handshake',
            title: l10n.onboardingStepMeetDeal,
            description: l10n.onboardingStepMeetOnCampusDesc,
          ),
        ],
      ),
    ];
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _contents.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final content = _contents[index];
              if (content.isSplash) {
                return _buildSplashPage(content);
              } else {
                return _buildFeaturePage(content);
              }
            },
          ),

          // Skip Button (Top Right)
          if (_currentIndex != _contents.length - 1)
            Positioned(
              top: 50.h,
              right: 20.w,
              child: TextButton(
                onPressed: _navigateToLogin,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.of(context).surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                child: Text(
                  l10n.skip,
                  style: TextStyle(
                    color: AppColors.of(context).textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSplashPage(OnboardingContent content) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 20.h),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    image: DecorationImage(
                      image: AssetImage(content.image),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.of(
                          context,
                        ).textPrimary.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Positioned(
                  bottom: 20.h,
                  right: 20.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.of(context).surface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.of(
                            context,
                          ).textPrimary.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: AppColors.of(
                              context,
                            ).accent.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: AppColors.of(context).accent,
                            size: 14.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.statusLabel,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.of(context).textSecondary,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              l10n.studentVerified,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.of(context).textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                _buildDots(),
                SizedBox(height: 24.h),
                Text(
                  content.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.of(context).textPrimary,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  content.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.of(context).textSecondary,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 56.h),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.getStarted),
                      SizedBox(width: 8.w),
                      const Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                TextButton(
                  onPressed: _navigateToLogin,
                  child: RichText(
                    text: TextSpan(
                      text: l10n.alreadyHaveAccount,
                      style: TextStyle(
                        color: AppColors.of(context).textSecondary,
                        fontSize: 14.sp,
                      ),
                      children: [
                        TextSpan(
                          text: l10n.logIn,
                          style: TextStyle(
                            color: AppColors.of(context).primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturePage(OnboardingContent content) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Image Header
        Container(
          height: 320.h,
          width: double.infinity,
          margin: EdgeInsets.all(16.w),
          padding: EdgeInsets.only(top: 40.h),
          decoration: BoxDecoration(
            color: AppColors.of(context).surface,
            borderRadius: BorderRadius.circular(24.r),
            image: DecorationImage(
              image: AssetImage(content.image),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              ),
            ),
            padding: EdgeInsets.all(24.w),
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: TextStyle(
                    color: AppColors.of(context).onPrimary,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  content.description,
                  style: TextStyle(
                    color: AppColors.of(context).onPrimary.withOpacity(0.9),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Steps List
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: content.steps?.length ?? 0,
              separatorBuilder: (c, i) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final step = content.steps![index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: AppColors.of(context).primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        _getIcon(step.icon),
                        color: AppColors.of(context).primary,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.title,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.of(context).textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            step.description,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.of(context).textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        // Bottom Controls
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
          child: Column(
            children: [
              _buildDots(),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  if (_currentIndex == _contents.length - 1) {
                    _navigateToLogin();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 56.h),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentIndex == _contents.length - 1
                          ? l10n.getStarted
                          : l10n.next,
                    ),
                    SizedBox(width: 8.w),
                    const Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_contents.length, (index) {
        final isActive = index == _currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          height: 8.h,
          width: isActive ? 32.w : 8.w,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.of(context).primary
                : AppColors.of(context).border,
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'search':
        return Iconsax.search_normal;
      case 'message':
        return Iconsax.message;
      case 'location':
        return Iconsax.location;
      case 'camera':
        return Iconsax.camera;
      case 'tag':
        return Iconsax.tag;
      case 'handshake':
        return Icons.handshake_rounded; // Material Icon as fallback
      default:
        return Iconsax.star;
    }
  }
}

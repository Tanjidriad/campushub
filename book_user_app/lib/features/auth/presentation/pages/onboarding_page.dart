import 'package:book_user_app/core/constants/api_constants.dart';
import 'package:book_user_app/core/theme/app_palette.dart';
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

  final List<OnboardingContent> _contents = [
    // Screen 1 (Splash/Intro)
    const OnboardingContent(
      isSplash: true,
      image:
          "https://lh3.googleusercontent.com/aida-public/AB6AXuBdTYwVm70L7jI50awq3a-KePJP_Po6lCJXl2bo4-sEs9bFj0K25E5fT7tw1jDEdKXsCuDE6llWigMZ27QBb_HZNcbVUPxzz-WTTJ2tEGvPo-cqtM5s5elYd1ISGTPNKX_lf3GFB5q8StgrqF-cfkk7ZYklMovL-7EgGEFEsHqqn8JJ4leoVXQUdyMOByhF0Of9Vgm2bN3hPuGzz6ibxTPiUpn0O__gjpla66mIFwXYVIfThGK0U46sdgWkn1uNlzfPwdTavtrRWJ8",
      title: "Your Campus.\nYour Marketplace.",
      description:
          "Turn your old textbooks into cash and find great deals on dorm essentials. Safe, local, and student-verified.",
    ),
    // Screen 2 (Shop)
    const OnboardingContent(
      image:
          "https://lh3.googleusercontent.com/aida-public/AB6AXuDBtAozbigN-LnAGEbWtGMTXbMTgXyq4ZwIfyqc3-22OxeUt--31j7kiGFKkfti3HzCKKuRXo5FzjTwIluYkiafvl-tUVg0lglBECJYpsGr1JavsAU3oAbgv_oLv129hAxCbbQt8csoxeY2kyMP9jvBpLVTrowwwWqe7I-SDg5zTZlRejMQSUgG_Yr27jKteI4UM1ewlHW7qHahfP0NLIpvJzkNilRKLsJCGLZqikCFbep5pLbaZMLLGymM-rORNNtyt9BAVUpKATg",
      title: "Shop Your Campus",
      description:
          "Safe, local deals from students near you. Buy textbooks, furniture, and more.",
      steps: [
        OnboardingStep(
          icon: 'search',
          title: "Search & Filter",
          description:
              "Find exactly what you need by category or dorm location.",
        ),
        OnboardingStep(
          icon: 'message',
          title: "Chat Securely",
          description:
              "Message sellers directly in-app to ask questions and negotiate.",
        ),
        OnboardingStep(
          icon: 'location',
          title: "Meet on Campus",
          description:
              "Safe exchange at designated campus spots like the student union.",
        ),
      ],
    ),
    // Screen 3 (Sell)
    const OnboardingContent(
      image:
          "https://lh3.googleusercontent.com/aida-public/AB6AXuAi6Ndk9It5HZQ3yIaZUCXOIEUKgyS8yZny6Zd7SDz2HuC_3ywNdwVFdxHeA6ntZFc_mcM4v6XO3428YklnsaaOuXqvlmjofCTozwun6m5iiJmfP5sJdzn2-wJYsXS3zOzLcMRoM3vntuGxURFlAfNB-mnY0nrXGPzOFFzYhIacS5NiKtUkR1GEkfq0DRFodLTpCpyBXv_Z0ASnE7zRKgJnctFZRbS-C-bhFTvw564rODoJBr3W9EO0e03ktlwOOKluQqCcmuqYNr8",
      title: "Sell in Seconds",
      description:
          "Turn your clutter into cash. Post textbooks, gadgets, and gear to students on your campus.",
      steps: [
        OnboardingStep(
          icon: 'camera',
          title: "Snap a Photo",
          description: "Take a clear picture of your item directly in the app.",
        ),
        OnboardingStep(
          icon: 'tag',
          title: "Set Your Price",
          description: "Add a description and set a fair price for students.",
        ),
        OnboardingStep(
          icon: 'handshake',
          title: "Meet on Campus",
          description: "Chat securely and arrange a safe meetup spot nearby.",
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
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
                  backgroundColor: AppPalette.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                child: Text(
                  "Skip",
                  style: TextStyle(
                    color: AppPalette.textSecondary,
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
                      image: NetworkImage(content.image),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
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
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
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
                            color: AppPalette.accent.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: AppPalette.accent,
                            size: 14.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "STATUS",
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: AppPalette.textSecondary,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              "Student Verified",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: AppPalette.textPrimary,
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
                    color: AppPalette.textPrimary,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  content.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppPalette.textSecondary,
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
                      const Text("Get Started"),
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
                      text: "Already have an account? ",
                      style: TextStyle(
                        color: AppPalette.textSecondary,
                        fontSize: 14.sp,
                      ),
                      children: [
                        TextSpan(
                          text: "Log in",
                          style: TextStyle(
                            color: AppPalette.primary,
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
    return Column(
      children: [
        // Image Header
        Container(
          height: 320.h,
          width: double.infinity,
          margin: EdgeInsets.all(16.w),
          padding: EdgeInsets.only(top: 40.h),
          decoration: BoxDecoration(
            color: AppPalette.surface,
            borderRadius: BorderRadius.circular(24.r),
            image: DecorationImage(
              image: NetworkImage(content.image),
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
                    color: Colors.white,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  content.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
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
                        color: AppPalette.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        _getIcon(step.icon),
                        color: AppPalette.primary,
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
                              color: AppPalette.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            step.description,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppPalette.textSecondary,
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
                          ? "Get Started"
                          : "Next",
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
            color: isActive ? AppPalette.primary : AppPalette.border,
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

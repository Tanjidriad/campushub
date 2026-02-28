import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// Reusable loading widget using SpinKit animations.
/// Drop-in replacement for CircularProgressIndicator.
class AppLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoader({super.key, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCube(color: color ?? AppPalette.primary, size: size.sp);
  }
}

/// Small inline loader for buttons and compact spaces.
class AppLoaderSmall extends StatelessWidget {
  final Color? color;

  const AppLoaderSmall({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return SpinKitThreeBounce(color: color ?? Colors.white, size: 20.sp);
  }
}

/// Full-page centered loading state.
class AppLoaderFullPage extends StatelessWidget {
  final String? message;

  const AppLoaderFullPage({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitFadingCube(color: AppPalette.primary, size: 40.sp),
          if (message != null) ...[
            SizedBox(height: 16.h),
            Text(
              message!,
              style: TextStyle(
                color: AppPalette.textSecondary,
                fontSize: 14.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

/// A cached network image with standardised placeholder and error handling.
class AppCachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final IconData errorIcon;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.errorIcon = Icons.image_not_supported_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    Widget child;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      child = CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) =>
            placeholder ??
            Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.border,
              ),
            ),
        errorWidget: (context, url, error) =>
            errorWidget ?? Icon(errorIcon, color: colors.border, size: 32.sp),
      );
    } else {
      child =
          errorWidget ??
          Center(
            child: Icon(
              Icons.image_outlined,
              color: colors.border,
              size: 32.sp,
            ),
          );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }
}

/// A cached circle avatar with placeholder icon/initials fallback.
class AppCachedAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Color? backgroundColor;
  final Widget? fallbackIcon;

  const AppCachedAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 20,
    this.backgroundColor,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bg = backgroundColor ?? colors.subtleFill;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return CircleAvatar(
      radius: radius.r,
      backgroundColor: bg,
      backgroundImage: hasImage ? CachedNetworkImageProvider(imageUrl!) : null,
      child: hasImage
          ? null
          : fallbackIcon ??
                Icon(
                  Iconsax.user,
                  color: colors.textSecondary,
                  size: (radius * 1.0).sp,
                ),
    );
  }
}

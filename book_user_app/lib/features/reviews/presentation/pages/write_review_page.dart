import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/app_snackbar.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:book_user_app/features/reviews/presentation/bloc/reviews_bloc.dart';
import 'package:book_user_app/features/reviews/presentation/bloc/reviews_event.dart';
import 'package:book_user_app/features/reviews/presentation/bloc/reviews_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class WriteReviewPage extends StatefulWidget {
  final String sellerId;
  final String sellerName;
  final String? sellerAvatar;
  final String? listingId;
  final String? listingTitle;

  const WriteReviewPage({
    super.key,
    required this.sellerId,
    required this.sellerName,
    this.sellerAvatar,
    this.listingId,
    this.listingTitle,
  });

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage>
    with SingleTickerProviderStateMixin {
  int _rating = 0;
  final _commentController = TextEditingController();
  late AnimationController _animController;

  List<String> _ratingLabels(AppLocalizations l10n) => [
    '',
    l10n.ratingPoor,
    l10n.ratingFair,
    l10n.ratingGood,
    l10n.ratingVeryGood,
    l10n.ratingExcellent,
  ];

  static const _ratingEmojis = ['', '😞', '😐', '🙂', '😊', '🤩'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _setRating(int value) {
    setState(() => _rating = value);
    _animController.forward(from: 0);
  }

  void _submitReview() {
    final l10n = AppLocalizations.of(context)!;
    if (_rating == 0) {
      AppSnackBar.showWarning(context, l10n.pleaseSelectRating);
      return;
    }

    context.read<ReviewsBloc>().add(
      SubmitReviewRequested(
        sellerId: widget.sellerId,
        listingId: widget.listingId,
        rating: _rating,
        comment: _commentController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<ReviewsBloc, ReviewsState>(
      listener: (context, state) {
        if (state is ReviewSubmitted) {
          final l10n = AppLocalizations.of(context)!;
          AppSnackBar.showSuccess(context, l10n.reviewSubmittedSuccess);
          context.pop(true);
        } else if (state is ReviewSubmitError) {
          AppSnackBar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.of(context).background,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.of(context).background,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.of(context).card,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.arrow_left,
                size: 20.sp,
                color: AppColors.of(context).textPrimary,
              ),
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            l10n.writeAReview,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.of(context).textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 16.h),

              // Seller card
              _buildSellerCard(),
              SizedBox(height: 28.h),

              // Rating section
              _buildRatingSection(),
              SizedBox(height: 28.h),

              // Comment section
              _buildCommentSection(),
              SizedBox(height: 32.h),

              // Submit button
              _buildSubmitButton(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSellerCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.of(context).card,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.of(context).textPrimary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.of(context).primary.withValues(alpha: 0.15),
                  AppColors.of(context).accent.withValues(alpha: 0.15),
                ],
              ),
              border: Border.all(
                color: AppColors.of(context).primary.withValues(alpha: 0.3),
                width: 2,
              ),
              image: widget.sellerAvatar != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(widget.sellerAvatar!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: widget.sellerAvatar == null
                ? Icon(
                    Icons.person,
                    size: 28.sp,
                    color: AppColors.of(context).primary,
                  )
                : null,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.sellerName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.of(context).textPrimary,
                  ),
                ),
                if (widget.listingTitle != null) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Iconsax.book,
                        size: 14.sp,
                        color: AppColors.of(context).primary,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          widget.listingTitle!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.of(context).textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.of(context).card,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.of(context).textPrimary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.howWasYourExperience,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.of(context).textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            l10n.tapStarToRate,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.of(context).textLight,
            ),
          ),
          SizedBox(height: 20.h),

          // Stars row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              final isSelected = starIndex <= _rating;
              return GestureDetector(
                onTap: () => _setRating(starIndex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: AnimatedScale(
                    scale: isSelected ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isSelected
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 44.sp,
                      color: isSelected
                          ? AppColors.of(context).warning
                          : AppColors.of(context).textLight,
                    ),
                  ),
                ),
              );
            }),
          ),

          // Rating label with animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: _rating > 0
                ? Padding(
                    key: ValueKey(_rating),
                    padding: EdgeInsets.only(top: 16.h),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getRatingColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _ratingEmojis[_rating],
                            style: TextStyle(fontSize: 18.sp),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _ratingLabels(l10n)[_rating],
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: _getRatingColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox(key: const ValueKey(0), height: 16.h),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor() {
    switch (_rating) {
      case 1:
        return AppColors.of(context).error;
      case 2:
        return AppColors.of(context).warning; // Orange
      case 3:
        return AppColors.of(context).warning;
      case 4:
        return AppColors.of(context).success; // Green
      case 5:
        return AppColors.of(context).success;
      default:
        return AppColors.of(context).textSecondary;
    }
  }

  Widget _buildCommentSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Iconsax.edit_2,
              size: 18.sp,
              color: AppColors.of(context).primary,
            ),
            SizedBox(width: 8.w),
            Text(
              l10n.writeYourFeedback,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.of(context).textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              l10n.optionalLabel,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.of(context).textLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        TextField(
          controller: _commentController,
          maxLines: 4,
          maxLength: 500,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.of(context).textPrimary,
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText: l10n.reviewHintText,
            hintStyle: TextStyle(
              fontSize: 13.sp,
              color: AppColors.of(context).textLight,
              height: 1.5,
            ),
            filled: true,
            fillColor: AppColors.of(context).subtleFill,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.of(context).border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.of(context).border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppColors.of(context).primary,
                width: 1.5,
              ),
            ),
            counterStyle: TextStyle(
              fontSize: 11.sp,
              color: AppColors.of(context).textLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ReviewsBloc, ReviewsState>(
      builder: (context, state) {
        final isSubmitting = state is ReviewSubmitting;
        return SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.of(context).primary,
              foregroundColor: AppColors.of(context).onPrimary,
              disabledBackgroundColor: AppColors.of(
                context,
              ).primary.withValues(alpha: 0.5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            child: isSubmitting
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      color: AppColors.of(context).card,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.send_1, size: 20.sp),
                      SizedBox(width: 10.w),
                      Text(
                        l10n.submitReview,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

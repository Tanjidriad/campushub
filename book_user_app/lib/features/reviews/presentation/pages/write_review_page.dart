import 'package:book_user_app/core/theme/app_palette.dart';
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

  static const _ratingLabels = [
    '',
    'Poor',
    'Fair',
    'Good',
    'Very Good',
    'Excellent',
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
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a rating'),
          backgroundColor: AppPalette.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
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
    return BlocListener<ReviewsBloc, ReviewsState>(
      listener: (context, state) {
        if (state is ReviewSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Review submitted successfully!'),
                ],
              ),
              backgroundColor: AppPalette.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
          context.pop(true);
        } else if (state is ReviewSubmitError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppPalette.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppPalette.background,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: AppPalette.background,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.arrow_left, size: 20.sp, color: Colors.black),
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Write a Review',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppPalette.textPrimary,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                  AppPalette.primary.withValues(alpha: 0.15),
                  AppPalette.accent.withValues(alpha: 0.15),
                ],
              ),
              border: Border.all(
                color: AppPalette.primary.withValues(alpha: 0.3),
                width: 2,
              ),
              image: widget.sellerAvatar != null
                  ? DecorationImage(
                      image: NetworkImage(widget.sellerAvatar!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: widget.sellerAvatar == null
                ? Icon(Icons.person, size: 28.sp, color: AppPalette.primary)
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
                    color: AppPalette.textPrimary,
                  ),
                ),
                if (widget.listingTitle != null) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Iconsax.book,
                        size: 14.sp,
                        color: AppPalette.primary,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          widget.listingTitle!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppPalette.textSecondary,
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
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'How was your experience?',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppPalette.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Tap a star to rate the seller',
            style: TextStyle(fontSize: 13.sp, color: AppPalette.textLight),
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
                          ? const Color(0xFFFBBF24)
                          : AppPalette.gray400,
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
                            _ratingLabels[_rating],
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
        return AppPalette.error;
      case 2:
        return const Color(0xFFF97316); // Orange
      case 3:
        return AppPalette.warning;
      case 4:
        return const Color(0xFF22C55E); // Green
      case 5:
        return AppPalette.success;
      default:
        return AppPalette.textSecondary;
    }
  }

  Widget _buildCommentSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.edit_2, size: 18.sp, color: AppPalette.primary),
              SizedBox(width: 8.w),
              Text(
                'Write your feedback',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'Optional',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppPalette.textLight,
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
              color: AppPalette.textPrimary,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText:
                  'Share your experience with this seller...\n\nWas the item as described? Was the seller responsive?',
              hintStyle: TextStyle(
                fontSize: 13.sp,
                color: AppPalette.textLight,
                height: 1.5,
              ),
              filled: true,
              fillColor: AppPalette.gray50,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppPalette.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppPalette.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppPalette.primary, width: 1.5),
              ),
              counterStyle: TextStyle(
                fontSize: 11.sp,
                color: AppPalette.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<ReviewsBloc, ReviewsState>(
      builder: (context, state) {
        final isSubmitting = state is ReviewSubmitting;
        return SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppPalette.primary.withValues(
                alpha: 0.5,
              ),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            child: isSubmitting
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.send_1, size: 20.sp),
                      SizedBox(width: 10.w),
                      Text(
                        'Submit Review',
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

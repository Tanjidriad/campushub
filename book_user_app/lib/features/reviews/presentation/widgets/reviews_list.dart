import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:book_user_app/features/reviews/domain/entities/review.dart';
import 'package:book_user_app/features/reviews/presentation/bloc/reviews_bloc.dart';
import 'package:book_user_app/features/reviews/presentation/bloc/reviews_state.dart';
import 'package:book_user_app/core/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ReviewsList extends StatelessWidget {
  const ReviewsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewsBloc, ReviewsState>(
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        if (state is ReviewsLoading) {
          return const AppLoaderFullPage();
        } else if (state is ReviewsError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is ReviewsLoaded) {
          if (state.reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 48.sp,
                    color: AppColors.of(context).textSecondary,
                  ),
                  SizedBox(height: 16.h),
                  Text(l10n.noReviewsYet),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.reviews.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              return ReviewItem(review: state.reviews[index]);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class ReviewItem extends StatelessWidget {
  final Review review;

  const ReviewItem({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.of(context).textPrimary.withOpacity(0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundImage: review.reviewerAvatar != null
                    ? CachedNetworkImageProvider(review.reviewerAvatar!)
                    : null,
                child: review.reviewerAvatar == null
                    ? Icon(
                        Icons.person,
                        color: AppColors.of(context).textSecondary,
                      )
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, y').format(review.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.of(context).textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: AppColors.of(context).warning,
                    size: 16.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    review.rating.toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(review.comment),
          if (review.listingTitle != null) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.of(context).subtleFill,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                l10n.itemLabel(review.listingTitle!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.of(context).textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

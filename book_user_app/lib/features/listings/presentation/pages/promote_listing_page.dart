import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/app_cached_image.dart';
import 'package:book_user_app/core/widgets/app_snackbar.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_event.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_state.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

class PromoteListingPage extends StatefulWidget {
  final Listing listing;

  const PromoteListingPage({super.key, required this.listing});

  @override
  State<PromoteListingPage> createState() => _PromoteListingPageState();
}

class _PromoteListingPageState extends State<PromoteListingPage> {
  String _selectedPlan = '7days';

  // Theme-aware color aliases
  Color get _primaryColor => AppColors.of(context).accent;
  Color get _accentGreen => AppColors.of(context).success;
  Color get _textMain => AppColors.of(context).textPrimary;
  Color get _textSecondary => AppColors.of(context).textSecondary;
  Color get _backgroundLight => AppColors.of(context).background;

  List<_Plan> _getPlans(AppLocalizations l10n) => [
    _Plan('3days', l10n.threeDays, '\$2.99', l10n.goodForQuickSales, null),
    _Plan(
      '7days',
      l10n.sevenDays,
      '\$4.99',
      l10n.recommendedDuration,
      l10n.mostPopular,
    ),
    _Plan(
      '30days',
      l10n.thirtyDays,
      '\$14.99',
      l10n.maximumExposure,
      l10n.bestValue,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<ListingsBloc, ListingsState>(
      listener: (context, state) {
        debugPrint(
          '🔵 PromotePage BlocListener: state=$state, mounted=$mounted',
        );
        if (!mounted) return;
        try {
          if (state is ListingPromoted) {
            debugPrint(
              '🔵 PromotePage: ListingPromoted received, about to pop',
            );
            Navigator.of(context).pop(true);
            debugPrint('🔵 PromotePage: pop called successfully');
          } else if (state is ListingsError) {
            debugPrint('🔵 PromotePage: ListingsError: ${state.message}');
            AppSnackBar.showError(context, state.message);
          }
        } catch (e, stack) {
          debugPrint('🔴 PromotePage BlocListener CRASH: $e');
          debugPrint('🔴 Stack: $stack');
        }
      },
      child: Scaffold(
        backgroundColor: _backgroundLight,
        appBar: AppBar(
          title: Text(
            l10n.promoteListing,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: _textMain,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.of(context).surface.withOpacity(0.9),
          foregroundColor: _textMain,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: AppColors.of(context).subtleFill,
              height: 1,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 140.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPreviewSection(),
              SizedBox(height: 24.h),
              _buildBenefitsSection(),
              SizedBox(height: 24.h),
              _buildPlanSelection(),
            ],
          ),
        ),
        bottomSheet: _buildBottomBar(),
      ),
    );
  }

  // ─── Preview Section ──────────────────────────────────────────────

  Widget _buildPreviewSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
          child: Text(
            l10n.previewOnFeed,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: _textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.of(context).card,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.of(context).subtleFill),
            boxShadow: [
              BoxShadow(
                color: AppColors.of(context).textPrimary.withOpacity(0.06),
                blurRadius: 30,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Area
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12.r),
                    ),
                    child: Container(
                      height: 192.h,
                      width: double.infinity,
                      color: AppColors.of(context).border,
                      child: widget.listing.primaryImageUrl != null
                          ? AppCachedImage(
                              imageUrl: widget.listing.primaryImageUrl,
                              fit: BoxFit.cover,
                              errorWidget: _imagePlaceholder(),
                            )
                          : _imagePlaceholder(),
                    ),
                  ),
                  // Gradient Overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 64.h,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // FEATURED Badge
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: _accentGreen,
                        borderRadius: BorderRadius.circular(6.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.of(
                              context,
                            ).textPrimary.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16.sp,
                            color: AppColors.of(context).onPrimary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            l10n.featuredBadge,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.of(context).card,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Info Area
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            widget.listing.title,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: _textMain,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          widget.listing.formattedPrice,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.listing.category} • ${widget.listing.condition.replaceAll('-', ' ').toUpperCase()}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: _textSecondary,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: _accentGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          child: Text(
                            l10n.promoted,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: _accentGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Center(
          child: Text(
            l10n.previewDescription,
            style: TextStyle(fontSize: 12.sp, color: _textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Center(
      child: Icon(
        Iconsax.image,
        size: 40.sp,
        color: AppColors.of(context).textLight,
      ),
    );
  }

  // ─── Benefits Section ─────────────────────────────────────────────

  Widget _buildBenefitsSection() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.of(context).card,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.of(context).subtleFill),
        boxShadow: [
          BoxShadow(
            color: AppColors.of(context).textPrimary.withOpacity(0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: _primaryColor, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                l10n.whyFeature,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: _textMain,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBenefitItem(
                Icons.visibility_outlined,
                l10n.fiveXMoreViews,
                Colors.blue,
              ),
              _buildBenefitItem(
                Icons.rocket_launch_outlined,
                l10n.sellTwoXFaster,
                Colors.green,
              ),
              _buildBenefitItem(Icons.verified, l10n.buildTrust, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String label, MaterialColor color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            margin: EdgeInsets.only(bottom: 8.h),
            decoration: BoxDecoration(color: color[50], shape: BoxShape.circle),
            child: Icon(icon, color: color[500], size: 24.sp),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: _textMain,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Plan Selection ───────────────────────────────────────────────

  Widget _buildPlanSelection() {
    final l10n = AppLocalizations.of(context)!;
    final plans = _getPlans(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
          child: Text(
            l10n.selectDuration,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: _textMain,
            ),
          ),
        ),
        ...plans.map((plan) => _buildPlanCard(plan)),
      ],
    );
  }

  Widget _buildPlanCard(_Plan plan) {
    final isSelected = _selectedPlan == plan.id;
    final badgeColor = plan.badge == 'Most Popular'
        ? _accentGreen
        : _primaryColor;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan.id),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.of(context).card,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected
                    ? _primaryColor.withOpacity(0.5)
                    : AppColors.of(context).border,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.of(context).textPrimary.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                // Radio Circle
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? _primaryColor
                          : AppColors.of(context).border,
                      width: isSelected ? 6 : 2,
                    ),
                    color: AppColors.of(context).card,
                  ),
                ),
                SizedBox(width: 16.w),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.label,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? _primaryColor : _textMain,
                        ),
                      ),
                      Text(
                        plan.description,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Price
                Text(
                  plan.price,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: _textMain,
                  ),
                ),
              ],
            ),
          ),
          // Highlight Overlay (Selected State)
          if (isSelected) ...[
            Positioned.fill(
              bottom: 12.h,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: _primaryColor, width: 2),
                ),
              ),
            ),
            Positioned.fill(
              bottom: 12.h,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: _primaryColor.withOpacity(0.05),
                ),
              ),
            ),
          ],
          // Badge
          if (plan.badge != null)
            Positioned(
              top: -10.h,
              right: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(100.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.of(context).textPrimary.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  plan.badge!.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.of(context).card,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Bottom Bar ───────────────────────────────────────────────────

  Widget _buildBottomBar() {
    final l10n = AppLocalizations.of(context)!;
    final plans = _getPlans(l10n);
    final selectedPlanData = plans.firstWhere((p) => p.id == _selectedPlan);

    return BlocBuilder<ListingsBloc, ListingsState>(
      builder: (context, state) {
        final isLoading = state is ListingPromoting;

        return Container(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
          decoration: BoxDecoration(
            color: AppColors.of(context).card,
            border: Border(
              top: BorderSide(color: AppColors.of(context).subtleFill),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.of(context).textPrimary.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selected Plan Summary
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Selected Plan',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: _textSecondary,
                      ),
                    ),
                    Text(
                      '${selectedPlanData.label} Feature',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: _textMain,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              // Action Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _textSecondary,
                        ),
                      ),
                      Text(
                        selectedPlanData.price,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: _textMain,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 24.w),
                  Expanded(
                    child: SizedBox(
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                context.read<ListingsBloc>().add(
                                  PromoteListingRequested(
                                    listingId: widget.listing.id,
                                    plan: _selectedPlan,
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: AppColors.of(context).onPrimary,
                          elevation: 8,
                          shadowColor: _primaryColor.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 24.w,
                                height: 24.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.of(context).card,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Promote Now',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Icon(Icons.arrow_forward, size: 20.sp),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Plan {
  final String id;
  final String label;
  final String price;
  final String description;
  final String? badge;

  const _Plan(this.id, this.label, this.price, this.description, this.badge);
}

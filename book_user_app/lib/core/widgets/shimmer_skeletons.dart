import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─── Base Shimmer Box ───
class _ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const _ShimmerBox({
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.of(context).card,
        borderRadius: shape == BoxShape.circle
            ? null
            : (borderRadius ?? BorderRadius.circular(8.r)),
        shape: shape,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  CHAT MESSAGE SHIMMER — mimics alternating chat bubbles
// ═══════════════════════════════════════════════════════════

class ChatMessageShimmer extends StatelessWidget {
  const ChatMessageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.of(context).border,
      highlightColor: AppColors.of(context).shimmerHighlight,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Incoming message (left)
            _buildBubble(context, isMe: false, width: 0.65),
            SizedBox(height: 12.h),
            // Outgoing message (right)
            _buildBubble(context, isMe: true, width: 0.55),
            SizedBox(height: 12.h),
            // Incoming message (left, shorter)
            _buildBubble(context, isMe: false, width: 0.40),
            SizedBox(height: 12.h),
            // Outgoing message (right, longer)
            _buildBubble(context, isMe: true, width: 0.70),
            SizedBox(height: 12.h),
            // Incoming message (left)
            _buildBubble(context, isMe: false, width: 0.50),
            SizedBox(height: 12.h),
            // Outgoing message (right, short)
            _buildBubble(context, isMe: true, width: 0.35),
            SizedBox(height: 12.h),
            // Incoming (two lines)
            _buildMultiLineBubble(context, isMe: false),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(
    BuildContext context, {
    required bool isMe,
    required double width,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: width.sw,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.of(context).card,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isMe ? 18.r : 4.r),
            topRight: Radius.circular(isMe ? 4.r : 18.r),
            bottomLeft: Radius.circular(18.r),
            bottomRight: Radius.circular(18.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_ShimmerBox(width: double.infinity, height: 14.h)],
        ),
      ),
    );
  }

  Widget _buildMultiLineBubble(BuildContext context, {required bool isMe}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 0.65.sw,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.of(context).card,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isMe ? 18.r : 4.r),
            topRight: Radius.circular(isMe ? 4.r : 18.r),
            bottomLeft: Radius.circular(18.r),
            bottomRight: Radius.circular(18.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBox(width: double.infinity, height: 14.h),
            SizedBox(height: 6.h),
            _ShimmerBox(width: 0.40.sw, height: 14.h),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  CONVERSATION LIST SHIMMER — mimics message inbox rows
// ═══════════════════════════════════════════════════════════

class ConversationListShimmer extends StatelessWidget {
  final int itemCount;
  const ConversationListShimmer({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.of(context).border,
      highlightColor: AppColors.of(context).shimmerHighlight,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => Padding(
          padding: EdgeInsets.only(left: 76.w),
          child: Divider(color: AppColors.of(context).subtleFill, height: 1),
        ),
        itemBuilder: (_, index) => _buildConversationRow(index),
      ),
    );
  }

  Widget _buildConversationRow(int index) {
    // Vary widths for realistic look
    final nameWidths = [120.w, 90.w, 140.w, 100.w, 110.w, 130.w, 80.w, 105.w];
    final msgWidths = [180.w, 150.w, 200.w, 160.w, 140.w, 190.w, 170.w, 155.w];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          // Avatar circle
          _ShimmerBox(width: 52.w, height: 52.w, shape: BoxShape.circle),
          SizedBox(width: 12.w),
          // Name + message preview
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(
                  width: nameWidths[index % nameWidths.length],
                  height: 14.h,
                ),
                SizedBox(height: 8.h),
                _ShimmerBox(
                  width: msgWidths[index % msgWidths.length],
                  height: 12.h,
                ),
              ],
            ),
          ),
          // Time + badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _ShimmerBox(width: 40.w, height: 10.h),
              SizedBox(height: 8.h),
              if (index % 3 == 0)
                _ShimmerBox(
                  width: 20.w,
                  height: 20.w,
                  borderRadius: BorderRadius.circular(10.r),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  LISTING DETAIL SHIMMER — mimics the full detail page
// ═══════════════════════════════════════════════════════════

class ListingDetailShimmer extends StatelessWidget {
  const ListingDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: Column(
        children: [
          // Sticky header
          _buildHeaderShimmer(context),
          // Scrollable body
          Expanded(
            child: Shimmer.fromColors(
              baseColor: AppColors.of(context).border,
              highlightColor: AppColors.of(context).shimmerHighlight,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero image
                    _buildImageShimmer(context),
                    // Dot indicators
                    _buildDotsShimmer(context),
                    // Price + Title
                    _buildInfoShimmer(),
                    // Seller card
                    _buildSellerCardShimmer(context),
                    // Description section
                    _buildDescriptionShimmer(),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
          // Bottom bar
          _buildBottomBarShimmer(context),
        ],
      ),
    );
  }

  Widget _buildHeaderShimmer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.of(context).card,
        boxShadow: [
          BoxShadow(
            color: AppColors.of(context).textPrimary.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
          child: Row(
            children: [
              IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.arrow_back,
                  color: AppColors.of(context).border,
                ),
              ),
              const Spacer(),
              Text(
                'Ad Details',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.of(context).textPrimary,
                ),
              ),
              const Spacer(),
              SizedBox(width: 48.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageShimmer(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8.h, left: 16.w, right: 16.w),
      height: 190.h,
      decoration: BoxDecoration(
        color: AppColors.of(context).card,
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }

  Widget _buildDotsShimmer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (i) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            width: i == 0 ? 24.w : 6.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: AppColors.of(context).card,
              borderRadius: BorderRadius.circular(3.r),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInfoShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          // Price
          _ShimmerBox(width: 120.w, height: 24.h),
          SizedBox(height: 12.h),
          // Title
          _ShimmerBox(width: double.infinity, height: 20.h),
          SizedBox(height: 6.h),
          _ShimmerBox(width: 200.w, height: 20.h),
          SizedBox(height: 14.h),
          // Location + date row
          Row(
            children: [
              _ShimmerBox(width: 16.w, height: 16.w, shape: BoxShape.circle),
              SizedBox(width: 6.w),
              _ShimmerBox(width: 140.w, height: 14.h),
              const Spacer(),
              _ShimmerBox(width: 80.w, height: 14.h),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSellerCardShimmer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        margin: EdgeInsets.only(top: 24.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.of(context).inputFill,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.of(context).subtleFill),
        ),
        child: Row(
          children: [
            // Avatar
            _ShimmerBox(width: 50.w, height: 50.w, shape: BoxShape.circle),
            SizedBox(width: 12.w),
            // Name + username
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: 100.w, height: 16.h),
                  SizedBox(height: 6.h),
                  _ShimmerBox(width: 70.w, height: 12.h),
                ],
              ),
            ),
            // View profile button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.of(context).border),
              ),
              child: _ShimmerBox(width: 60.w, height: 14.h),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          // Section header
          Row(
            children: [
              _ShimmerBox(width: 40.w, height: 40.w, shape: BoxShape.circle),
              SizedBox(width: 12.w),
              _ShimmerBox(width: 100.w, height: 18.h),
            ],
          ),
          SizedBox(height: 16.h),
          // Description lines
          _ShimmerBox(width: double.infinity, height: 14.h),
          SizedBox(height: 8.h),
          _ShimmerBox(width: double.infinity, height: 14.h),
          SizedBox(height: 8.h),
          _ShimmerBox(width: 0.7.sw, height: 14.h),
          SizedBox(height: 20.h),
          // Detail rows
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(width: 60.w, height: 12.h),
                    SizedBox(height: 4.h),
                    _ShimmerBox(width: 80.w, height: 14.h),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(width: 60.w, height: 12.h),
                    SizedBox(height: 4.h),
                    _ShimmerBox(width: 70.w, height: 14.h),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(width: 50.w, height: 12.h),
                    SizedBox(height: 4.h),
                    _ShimmerBox(width: 90.w, height: 14.h),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(width: 55.w, height: 12.h),
                    SizedBox(height: 4.h),
                    _ShimmerBox(width: 65.w, height: 14.h),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBarShimmer(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.of(context).card,
        border: Border(top: BorderSide(color: AppColors.of(context).border)),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.of(context).border,
        highlightColor: AppColors.of(context).shimmerHighlight,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColors.of(context).card,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              flex: 2,
              child: Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColors.of(context).card,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/features/chat/data/models/chat_message.dart';
import 'package:book_user_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class OfferBubble extends StatelessWidget {
  final OfferData offer;
  final bool isMe;
  final String time;
  final String? otherUserId;
  final String? otherUserName;
  final String? otherUserAvatar;

  const OfferBubble({
    super.key,
    required this.offer,
    required this.isMe,
    required this.time,
    this.otherUserId,
    this.otherUserName,
    this.otherUserAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.78.sw),
        decoration: BoxDecoration(
          color: AppColors.of(context).card,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: _borderColor(context),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.of(context).textPrimary.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: _headerColor(context),
                borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
              ),
              child: Row(
                children: [
                  Icon(_statusIcon, size: 16.sp, color: _statusColor(context)),
                  SizedBox(width: 6.w),
                  Text(
                    _statusLabel(l10n),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(context),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.of(context).textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content Body
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Listing Info
                  if (offer.listingTitle != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (offer.listingImage != null && offer.listingImage!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: CachedNetworkImage(
                              imageUrl: offer.listingImage!,
                              width: 40.w,
                              height: 40.w,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                width: 40.w,
                                height: 40.w,
                                color: AppColors.of(context).border,
                                child: Icon(Icons.image, size: 18.sp, color: AppColors.of(context).iconMuted),
                              ),
                            ),
                          ),
                        if (offer.listingImage != null && offer.listingImage!.isNotEmpty)
                          SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                offer.listingTitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.of(context).textPrimary,
                                ),
                              ),
                              if (offer.listingPrice != null)
                                Text(
                                  'Asking: \$${offer.listingPrice!.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.of(context).textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  if (offer.listingTitle != null)
                    SizedBox(height: 12.h),

                  // Offer Amount
                  Row(
                    children: [
                      Text(
                        isMe ? l10n.yourOffer : l10n.offeredPrice,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.of(context).textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${offer.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.of(context).accent,
                        ),
                      ),
                    ],
                  ),
                  
                  if (offer.isCountered && offer.counterAmount != null) ...[
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColors.of(context).warning.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.counterOffer,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.of(context).warning,
                            ),
                          ),
                          Text(
                            '\$${offer.counterAmount!.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.of(context).warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Action Buttons
            Builder(
              builder: (context) {
                // If offer is accepted, allow either side to review the counterparty.
                if (offer.isAccepted) {
                  return _buildLeaveReviewButton(context, l10n);
                }

                bool isMyTurn = false;
                if (offer.isPending || offer.isCountered) {
                  final isBuyerTurn = offer.roundNumber % 2 == 0;
                  final isSellerTurn = offer.roundNumber % 2 != 0;
                  
                  // isMe means this user sent the *original* offer message (the Buyer)
                  if (isMe && isBuyerTurn) {
                    isMyTurn = true;
                  } else if (!isMe && isSellerTurn) {
                    isMyTurn = true;
                  }
                }
                
                if (isMyTurn) {
                  return _buildActionButtons(context, l10n);
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveReviewButton(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
      child: Column(
        children: [
          Divider(color: AppColors.of(context).border, height: 1),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
            onPressed: () {
              if (!offer.isAccepted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Cannot leave review yet. Transaction is not completed.',
                    ),
                  ),
                );
                return;
              }

              final revieweeId =
                  (otherUserId != null && otherUserId!.isNotEmpty)
                  ? otherUserId
                  : null;

              if (revieweeId == null) {
                final missingRole = isMe ? 'seller' : 'buyer';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Cannot leave review right now. Missing $missingRole information.',
                    ),
                  ),
                );
                return;
              }

              final fallbackName = isMe ? 'Seller' : 'Buyer';
              context.pushNamed(
                'write_review',
                extra: {
                  // Route/API contract still expects sellerId key,
                  // but value is the resolved review target user id.
                  'sellerId': revieweeId,
                  'sellerName': otherUserName ?? fallbackName,
                  'sellerAvatar': otherUserAvatar,
                  'listingId': offer.listingId,
                  'listingTitle': offer.listingTitle,
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: AppColors.of(context).onPrimary,
              minimumSize: Size(double.infinity, 48.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.leaveAReview,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.of(context).onPrimary,
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.w),
      child: Column(
        children: [
          Divider(color: AppColors.of(context).border, height: 1),
          SizedBox(height: 10.h),
          // Accept button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<ChatBloc>().add(
                  RespondToOfferInChat(offerId: offer.offerId, action: 'accept'),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.of(context).success,
                foregroundColor: AppColors.of(context).onPrimary,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.acceptOffer,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          // Counter + Decline
          Row(
            children: [
              if (offer.canCounter)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showCounterDialog(context, l10n),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.of(context).accent,
                      side: BorderSide(color: AppColors.of(context).accent),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      l10n.counter,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.of(context).accent,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              if (offer.canCounter) SizedBox(width: 8.w),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    context.read<ChatBloc>().add(
                      RespondToOfferInChat(offerId: offer.offerId, action: 'decline'),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.of(context).textSecondary,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  child: Text(
                    l10n.decline,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCounterDialog(BuildContext context, AppLocalizations l10n) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        backgroundColor: AppColors.of(context).card,
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.counterOffer,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.of(context).textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: TextStyle(fontSize: 16.sp, color: AppColors.of(context).textPrimary),
                decoration: InputDecoration(
                  labelText: l10n.yourOffer,
                  prefixIcon: Icon(Icons.attach_money, color: AppColors.of(context).textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: AppColors.of(context).border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: AppColors.of(context).border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: AppColors.of(context).accent, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(controller.text);
                    if (amount != null && amount > 0) {
                      Navigator.pop(ctx);
                      context.read<ChatBloc>().add(
                        RespondToOfferInChat(
                          offerId: offer.offerId,
                          action: 'counter',
                          counterAmount: amount,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.of(context).accent,
                    foregroundColor: AppColors.of(context).onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.sendCounter,
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper methods ───────────────────────────────────

  Color _borderColor(BuildContext context) {
    if (offer.isAccepted) return AppColors.of(context).success.withOpacity(0.4);
    if (offer.isDeclined) return AppColors.of(context).error.withOpacity(0.3);
    if (offer.isCountered) return AppColors.of(context).warning.withOpacity(0.4);
    return AppColors.of(context).accent.withOpacity(0.3);
  }

  Color _headerColor(BuildContext context) {
    if (offer.isAccepted) return AppColors.of(context).success.withOpacity(0.08);
    if (offer.isDeclined) return AppColors.of(context).error.withOpacity(0.06);
    if (offer.isCountered) return AppColors.of(context).warning.withOpacity(0.08);
    return AppColors.of(context).accent.withOpacity(0.06);
  }

  Color _statusColor(BuildContext context) {
    if (offer.isAccepted) return AppColors.of(context).success;
    if (offer.isDeclined) return AppColors.of(context).error;
    if (offer.isCountered) return AppColors.of(context).warning;
    if (offer.isExpired) return AppColors.of(context).textSecondary;
    return AppColors.of(context).accent;
  }

  IconData get _statusIcon {
    if (offer.isAccepted) return Icons.check_circle_rounded;
    if (offer.isDeclined) return Icons.cancel_rounded;
    if (offer.isCountered) return Icons.swap_horiz_rounded;
    if (offer.isExpired) return Icons.timer_off_rounded;
    return Icons.local_offer_rounded;
  }

  String _statusLabel(AppLocalizations l10n) {
    if (offer.isAccepted) return l10n.accepted;
    if (offer.isDeclined) return l10n.declined;
    if (offer.isCountered) return l10n.countered;
    if (offer.isExpired) return l10n.expired;
    return l10n.pending;
  }
}

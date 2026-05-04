import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/constants/api_constants.dart';
import 'package:book_user_app/core/widgets/app_snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:book_user_app/core/widgets/app_loader.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../domain/entities/offer.dart';
import '../bloc/offer_bloc.dart';
import '../bloc/offer_event.dart';
import '../bloc/offer_state.dart';
import 'package:book_user_app/l10n/app_localizations.dart';

class OfferRequestPage extends StatefulWidget {
  final String offerId;

  const OfferRequestPage({super.key, required this.offerId});

  @override
  State<OfferRequestPage> createState() => _OfferRequestPageState();
}

class _OfferRequestPageState extends State<OfferRequestPage> {
  @override
  void initState() {
    super.initState();
    context.read<OfferBloc>().add(
      OfferDetailRequested(offerId: widget.offerId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const _OfferRequestBody();
  }
}

class _OfferRequestBody extends StatelessWidget {
  const _OfferRequestBody();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: AppBar(
        title: Text(
          l10n.offerRequest,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.of(context).textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.of(context).background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.of(context).textPrimary),
      ),
      body: BlocConsumer<OfferBloc, OfferState>(
        listener: (context, state) {
          if (state is OfferResponded) {
            final actionText = state.action == 'accept'
                ? l10n.offerAccepted
                : state.action == 'decline'
                ? l10n.offerDeclined
                : l10n.counterOfferSent;
            if (state.action == 'accept') {
              AppSnackBar.showSuccess(context, actionText);
            } else if (state.action == 'counter') {
              AppSnackBar.showInfo(context, actionText);
            } else {
              AppSnackBar.showWarning(context, actionText);
            }
            if (context.canPop()) {
              context.pop();
            }
          } else if (state is OfferError) {
            AppSnackBar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is OfferLoading) {
            return const AppLoaderFullPage();
          }
          if (state is OfferDetailLoaded) {
            return _buildOfferDetail(context, state.offer);
          }
          if (state is OfferError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.warning_2,
                    size: 48.sp,
                    color: AppColors.of(context).error.withOpacity(0.7),
                  ),
                  SizedBox(height: 12.h),
                  Text(state.message, style: TextStyle(fontSize: 14.sp)),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOfferDetail(BuildContext context, Offer offer) {
    final l10n = AppLocalizations.of(context)!;
    final listing = offer.listing;
    final buyer = offer.buyer;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Carousel
          if (listing != null && listing.images.isNotEmpty)
            SizedBox(
              height: 260.h,
              child: PageView.builder(
                itemCount: listing.images.length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: listing.images[index].url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.of(context).border,
                      child: Icon(
                        Icons.image,
                        size: 48.sp,
                        color: AppColors.of(context).iconMuted,
                      ),
                    ),
                  );
                },
              ),
            ),

          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Buyer Info
                if (buyer != null)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20.r,
                        backgroundImage: buyer.avatar != null
                            ? CachedNetworkImageProvider(buyer.avatar!)
                            : null,
                        backgroundColor: AppColors.of(context).subtleFill,
                        child: buyer.avatar == null
                            ? Text(
                                buyer.name.isNotEmpty
                                    ? buyer.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                  color: AppColors.of(context).primary,
                                ),
                              )
                            : null,
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            buyer.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15.sp,
                            ),
                          ),
                          Text(
                            l10n.roundOfThree(offer.roundNumber),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.of(context).textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _StatusBadge(status: offer.status),
                    ],
                  ),
                SizedBox(height: 16.h),

                // Listing Title
                Text(
                  listing?.title ?? l10n.listing,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.of(context).textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),

                // Description
                if (listing?.description != null)
                  Text(
                    listing!.description!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.of(context).textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                SizedBox(height: 16.h),

                // Details Table
                _buildDetailsTable(context, offer),
                SizedBox(height: 20.h),

                // Price Comparison Card
                _buildPriceComparison(context, offer),
                SizedBox(height: 24.h),

                // Action Buttons (only if offer is still actionable)
                if (offer.isPending || offer.isCountered)
                  _buildActionButtons(context, offer),

                // Leave a Review button (after offer accepted)
                if (offer.isAccepted)
                  _buildLeaveReviewButton(context, offer),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTable(BuildContext context, Offer offer) {
    final l10n = AppLocalizations.of(context)!;
    final listing = offer.listing;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: Column(
        children: [
          if (listing?.condition != null)
            _detailRow(
              context,
              l10n.condition,
              _capitalize(listing!.condition!),
            ),
          if (listing?.category != null) ...[
            Divider(height: 20.h, color: AppColors.of(context).border),
            _detailRow(context, l10n.category, _capitalize(listing!.category!)),
          ],
          if (listing?.location?.name != null) ...[
            Divider(height: 20.h, color: AppColors.of(context).border),
            _detailRow(context, l10n.location, listing!.location!.name!),
          ],
          Divider(height: 20.h, color: AppColors.of(context).border),
          _detailRow(
            context,
            l10n.expires,
            _formatExpiry(context, offer.expiresAt),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.of(context).textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.of(context).textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceComparison(BuildContext context, Offer offer) {
    final l10n = AppLocalizations.of(context)!;
    final listingPrice = offer.listing?.price ?? 0;
    final difference = offer.amount - listingPrice;
    final percentage = listingPrice > 0
        ? (offer.amount / listingPrice * 100)
        : 0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.of(context).accent.withOpacity(0.05),
            AppColors.of(context).accent.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.of(context).accent.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Original Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.askingPriceLabel,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.of(context).textSecondary,
                ),
              ),
              Text(
                '\$${listingPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.of(context).textSecondary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Offer Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.offeredPrice,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.of(context).textPrimary,
                ),
              ),
              Text(
                '\$${offer.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.of(context).accent,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Counter Amount (if countered)
          if (offer.counterAmount != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.counterOffer,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.of(context).warning,
                  ),
                ),
                Text(
                  '\$${offer.counterAmount!.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.of(context).warning,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
          ],

          // Difference
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.of(context).card,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.percentOfAskingPrice(percentage.toStringAsFixed(0)),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: percentage >= 90
                        ? AppColors.of(context).success
                        : percentage >= 70
                        ? AppColors.of(context).warning
                        : AppColors.of(context).error,
                  ),
                ),
                Text(
                  '${difference >= 0 ? '+' : ''}\$${difference.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: difference >= 0
                        ? AppColors.of(context).success
                        : AppColors.of(context).error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Offer offer) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Accept
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton.icon(
            onPressed: () {
              _showConfirmDialog(
                context,
                title: l10n.acceptOffer,
                message: l10n.acceptOfferConfirm(
                  offer.amount.toStringAsFixed(2),
                ),
                confirmText: l10n.accept,
                confirmColor: AppColors.of(context).success,
                onConfirm: () {
                  context.read<OfferBloc>().add(
                    OfferAccepted(offerId: offer.id),
                  );
                },
              );
            },
            icon: const Icon(Iconsax.tick_circle, size: 20),
            label: Text(
              l10n.acceptOffer,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.of(context).success,
              foregroundColor: AppColors.of(context).onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 0,
            ),
          ),
        ),
        SizedBox(height: 10.h),

        // Counter + Decline row
        Row(
          children: [
            // Counter
            if (offer.canCounter)
              Expanded(
                child: SizedBox(
                  height: 50.h,
                  child: ElevatedButton.icon(
                    onPressed: () => _showCounterDialog(context, offer),
                    icon: const Icon(Iconsax.refresh, size: 18),
                    label: Text(
                      l10n.counter,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.of(context).accent,
                      foregroundColor: AppColors.of(context).onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            if (offer.canCounter) SizedBox(width: 10.w),

            // Decline
            Expanded(
              child: SizedBox(
                height: 50.h,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showConfirmDialog(
                      context,
                      title: l10n.declineOffer,
                      message: l10n.confirmDeclineOffer,
                      confirmText: l10n.decline,
                      confirmColor: AppColors.of(context).error,
                      onConfirm: () {
                        context.read<OfferBloc>().add(
                          OfferDeclined(offerId: offer.id),
                        );
                      },
                    );
                  },
                  icon: Icon(
                    Iconsax.close_circle,
                    size: 18,
                    color: AppColors.of(context).textSecondary,
                  ),
                  label: Text(
                    l10n.decline,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.of(context).textSecondary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.of(context).border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeaveReviewButton(BuildContext context, Offer offer) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 8.h),
      child: SizedBox(
        height: 48.h,
        child: ElevatedButton(
          onPressed: () async {
            if (!offer.isAccepted) {
              AppSnackBar.showWarning(
                context,
                'Cannot leave review yet. Transaction is not completed.',
              );
              return;
            }

            final currentUserId = await _storage.read(key: StorageKeys.userId);
            if (!context.mounted) return;
            if (currentUserId == null || currentUserId.isEmpty) {
              AppSnackBar.showWarning(
                context,
                'Cannot leave review right now. Unable to identify your account. Please log in again.',
              );
              return;
            }

            // Resolve review target as counterparty:
            // seller reviews buyer, buyer reviews seller.
            String revieweeId = '';
            String? revieweeName;
            String? revieweeAvatar;

            if (currentUserId == offer.sellerId) {
              revieweeId = offer.buyerId;
              revieweeName = offer.buyer?.name;
              revieweeAvatar = offer.buyer?.avatar;
            } else if (currentUserId == offer.buyerId) {
              revieweeId = offer.sellerId;
              revieweeName = offer.seller?.name;
              revieweeAvatar = offer.seller?.avatar;
            } else {
              AppSnackBar.showWarning(
                context,
                'Cannot leave review right now. Unable to match your role for this transaction.',
              );
              return;
            }

            if (revieweeId.isEmpty) {
              final missingRole =
                  currentUserId == offer.buyerId
                  ? 'seller'
                  : 'buyer';
              AppSnackBar.showWarning(
                context,
                'Cannot leave review right now. Missing $missingRole information.',
              );
              return;
            }

            context.pushNamed(
              'write_review',
              extra: {
                // Route/API contract uses sellerId key; value is review target user id.
                'sellerId': revieweeId,
                'sellerName': revieweeName ?? 'User',
                'sellerAvatar': revieweeAvatar,
                'listingId': offer.listingId,
                'listingTitle': offer.listing?.title,
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
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: AppColors.of(context).onPrimary,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  void _showCounterDialog(BuildContext context, Offer offer) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(l10n.counterOfferTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.enterCounterPrice, style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 12.h),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                prefixText: '\$ ',
                hintText: '0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.pop(ctx);
                context.read<OfferBloc>().add(
                  OfferCountered(offerId: offer.id, counterAmount: amount),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.of(context).accent,
              foregroundColor: AppColors.of(context).onPrimary,
            ),
            child: Text(l10n.sendCounter),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : s;

  String _formatExpiry(BuildContext context, DateTime expiresAt) {
    final l10n = AppLocalizations.of(context)!;
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.isNegative) return l10n.expired;
    if (remaining.inHours >= 24)
      return l10n.daysHoursRemaining(remaining.inDays, remaining.inHours % 24);
    if (remaining.inHours > 0)
      return l10n.hoursMinutesRemaining(
        remaining.inHours,
        remaining.inMinutes % 60,
      );
    return l10n.minutesRemaining(remaining.inMinutes);
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'pending':
        bgColor = AppColors.of(context).warning.withOpacity(0.15);
        textColor = AppColors.of(context).warning;
        label = l10n.pending;
        break;
      case 'accepted':
        bgColor = AppColors.of(context).success.withOpacity(0.15);
        textColor = AppColors.of(context).success;
        label = l10n.accepted;
        break;
      case 'declined':
        bgColor = AppColors.of(context).error.withOpacity(0.15);
        textColor = AppColors.of(context).error;
        label = l10n.declined;
        break;
      case 'countered':
        bgColor = AppColors.of(context).accent.withOpacity(0.15);
        textColor = AppColors.of(context).accent;
        label = l10n.countered;
        break;
      case 'expired':
        bgColor = AppColors.of(context).border;
        textColor = AppColors.of(context).textSecondary;
        label = l10n.expired;
        break;
      default:
        bgColor = AppColors.of(context).border;
        textColor = AppColors.of(context).textSecondary;
        label = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

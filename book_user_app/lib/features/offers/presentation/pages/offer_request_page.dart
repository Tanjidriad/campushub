import 'package:book_user_app/core/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../domain/entities/offer.dart';
import '../bloc/offer_bloc.dart';
import '../bloc/offer_event.dart';
import '../bloc/offer_state.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Offer Request',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0E141B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0E141B)),
      ),
      body: BlocConsumer<OfferBloc, OfferState>(
        listener: (context, state) {
          if (state is OfferResponded) {
            final actionText = state.action == 'accept'
                ? 'Offer accepted! 🎉'
                : state.action == 'decline'
                ? 'Offer declined'
                : 'Counter offer sent!';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(actionText),
                backgroundColor: state.action == 'accept'
                    ? const Color(0xFF22C55E)
                    : state.action == 'counter'
                    ? const Color(0xFF4794E6)
                    : Colors.grey[700],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            );
            if (context.canPop()) {
              context.pop();
            }
          } else if (state is OfferError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
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
                  Icon(Iconsax.warning_2, size: 48.sp, color: Colors.red[300]),
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
                  return Image.network(
                    listing.images[index].url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.image, size: 48.sp, color: Colors.grey),
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
                            ? NetworkImage(buyer.avatar!)
                            : null,
                        backgroundColor: const Color(0xFFE8F0FE),
                        child: buyer.avatar == null
                            ? Text(
                                buyer.name.isNotEmpty
                                    ? buyer.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                  color: const Color(0xFF4794E6),
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
                            'Round ${offer.roundNumber} of 3',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
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
                  listing?.title ?? 'Listing',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0E141B),
                  ),
                ),
                SizedBox(height: 6.h),

                // Description
                if (listing?.description != null)
                  Text(
                    listing!.description!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                SizedBox(height: 16.h),

                // Details Table
                _buildDetailsTable(offer),
                SizedBox(height: 20.h),

                // Price Comparison Card
                _buildPriceComparison(offer),
                SizedBox(height: 24.h),

                // Action Buttons (only if offer is still actionable)
                if (offer.isPending || offer.isCountered)
                  _buildActionButtons(context, offer),

                // Leave a Review button (after offer accepted)
                if (offer.isAccepted && offer.seller != null)
                  _buildLeaveReviewButton(context, offer),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTable(Offer offer) {
    final listing = offer.listing;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          if (listing?.condition != null)
            _detailRow('Condition', _capitalize(listing!.condition!)),
          if (listing?.category != null) ...[
            Divider(height: 20.h, color: Colors.grey[200]),
            _detailRow('Category', _capitalize(listing!.category!)),
          ],
          if (listing?.location?.name != null) ...[
            Divider(height: 20.h, color: Colors.grey[200]),
            _detailRow('Location', listing!.location!.name!),
          ],
          Divider(height: 20.h, color: Colors.grey[200]),
          _detailRow('Expires', _formatExpiry(offer.expiresAt)),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0E141B),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceComparison(Offer offer) {
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
            const Color(0xFF4794E6).withOpacity(0.05),
            const Color(0xFF4794E6).withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFF4794E6).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Original Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Asking Price',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
              ),
              Text(
                '\$${listingPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[500],
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
                'Offered Price',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0E141B),
                ),
              ),
              Text(
                '\$${offer.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4794E6),
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
                  'Counter Offer',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                Text(
                  '\$${offer.counterAmount!.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF59E0B),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${percentage.toStringAsFixed(0)}% of asking price',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: percentage >= 90
                        ? const Color(0xFF22C55E)
                        : percentage >= 70
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFEF4444),
                  ),
                ),
                Text(
                  '${difference >= 0 ? '+' : ''}\$${difference.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: difference >= 0
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFEF4444),
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
                title: 'Accept Offer',
                message:
                    'Accept this offer of \$${offer.amount.toStringAsFixed(2)}?',
                confirmText: 'Accept',
                confirmColor: const Color(0xFF22C55E),
                onConfirm: () {
                  context.read<OfferBloc>().add(
                    OfferAccepted(offerId: offer.id),
                  );
                },
              );
            },
            icon: const Icon(Iconsax.tick_circle, size: 20),
            label: Text(
              'Accept Offer',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
              foregroundColor: Colors.white,
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
                      'Counter',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4794E6),
                      foregroundColor: Colors.white,
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
                      title: 'Decline Offer',
                      message: 'Decline this offer?',
                      confirmText: 'Decline',
                      confirmColor: const Color(0xFFEF4444),
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
                    color: Colors.grey[600],
                  ),
                  label: Text(
                    'Decline',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
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
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 8.h),
      child: OutlinedButton.icon(
        onPressed: () {
          context.pushNamed(
            'write_review',
            extra: {
              'sellerId': offer.sellerId,
              'sellerName': offer.seller?.name ?? 'Seller',
              'sellerAvatar': offer.seller?.avatar,
              'listingId': offer.listingId,
              'listingTitle': offer.listing?.title,
            },
          );
        },
        icon: Icon(Iconsax.star_1, size: 18.sp),
        label: Text(
          'Leave a Review',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFBBF24),
          side: const BorderSide(color: Color(0xFFFBBF24), width: 1.5),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  void _showCounterDialog(BuildContext context, Offer offer) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: const Text('Counter Offer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your counter price:',
              style: TextStyle(fontSize: 14.sp),
            ),
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
            child: const Text('Cancel'),
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
              backgroundColor: const Color(0xFF4794E6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Counter'),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : s;

  String _formatExpiry(DateTime expiresAt) {
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.isNegative) return 'Expired';
    if (remaining.inHours >= 24)
      return '${remaining.inHours ~/ 24}d ${remaining.inHours % 24}h remaining';
    if (remaining.inHours > 0)
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m remaining';
    return '${remaining.inMinutes}m remaining';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'pending':
        bgColor = const Color(0xFFFFF3CD);
        textColor = const Color(0xFFF59E0B);
        label = 'Pending';
        break;
      case 'accepted':
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF22C55E);
        label = 'Accepted';
        break;
      case 'declined':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFEF4444);
        label = 'Declined';
        break;
      case 'countered':
        bgColor = const Color(0xFFE0ECFF);
        textColor = const Color(0xFF4794E6);
        label = 'Countered';
        break;
      case 'expired':
        bgColor = Colors.grey[200]!;
        textColor = Colors.grey[600]!;
        label = 'Expired';
        break;
      default:
        bgColor = Colors.grey[200]!;
        textColor = Colors.grey[600]!;
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

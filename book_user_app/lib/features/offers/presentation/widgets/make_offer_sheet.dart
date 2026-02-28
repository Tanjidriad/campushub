import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../injection_container/injection_container.dart';
import '../bloc/offer_bloc.dart';
import '../bloc/offer_event.dart';
import '../bloc/offer_state.dart';

class MakeOfferSheet extends StatefulWidget {
  final String listingId;
  final String listingTitle;
  final double listingPrice;
  final String? listingImage;
  final void Function(double amount)? onOfferSent;

  const MakeOfferSheet({
    super.key,
    required this.listingId,
    required this.listingTitle,
    required this.listingPrice,
    this.listingImage,
    this.onOfferSent,
  });

  static Future<void> show(
    BuildContext context, {
    required String listingId,
    required String listingTitle,
    required double listingPrice,
    String? listingImage,
    void Function(double amount)? onOfferSent,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MakeOfferSheet(
        listingId: listingId,
        listingTitle: listingTitle,
        listingPrice: listingPrice,
        listingImage: listingImage,
        onOfferSent: onOfferSent,
      ),
    );
  }

  @override
  State<MakeOfferSheet> createState() => _MakeOfferSheetState();
}

class _MakeOfferSheetState extends State<MakeOfferSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  double? _offerAmount;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  double get _difference => (_offerAmount ?? 0) - widget.listingPrice;

  double get _percentage => widget.listingPrice > 0
      ? ((_offerAmount ?? 0) / widget.listingPrice * 100)
      : 0;

  Color get _differenceColor {
    if (_offerAmount == null) return Colors.grey;
    if (_percentage >= 90) return const Color(0xFF22C55E);
    if (_percentage >= 70) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OfferBloc>(),
      child: BlocConsumer<OfferBloc, OfferState>(
        listener: (context, state) {
          if (state is OfferCreated) {
            if (!mounted) return;
            Navigator.pop(context);
            widget.onOfferSent?.call(state.offer.amount);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('🎉 Offer sent successfully!'),
                backgroundColor: const Color(0xFF22C55E),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            );
          } else if (state is OfferError) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  Container(
                    margin: EdgeInsets.only(top: 12.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Text(
                          'Make an Offer',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0E141B),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Listing Info Row
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              // Image
                              Container(
                                width: 56.w,
                                height: 56.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  color: Colors.grey[200],
                                  image: widget.listingImage != null
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            widget.listingImage!,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: widget.listingImage == null
                                    ? Icon(Icons.image, color: Colors.grey[400])
                                    : null,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.listingTitle,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF0E141B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Asking: \$${widget.listingPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF4794E6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Price Input
                        Text(
                          'Your Offer',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0E141B),
                          ),
                          decoration: InputDecoration(
                            prefixText: '\$ ',
                            prefixStyle: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0E141B),
                            ),
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[300],
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              borderSide: const BorderSide(
                                color: Color(0xFF4794E6),
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 16.h,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _offerAmount = double.tryParse(value);
                            });
                          },
                        ),
                        SizedBox(height: 12.h),

                        // Price Comparison
                        if (_offerAmount != null && _offerAmount! > 0)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: _differenceColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: _differenceColor.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _difference >= 0
                                          ? Iconsax.arrow_up_3
                                          : Iconsax.arrow_down,
                                      color: _differenceColor,
                                      size: 18.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      '${_percentage.toStringAsFixed(0)}% of asking price',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: _differenceColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${_difference >= 0 ? '+' : ''}\$${_difference.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: _differenceColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: 20.h),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: ElevatedButton(
                            onPressed:
                                state is OfferLoading ||
                                    _offerAmount == null ||
                                    _offerAmount! <= 0
                                ? null
                                : () {
                                    context.read<OfferBloc>().add(
                                      CreateOfferRequested(
                                        listingId: widget.listingId,
                                        amount: _offerAmount!,
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4794E6),
                              disabledBackgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              elevation: 0,
                            ),
                            child: state is OfferLoading
                                ? SizedBox(
                                    width: 24.w,
                                    height: 24.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Send Offer',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

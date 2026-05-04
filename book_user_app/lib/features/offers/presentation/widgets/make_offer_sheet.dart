import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/app_snackbar.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  final void Function(String offerId, double amount)? onOfferSent;

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
    void Function(String offerId, double amount)? onOfferSent,
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
    if (_offerAmount == null) return AppColors.of(context).textSecondary;
    if (_percentage >= 90) return AppColors.of(context).success;
    if (_percentage >= 70) return AppColors.of(context).warning;
    return AppColors.of(context).error;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (_) => sl<OfferBloc>(),
      child: BlocConsumer<OfferBloc, OfferState>(
        listener: (context, state) {
          if (state is OfferCreated) {
            if (!mounted) return;
            Navigator.pop(context);
            widget.onOfferSent?.call(state.offer.id, state.offer.amount);
            AppSnackBar.showSuccess(context, l10n.offerSentSuccess);
          } else if (state is OfferError) {
            if (!mounted) return;
            AppSnackBar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.of(context).card,
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
                      color: AppColors.of(context).border,
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
                          l10n.makeAnOffer,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.of(context).textPrimary,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Listing Info Row
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppColors.of(context).inputFill,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.of(context).border,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Image
                              Container(
                                width: 56.w,
                                height: 56.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  color: AppColors.of(context).border,
                                  image: widget.listingImage != null
                                      ? DecorationImage(
                                          image: CachedNetworkImageProvider(
                                            widget.listingImage!,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: widget.listingImage == null
                                    ? Icon(
                                        Icons.image,
                                        color: AppColors.of(context).textLight,
                                      )
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
                                        color: AppColors.of(
                                          context,
                                        ).textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      l10n.askingPrice(
                                        widget.listingPrice.toStringAsFixed(2),
                                      ),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.of(context).accent,
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
                          l10n.yourOffer,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.of(context).textPrimary,
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
                            color: AppColors.of(context).textPrimary,
                          ),
                          decoration: InputDecoration(
                            prefixText: '\$ ',
                            prefixStyle: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.of(context).textPrimary,
                            ),
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.of(context).border,
                            ),
                            filled: true,
                            fillColor: AppColors.of(context).inputFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              borderSide: BorderSide(
                                color: AppColors.of(context).border,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              borderSide: BorderSide(
                                color: AppColors.of(context).border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              borderSide: BorderSide(
                                color: AppColors.of(context).accent,
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
                                      l10n.percentOfAskingPrice(
                                        _percentage.toStringAsFixed(0),
                                      ),
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
                              backgroundColor: AppColors.of(context).accent,
                              disabledBackgroundColor: AppColors.of(
                                context,
                              ).border,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              elevation: 0,
                            ),
                            child: state is OfferLoading
                                ? SizedBox(
                                    width: 24.w,
                                    height: 24.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.of(context).card,
                                    ),
                                  )
                                : Text(
                                    l10n.sendOffer,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.of(context).card,
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

import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/app_snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:book_user_app/features/chat/data/repositories/chat_repository.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_event.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_state.dart';
import 'package:book_user_app/features/listings/presentation/pages/promote_listing_page.dart';
import 'package:book_user_app/features/listings/presentation/pages/edit_listing_page.dart';
import 'package:book_user_app/features/listings/domain/repositories/listing_repository.dart';
import 'package:book_user_app/core/services/recently_viewed_service.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:book_user_app/core/widgets/shimmer_skeletons.dart';
import 'package:book_user_app/features/offers/presentation/widgets/make_offer_sheet.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:book_user_app/core/constants/api_constants.dart';
import 'package:book_user_app/core/network/api_client.dart';
import 'package:book_user_app/features/report/domain/entities/report.dart';
import 'package:book_user_app/features/report/presentation/widgets/report_dialog.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:book_user_app/core/constants/app_icons.dart';
import 'package:book_user_app/features/reviews/domain/entities/review.dart';
import 'package:book_user_app/features/reviews/presentation/bloc/reviews_bloc.dart';
import 'package:book_user_app/features/reviews/presentation/bloc/reviews_event.dart';
import 'package:book_user_app/features/reviews/presentation/bloc/reviews_state.dart';
import 'package:share_plus/share_plus.dart';
import 'package:book_user_app/features/listings/presentation/widgets/staggered_listing_card.dart';

// ─── Color Palette: use AppColors.of(context).success ───

class ListingDetailPage extends StatefulWidget {
  final String heroTag;
  final String imageUrl;
  final String? listingId;

  const ListingDetailPage({
    super.key,
    this.heroTag = 'hero_tag',
    this.imageUrl =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBi7YTqJfifuAs_fbND7DhnUo4YF75ZJ0TBnBz4FMSFnO-tokPAh3TKoVZAHMkjT2qx9A50FjbyV-38IY2FSxn7iGbesVNUUj6eSPDwFk05K8TgA77hTlI9czoO0W-1gl1ALaz4z7uv6rlPaP_pkky2T_Wy_SvAQLfVKSe_AZY8bo7yRFzvXIhJBWpNZ_IOBQZsGkl5rhAL6LqzOQQGCY4pTJgqYTeUWJ7NCtvevdKPCCkV6ULCaVCXWLOdGy65Bqqaz2eKf-g9tb0',
    this.listingId,
  });

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ListingsBloc _listingsBloc;

  int _currentImageIndex = 0;
  Listing? _listing;
  bool _isDescriptionExpanded = true;
  bool _isRatingExpanded = false;
  late ReviewsBloc _reviewsBloc;
  List<Review> _reviews = [];
  bool _reviewsLoaded = false;
  List<Listing> _similarListings = [];
  bool _similarLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    _listingsBloc = sl<ListingsBloc>();
    _reviewsBloc = sl<ReviewsBloc>();
    if (widget.listingId != null) {
      _listingsBloc.add(ListingDetailRequested(listingId: widget.listingId!));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _listingsBloc.close();
    _reviewsBloc.close();
    super.dispose();
  }

  List<String> get _images {
    if (_listing != null && _listing!.images.isNotEmpty) {
      return _listing!.images.map((img) => img.url).toList();
    }
    return [widget.imageUrl];
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  String _capitalizeFirst(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  // ─── Start Conversation (existing logic) ───
  Future<void> _startConversation(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (_listing == null) {
      AppSnackBar.showInfo(context, l10n.listingDataNotLoaded);
      return;
    }

    final seller = _listing!.seller;
    if (seller == null) {
      AppSnackBar.showInfo(context, l10n.sellerInfoNotAvailable);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repository = ChatRepository();
      final result = await repository.createConversation(
        listingId: _listing!.id,
        sellerId: seller.id,
      );

      if (!context.mounted) return;
      Navigator.pop(context);

      result.fold(
        (failure) {
          AppSnackBar.showError(
            context,
            'Failed to start conversation: ${failure.message}',
          );
        },
        (conversation) async {
          final firstImage = _listing!.images.isNotEmpty
              ? _listing!.images.first.url
              : '';

          final currentUserId = await sl<ApiClient>().secureStorage.read(
            key: StorageKeys.userId,
          );

          if (!context.mounted) return;

          context.push(
            '/chat/detail/${conversation.id}'
            '?name=${Uri.encodeComponent(seller.name)}'
            '&avatar=${Uri.encodeComponent(seller.avatar ?? '')}'
            '&userId=${seller.id}'
            '&listingId=${_listing!.id}'
            '&listingTitle=${Uri.encodeComponent(_listing!.title)}'
            '&listingImage=${Uri.encodeComponent(firstImage)}'
            '&listingPrice=${_listing!.price}'
            '&sellerId=${seller.id}'
            '&currentUserId=${currentUserId ?? ''}',
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      AppSnackBar.showError(context, 'Error: $e');
    }
  }

  // ─── Fetch Similar Listings ───
  Future<void> _fetchSimilarListings(String listingId) async {
    if (_similarLoading) return;
    setState(() => _similarLoading = true);
    final result = await sl<ListingRepository>().getSimilarListings(listingId);
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _similarLoading = false),
      (listings) => setState(() {
        _similarListings = listings;
        _similarLoading = false;
      }),
    );
  }

  // ─── Build ───
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider.value(
      value: _listingsBloc,
      child: HeroMode(
        enabled: false,
        child: BlocConsumer<ListingsBloc, ListingsState>(
          listener: (context, state) {
            if (!mounted) return;
            if (state is ListingDetailLoaded) {
              setState(() => _listing = state.listing);
              sl<RecentlyViewedService>().recordListing(state.listing);
              _fetchSimilarListings(state.listing.id);
            } else if (state is WishlistToggled &&
                _listing != null &&
                state.listingId == _listing!.id) {
              setState(() {
                _listing = _listing!.copyWith(isInWishlist: state.isInWishlist);
              });
            } else if (state is ListingsError && _listing != null) {
              AppSnackBar.showError(context, state.message);
            } else if (state is ListingDeleted) {
              AppSnackBar.showSuccess(context, l10n.listingDeletedSuccess);
              Navigator.pop(context);
            } else if (state is ListingMarkedAsSold) {
              AppSnackBar.showSuccess(context, l10n.listingMarkedAsSoldMsg);
              _listingsBloc.add(
                ListingDetailRequested(listingId: state.listingId),
              );
            }
          },
          buildWhen: (previous, current) {
            if (current is WishlistToggled) return false;
            if (current is ListingsError && _listing != null) return false;
            return true;
          },
          builder: (context, state) {
            if (state is ListingDetailLoading) {
              return const ListingDetailShimmer();
            }

            if (state is ListingsError && _listing == null) {
              return Scaffold(
                backgroundColor: AppColors.of(context).background,
                appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48.sp,
                        color: AppColors.of(context).iconMuted,
                      ),
                      SizedBox(height: 16.h),
                      Text(state.message),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          if (widget.listingId != null) {
                            _listingsBloc.add(
                              ListingDetailRequested(
                                listingId: widget.listingId!,
                              ),
                            );
                          }
                        },
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              );
            }

            return _buildContent();
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  MAIN CONTENT — matches HTML mockup
  // ═══════════════════════════════════════════════════════

  Widget _buildContent() {
    final listing = _listing;
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: Column(
        children: [
          // ─── Sticky Header ───
          _buildStickyHeader(),

          // ─── Scrollable Body ───
          Expanded(
            child: SingleChildScrollView(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Image Carousel
                      _buildHeroImageCarousel(),

                      // Dot Indicators
                      _buildDotIndicators(),

                      // Main Info
                      _buildMainInfoSection(listing),

                      // Seller Card
                      if (listing != null && listing.seller != null)
                        _buildSellerCard(listing),

                      // Description
                      _buildDescriptionSection(listing),

                      // Tags
                      if (listing != null && listing.tags.isNotEmpty)
                        _buildTagsSection(listing.tags),

                      // Divider
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Divider(
                          color: AppColors.of(context).border,
                          height: 1,
                        ),
                      ),

                      // Action Menu
                      _buildActionMenu(),

                      // Similar Listings
                      _buildSimilarListings(),

                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // ─── Sticky Bottom Bar ───
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ─── Sticky Header ───
  Widget _buildStickyHeader() {
    final l10n = AppLocalizations.of(context)!;
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
              // Back Button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  color: AppColors.of(context).textPrimary,
                ),
                splashRadius: 20.r,
              ),

              // Title
              Expanded(
                child: Text(
                  l10n.adDetails,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.of(context).textPrimary,
                  ),
                ),
              ),

              // Share
              IconButton(
                onPressed: () {
                  if (_listing == null) return;
                  final text =
                      '${_listing!.title}\n'
                      '${_listing!.formattedPrice}\n'
                      '${l10n.shareCheckItOut}';
                  Share.share(text);
                },
                icon: Icon(
                  Iconsax.share,
                  color: AppColors.of(context).textSecondary,
                  size: 22.sp,
                ),
                splashRadius: 20.r,
              ),

              // Wishlist / Owner Menu
              if (_listing != null)
                Builder(
                  builder: (context) {
                    final authState = context.read<AuthBloc>().state;
                    final currentUserId = authState is AuthAuthenticated
                        ? authState.user.id
                        : null;
                    final isOwner =
                        currentUserId != null &&
                        (_listing?.sellerId == currentUserId ||
                            _listing?.seller?.id == currentUserId);

                    if (isOwner) return _buildOwnerMenuButton();

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            context.read<ListingsBloc>().add(
                              ListingWishlistToggled(listingId: _listing!.id),
                            );
                          },
                          icon: Icon(
                            _listing?.isInWishlist == true
                                ? Iconsax.heart5
                                : Iconsax.heart,
                            color: _listing?.isInWishlist == true
                                ? AppColors.of(context).error
                                : AppColors.of(context).textSecondary,
                            size: 22.sp,
                          ),
                          splashRadius: 20.r,
                        ),
                      ],
                    );
                  },
                )
              else
                SizedBox(width: 48.w),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Hero Image Carousel ───
  Widget _buildHeroImageCarousel() {
    return Container(
      margin: EdgeInsets.only(top: 8.h, left: 16.w, right: 16.w),
      height: 190.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: AppColors.of(context).border,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Image PageView
          PageView.builder(
            itemCount: _images.length,
            onPageChanged: (index) =>
                setState(() => _currentImageIndex = index),
            itemBuilder: (context, index) {
              final imageWidget = CachedNetworkImage(
                imageUrl: _images[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.of(context).border,
                  child: Icon(
                    Iconsax.image,
                    size: 48.sp,
                    color: AppColors.of(context).textLight,
                  ),
                ),
              );
              return imageWidget;
            },
          ),

          // Bottom-right overlay badges
          Positioned(
            bottom: 12.h,
            right: 12.w,
            child: Row(
              children: [
                // Views badge
                _buildOverlayBadge('Views: ${_listing?.views ?? 0}'),
                SizedBox(width: 8.w),
                // Pagination badge
                _buildOverlayBadge(
                  '${_currentImageIndex + 1} / ${_images.length}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.of(context).subtleFill, width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.of(context).textPrimary,
        ),
      ),
    );
  }

  // ─── Dot Indicators ───
  Widget _buildDotIndicators() {
    if (_images.length <= 1) return SizedBox(height: 12.h);

    return Padding(
      padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_images.length, (index) {
          final isActive = _currentImageIndex == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            width: isActive ? 24.w : 6.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.of(context).success
                  : AppColors.of(context).border,
              borderRadius: BorderRadius.circular(3.r),
            ),
          );
        }),
      ),
    );
  }

  // ─── Main Info Section ───
  Widget _buildMainInfoSection(Listing? listing) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),

          // Price Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                listing?.priceType == 'free'
                    ? 'FREE'
                    : '\$ ${listing?.price?.toStringAsFixed(2) ?? '0.00'}',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.of(context).success,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '(${_capitalizeFirst(listing?.priceType ?? 'fixed')})',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.of(context).textSecondary,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Title
          Text(
            listing?.title ?? l10n.loading,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              height: 1.3,
              color: AppColors.of(context).textPrimary,
            ),
          ),

          SizedBox(height: 12.h),

          // Location + Date Row
          Row(
            children: [
              // Location
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Iconsax.location,
                      size: 14.sp,
                      color: AppColors.of(context).textLight,
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        listing?.location?.name ??
                            listing?.location?.address ??
                            l10n.locationNotSet,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.of(context).textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    if (listing?.location != null)
                      GestureDetector(
                        onTap: () {
                          // Could open map view
                        },
                        child: Text(
                          l10n.seeMap,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.of(context).success,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.of(context).success,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Date
              Text(
                listing != null ? _formatDate(listing.createdAt) : '',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.of(context).textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Seller Profile Card (matches screenshot) ───
  Widget _buildSellerCard(Listing listing) {
    final l10n = AppLocalizations.of(context)!;
    SellerInfo seller = listing.seller!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        margin: EdgeInsets.only(top: 24.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.of(context).subtleFill,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.of(context).border),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 25.r,
              backgroundImage: seller.avatar != null
                  ? CachedNetworkImageProvider(seller.avatar!)
                  : null,
              backgroundColor: AppColors.of(context).border,
              child: seller.avatar == null
                  ? Text(
                      seller.name.isNotEmpty ? seller.name[0] : '?',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.of(context).textSecondary,
                      ),
                    )
                  : null,
            ),

            SizedBox(width: 12.w),

            // Name + Username
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seller.name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.of(context).textPrimary,
                    ),
                  ),
                  if (seller.username != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      seller.username!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.of(context).textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // View Profile Button (outlined, matching screenshot)
            GestureDetector(
              onTap: () {
                context.pushNamed(
                  'seller_profile',
                  pathParameters: {'id': seller.id},
                  extra: listing, // Pass the listing to extract seller details
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.of(context).card,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.of(context).border),
                ),
                child: Text(
                  l10n.viewProfile,
                  style: TextStyle(
                    color: AppColors.of(context).textPrimary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Description Section (collapsible with details grid — matches screenshot) ───
  Widget _buildDescriptionSection(Listing? listing) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),

          // Collapsible Header
          GestureDetector(
            onTap: () => setState(
              () => _isDescriptionExpanded = !_isDescriptionExpanded,
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.of(context).error,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppIcons.descriptionIcon,
                      width: 20.sp,
                      height: 20.sp,
                      colorFilter: ColorFilter.mode(
                        AppColors.of(context).onPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    l10n.description,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.of(context).textPrimary,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isDescriptionExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.of(context).textSecondary,
                    size: 24.sp,
                  ),
                ),
              ],
            ),
          ),

          // Expandable Content
          AnimatedCrossFade(
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),

                // Details Grid
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.of(context).border),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        'Category',
                        _capitalizeFirst(listing?.category ?? 'N/A'),
                        'Price',
                        listing?.priceType == 'free'
                            ? 'Free'
                            : '\$ ${listing?.price?.toStringAsFixed(2) ?? '0.00'} (${_capitalizeFirst(listing?.priceType ?? 'Fixed')})',
                      ),
                      Divider(
                        color: AppColors.of(context).border,
                        height: 24.h,
                      ),
                      _buildDetailRow(
                        'Date',
                        listing != null
                            ? _formatDate(listing.createdAt)
                            : 'N/A',
                        'Condition',
                        _capitalizeFirst(listing?.condition ?? 'N/A'),
                      ),
                      Divider(
                        color: AppColors.of(context).border,
                        height: 24.h,
                      ),
                      _buildDetailRow(
                        'Type',
                        _capitalizeFirst(listing?.priceType ?? 'N/A'),
                        'Warranty',
                        l10n.no,
                      ),
                      if (listing?.educationLevel != null) ...[
                        Divider(
                          color: AppColors.of(context).border,
                          height: 24.h,
                        ),
                        _buildDetailRow(
                          'Level',
                          _capitalizeFirst(listing!.educationLevel!),
                          'Subject/Dept',
                          (listing.subject != null && listing.subject!.isNotEmpty)
                              ? _capitalizeFirst(listing.subject!)
                              : 'N/A',
                        ),
                        Divider(
                          color: AppColors.of(context).border,
                          height: 24.h,
                        ),
                        _buildDetailRow(
                          'Class/Sem',
                          (listing.classOrSemester != null && listing.classOrSemester!.isNotEmpty)
                              ? _capitalizeFirst(listing.classOrSemester!)
                              : 'N/A',
                          'Book Type',
                          (listing.bookType != null && listing.bookType!.isNotEmpty)
                              ? _capitalizeFirst(listing.bookType!)
                              : 'N/A',
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Description text
                Text(
                  listing?.description ?? l10n.noDescriptionAvailable,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.6,
                    color: AppColors.of(context).textPrimary,
                  ),
                ),

                SizedBox(height: 20.h),

                // Safety Tips (inside description)
                Text(
                  l10n.safetyTipsForDeal,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.of(context).textPrimary,
                  ),
                ),
                SizedBox(height: 10.h),
                _buildSafetyTipItem(1, l10n.safetyTipMeetSeller),
                _buildSafetyTipItem(2, l10n.safetyTipAvoidCash),
                _buildSafetyTipItem(3, l10n.safetyTipUnrealisticOffers),
              ],
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _isDescriptionExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label1,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.of(context).textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value1,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.of(context).textSecondary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label2,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.of(context).textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value2,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.of(context).textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyTipItem(int number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.of(context).textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.of(context).textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tags Section ───
  Widget _buildTagsSection(List<String> tags) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Padding(
        padding: EdgeInsets.only(top: 20.h, bottom: 16.h),
        child: Row(
          children: [
            Icon(
              Iconsax.tag,
              size: 16.sp,
              color: AppColors.of(context).textPrimary,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                tags.map((t) => '#$t').join(' '),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.of(context).textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Action Menu (Report, Rating, Write Review) ───
  Widget _buildActionMenu() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 4.h),

          // Report
          _buildActionMenuItem(
            svgAsset: AppIcons.reportIcon,
            iconBgColor: AppColors.of(context).error,
            label: l10n.report,
            onTap: () {
              if (_listing != null) {
                ReportDialog.show(
                  context,
                  targetType: ReportTargetType.listing,
                  targetId: _listing!.id,
                  targetName: _listing!.title,
                );
              }
            },
          ),

          // Rating & Review (expandable)
          _buildRatingSection(),

          // Write a Review
          _buildActionMenuItem(
            svgAsset: AppIcons.writeReviewIcon,
            iconBgColor: AppColors.of(context).accent,
            label: l10n.writeAReview,
            showBorder: false,
            onTap: () {
              if (_listing?.seller != null) {
                context.pushNamed(
                  'write_review',
                  extra: {
                    'sellerId': _listing!.seller!.id,
                    'sellerName': _listing!.seller!.name,
                    'sellerAvatar': _listing!.seller?.avatar,
                    'listingId': _listing!.id,
                    'listingTitle': _listing!.title,
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // ─── Similar Listings Section ───
  Widget _buildSimilarListings() {
    final l10n = AppLocalizations.of(context)!;

    if (_similarLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(color: AppColors.of(context).border, height: 1),
            SizedBox(height: 16.h),
            Text(
              l10n.similarListings,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.of(context).textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }

    if (_similarListings.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: AppColors.of(context).border, height: 1),
          SizedBox(height: 16.h),
          Text(
            l10n.similarListings,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.of(context).textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          ...List.generate((_similarListings.length / 2).ceil(), (rowIndex) {
            final first = rowIndex * 2;
            final second = first + 1;
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: StaggeredListingCard(
                      listing: _similarListings[first],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: second < _similarListings.length
                        ? StaggeredListingCard(
                            listing: _similarListings[second],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Expandable Rating & Review Section ───
  Widget _buildRatingSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Header (tap to expand)
        InkWell(
          onTap: () {
            setState(() => _isRatingExpanded = !_isRatingExpanded);
            if (_isRatingExpanded &&
                !_reviewsLoaded &&
                _listing?.seller != null) {
              _reviewsBloc.add(
                ReviewsLoadRequested(sellerId: _listing!.seller!.id),
              );
            }
          },
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.of(context).subtleFill),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.of(context).success,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppIcons.ratingIcon,
                      width: 20.sp,
                      height: 20.sp,
                      colorFilter: ColorFilter.mode(
                        AppColors.of(context).onPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Text(
                    l10n.ratingAndReview,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.of(context).textPrimary,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isRatingExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.of(context).textLight,
                    size: 24.sp,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Expandable reviews list
        AnimatedCrossFade(
          firstChild: BlocProvider.value(
            value: _reviewsBloc,
            child: BlocConsumer<ReviewsBloc, ReviewsState>(
              listener: (context, state) {
                if (state is ReviewsLoaded) {
                  setState(() {
                    _reviews = state.reviews;
                    _reviewsLoaded = true;
                  });
                }
              },
              builder: (context, state) {
                if (state is ReviewsLoading) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.of(context).success,
                      ),
                    ),
                  );
                }

                if (state is ReviewsError) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Text(
                      l10n.couldNotLoadReviews,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.of(context).textSecondary,
                      ),
                    ),
                  );
                }

                if (_reviews.isEmpty && _reviewsLoaded) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Text(
                      l10n.noReviewsYet,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.of(context).textSecondary,
                      ),
                    ),
                  );
                }

                return Column(
                  children: _reviews
                      .map((review) => _buildReviewCard(review))
                      .toList(),
                );
              },
            ),
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState: _isRatingExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.of(context).subtleFill),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Reviewer avatar
              CircleAvatar(
                radius: 20.r,
                backgroundImage: review.reviewerAvatar != null
                    ? CachedNetworkImageProvider(review.reviewerAvatar!)
                    : null,
                backgroundColor: AppColors.of(context).border,
                child: review.reviewerAvatar == null
                    ? Text(
                        review.reviewerName.isNotEmpty
                            ? review.reviewerName[0]
                            : '?',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.of(context).textSecondary,
                        ),
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
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.of(context).textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Text(
                          _formatDate(review.createdAt),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.of(context).textSecondary,
                          ),
                        ),
                        Text(
                          ' | ',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.of(context).textLight,
                          ),
                        ),
                        Icon(
                          Icons.star_rounded,
                          size: 14.sp,
                          color: AppColors.of(context).warning,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '${review.rating.toInt()} Reviews',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.of(context).textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.of(context).subtleFill,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                review.comment,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.of(context).textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionMenuItem({
    required String svgAsset,
    required Color iconBgColor,
    required String label,
    required VoidCallback onTap,
    bool showBorder = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          border: showBorder
              ? Border(
                  bottom: BorderSide(color: AppColors.of(context).subtleFill),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  svgAsset,
                  width: 20.sp,
                  height: 20.sp,
                  colorFilter: ColorFilter.mode(
                    AppColors.of(context).onPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.of(context).textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.of(context).textLight,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  BOTTOM BAR
  // ═══════════════════════════════════════════════════════

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.of(context).card,
        boxShadow: [
          BoxShadow(
            color: AppColors.of(context).textPrimary.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Builder(
            builder: (context) {
              final authState = context.read<AuthBloc>().state;
              String? currentUserId;
              if (authState is AuthAuthenticated) {
                currentUserId = authState.user.id;
              }
              final isOwner =
                  currentUserId != null &&
                  (_listing?.sellerId == currentUserId ||
                      _listing?.seller?.id == currentUserId);

              if (isOwner && _listing != null) {
                return _buildOwnerBottomBar();
              }

              return _buildBuyerBottomBar();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOwnerBottomBar() {
    final l10n = AppLocalizations.of(context)!;
    if (_listing!.isFeatured) {
      return Container(
        height: 50.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.of(context).warning.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.of(context).warning.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.star1,
              size: 18.sp,
              color: AppColors.of(context).warning,
            ),
            SizedBox(width: 8.w),
            Text(
              l10n.featured,
              style: TextStyle(
                color: AppColors.of(context).warning,
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 50.h,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final promoted = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => sl<ListingsBloc>(),
                child: PromoteListingPage(listing: _listing!),
              ),
            ),
          );
          if (promoted == true && mounted) {
            AppSnackBar.showSuccess(
              context,
              AppLocalizations.of(context)!.listingPromotedSuccess,
            );
            setState(() {
              _listing = _listing!.copyWith(isFeatured: true);
            });
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.of(context).warning,
          foregroundColor: AppColors.of(context).onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 2,
          shadowColor: AppColors.of(context).warning.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.flash_1,
              color: AppColors.of(context).onPrimary,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              l10n.promoteListing,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyerBottomBar() {
    final l10n = AppLocalizations.of(context)!;
    final seller = _listing?.seller;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // WhatsApp Share button (secondary action)
        SizedBox(
          width: double.infinity,
          height: 44.h,
          child: OutlinedButton.icon(
            onPressed: () {
              if (_listing == null) return;
              final price = _listing!.price != null
                  ? '৳${_listing!.price!.toStringAsFixed(0)}'
                  : 'Free';
              final text =
                  '*${_listing!.title}*\n'
                  'Price: $price\n'
                  'Condition: ${_listing!.condition}\n'
                  '${l10n.foundOnCampusHub}';
              Share.share(text, subject: _listing!.title);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF25D366), width: 1.5),
              foregroundColor: const Color(0xFF25D366),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 10.h),
            ),
            icon: SvgPicture.string(
              '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#25D366"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/></svg>',
              width: 18.sp,
              height: 18.sp,
            ),
            label: Text(
              l10n.shareOnWhatsApp,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF25D366),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        // Buy Now + Send Message row
        Row(
          children: [
            // Seller avatar (small green circle)
            if (seller != null)
              Container(
                margin: EdgeInsets.only(right: 10.w),
                child: CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppColors.of(
                    context,
                  ).success.withOpacity(0.1),
                  backgroundImage: seller.avatar != null
                      ? CachedNetworkImageProvider(seller.avatar!)
                      : null,
                  child: seller.avatar == null
                      ? Text(
                          seller.name.isNotEmpty ? seller.name[0] : '?',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.of(context).success,
                          ),
                        )
                      : null,
                ),
              ),

            // Buy Now
            Expanded(
              child: SizedBox(
                height: 48.h,
                child: OutlinedButton(
                  onPressed: () {
                    if (_listing != null) {
                      MakeOfferSheet.show(
                        context,
                        listingId: _listing!.id,
                        listingTitle: _listing!.title,
                        listingPrice: _listing!.price ?? 0,
                        listingImage: _listing!.images.isNotEmpty
                            ? _listing!.images.first.url
                            : null,
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.of(context).success,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.shopping_cart,
                        size: 16.sp,
                        color: AppColors.of(context).success,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        l10n.buyNow,
                        style: TextStyle(
                          color: AppColors.of(context).success,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(width: 10.w),

            // Send Message
            Expanded(
              child: SizedBox(
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () => _startConversation(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.of(context).success,
                    foregroundColor: AppColors.of(context).onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.message,
                        color: AppColors.of(context).onPrimary,
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          l10n.sendMessage,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  //  OWNER ACTIONS (preserved from original)
  // ═══════════════════════════════════════════════════════

  void _handleOwnerAction(String action) {
    final l10n = AppLocalizations.of(context)!;
    if (_listing == null) return;

    switch (action) {
      case 'edit':
        Navigator.push<bool>(
          context,
          PageRouteBuilder<bool>(
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            pageBuilder: (_, __, ___) => EditListingPage(listing: _listing!),
            transitionsBuilder: (_, __, ___, child) => child,
          ),
        ).then((edited) {
          if (edited == true && mounted) {
            _listingsBloc.add(ListingDetailRequested(listingId: _listing!.id));
          }
        });
        break;
      case 'sold':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.markAsSold),
            content: Text(l10n.confirmMarkAsSold),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _listingsBloc.add(
                    ListingMarkAsSoldRequested(listingId: _listing!.id),
                  );
                },
                child: Text(l10n.confirm),
              ),
            ],
          ),
        );
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.deleteListing),
            content: Text(l10n.confirmDeleteListing),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.of(context).error,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _listingsBloc.add(
                    ListingDeleteRequested(listingId: _listing!.id),
                  );
                },
                child: Text(
                  l10n.delete,
                  style: TextStyle(color: AppColors.of(context).onPrimary),
                ),
              ),
            ],
          ),
        );
        break;
    }
  }

  Widget _buildOwnerMenuButton() {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: AppColors.of(context).textSecondary,
        size: 22.sp,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      onSelected: _handleOwnerAction,
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Iconsax.edit, size: 20.sp),
              SizedBox(width: 8.w),
              Text(l10n.editListing),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'sold',
          child: Row(
            children: [
              Icon(Iconsax.tick_circle, size: 20.sp),
              SizedBox(width: 8.w),
              Text(l10n.markAsSold),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Iconsax.trash,
                size: 20.sp,
                color: AppColors.of(context).error,
              ),
              SizedBox(width: 8.w),
              Text(
                l10n.deleteListing,
                style: TextStyle(color: AppColors.of(context).error),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

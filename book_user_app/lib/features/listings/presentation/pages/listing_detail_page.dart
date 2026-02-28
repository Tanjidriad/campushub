import 'package:book_user_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:book_user_app/features/chat/data/repositories/chat_repository.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_event.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_state.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:book_user_app/core/widgets/shimmer_skeletons.dart';
import 'package:book_user_app/features/offers/presentation/widgets/make_offer_sheet.dart';
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

// ─── Color Palette (from HTML mockup) ───
const _kPrimaryGreen = Color(0xFF16A34A);
const _kPriceGreen = Color(0xFF15803D);

const _kDarkText = Color(0xFF1F2937);

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
    if (_listing == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing data not loaded yet')),
      );
      return;
    }

    final seller = _listing!.seller;
    if (seller == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seller information not available')),
      );
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to start conversation: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ─── Build ───
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _listingsBloc,
      child: BlocConsumer<ListingsBloc, ListingsState>(
        listener: (context, state) {
          if (state is ListingDetailLoaded) {
            setState(() => _listing = state.listing);
          } else if (state is WishlistToggled &&
              _listing != null &&
              state.listingId == _listing!.id) {
            setState(() {
              _listing = _listing!.copyWith(isInWishlist: state.isInWishlist);
            });
          } else if (state is ListingsError && _listing != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ListingDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Listing deleted successfully')),
            );
            context.pop();
          } else if (state is ListingMarkedAsSold) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Listing marked as sold')),
            );
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
              backgroundColor: Colors.white,
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
                    Icon(Icons.error_outline, size: 48.sp, color: Colors.grey),
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
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return _buildContent();
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  MAIN CONTENT — matches HTML mockup
  // ═══════════════════════════════════════════════════════

  Widget _buildContent() {
    final listing = _listing;
    return Scaffold(
      backgroundColor: Colors.white,
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
                        child: Divider(color: Colors.grey[200], height: 1),
                      ),

                      // Action Menu
                      _buildActionMenu(),

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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
                splashRadius: 20.r,
              ),

              // Title
              Expanded(
                child: Text(
                  'Ad Details',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: _kDarkText,
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
                      'Check it out on CampusHub Pro!';
                  Share.share(text);
                },
                icon: Icon(Iconsax.share, color: Colors.grey[500], size: 22.sp),
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
                                ? Colors.red
                                : Colors.grey[500],
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
        color: Colors.grey[200],
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
              final imageWidget = Image.network(
                _images[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Iconsax.image,
                    size: 48.sp,
                    color: Colors.grey[400],
                  ),
                ),
              );
              if (index == 0) {
                return Hero(tag: widget.heroTag, child: imageWidget);
              }
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
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[100]!, width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: _kDarkText,
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
              color: isActive ? _kPrimaryGreen : Colors.grey[300],
              borderRadius: BorderRadius.circular(3.r),
            ),
          );
        }),
      ),
    );
  }

  // ─── Main Info Section ───
  Widget _buildMainInfoSection(Listing? listing) {
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
                  color: _kPriceGreen,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '(${_capitalizeFirst(listing?.priceType ?? 'fixed')})',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Title
          Text(
            listing?.title ?? 'Loading...',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              height: 1.3,
              color: _kDarkText,
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
                      color: Colors.grey[400],
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        listing?.location?.name ??
                            listing?.location?.address ??
                            'Location not set',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[500],
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
                          'see map',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: _kPrimaryGreen,
                            decoration: TextDecoration.underline,
                            decorationColor: _kPrimaryGreen,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Date
              Text(
                listing != null ? _formatDate(listing.createdAt) : '',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Seller Profile Card (matches screenshot) ───
  Widget _buildSellerCard(Listing listing) {
    SellerInfo seller = listing.seller!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        margin: EdgeInsets.only(top: 24.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 25.r,
              backgroundImage: seller.avatar != null
                  ? NetworkImage(seller.avatar!)
                  : null,
              backgroundColor: Colors.grey[300],
              child: seller.avatar == null
                  ? Text(
                      seller.name.isNotEmpty ? seller.name[0] : '?',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
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
                      color: _kDarkText,
                    ),
                  ),
                  if (seller.username != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      seller.username!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  'View profile',
                  style: TextStyle(
                    color: _kDarkText,
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppIcons.descriptionIcon,
                      width: 20.sp,
                      height: 20.sp,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: _kDarkText,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isDescriptionExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey[500],
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
                    color: const Color(0xFFF8EBDC),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey[200]!),
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
                      Divider(color: Colors.grey[200], height: 24.h),
                      _buildDetailRow(
                        'Date',
                        listing != null
                            ? _formatDate(listing.createdAt)
                            : 'N/A',
                        'Condition',
                        _capitalizeFirst(listing?.condition ?? 'N/A'),
                      ),
                      Divider(color: Colors.grey[200], height: 24.h),
                      _buildDetailRow(
                        'Type',
                        _capitalizeFirst(listing?.priceType ?? 'N/A'),
                        'Warranty',
                        'No',
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Description text
                Text(
                  listing?.description ?? 'No description available.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.6,
                    color: Colors.grey[700],
                  ),
                ),

                SizedBox(height: 20.h),

                // Safety Tips (inside description)
                Text(
                  'Safety tips for deal',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: _kDarkText,
                  ),
                ),
                SizedBox(height: 10.h),
                _buildSafetyTipItem(1, 'Use a safe location to meet seller'),
                _buildSafetyTipItem(2, 'Avoid cash transactions'),
                _buildSafetyTipItem(3, 'Beware of unrealistic offers'),
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
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value1,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[500],
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
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value2,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[500],
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
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
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
            Icon(Iconsax.tag, size: 16.sp, color: _kDarkText),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                tags.map((t) => '#$t').join(' '),
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Action Menu (Report, Rating, Write Review) ───
  Widget _buildActionMenu() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 4.h),

          // Report
          _buildActionMenuItem(
            svgAsset: AppIcons.reportIcon,
            iconBgColor: const Color(0xFFDC3545),
            label: 'Report',
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
            iconBgColor: const Color(0xFF0D6EFD),
            label: 'Write a Review',
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

  // ─── Expandable Rating & Review Section ───
  Widget _buildRatingSection() {
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
              border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF198754),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppIcons.ratingIcon,
                      width: 20.sp,
                      height: 20.sp,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Text(
                    'Rating & Review',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: _kDarkText,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isRatingExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey[400],
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
                    child: const Center(
                      child: CircularProgressIndicator(color: _kPrimaryGreen),
                    ),
                  );
                }

                if (state is ReviewsError) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Text(
                      'Could not load reviews',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  );
                }

                if (_reviews.isEmpty && _reviewsLoaded) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Text(
                      'No reviews yet',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[500],
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
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
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
                    ? NetworkImage(review.reviewerAvatar!)
                    : null,
                backgroundColor: Colors.grey[300],
                child: review.reviewerAvatar == null
                    ? Text(
                        review.reviewerName.isNotEmpty
                            ? review.reviewerName[0]
                            : '?',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
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
                        color: _kDarkText,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Text(
                          _formatDate(review.createdAt),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          ' | ',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[400],
                          ),
                        ),
                        Icon(
                          Icons.star_rounded,
                          size: 14.sp,
                          color: const Color(0xFFF59E0B),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '${review.rating.toInt()} Reviews',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[500],
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
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                review.comment,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[700],
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
              ? Border(bottom: BorderSide(color: Colors.grey[100]!))
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
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
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
                  color: _kDarkText,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20.sp),
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
    if (_listing!.isFeatured) {
      return Container(
        height: 50.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.star1, size: 18.sp, color: const Color(0xFFF59E0B)),
            SizedBox(width: 8.w),
            Text(
              'Featured',
              style: TextStyle(
                color: const Color(0xFFB45309),
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
        onPressed: () {
          context.push('/listing/${_listing!.id}/promote', extra: _listing!);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF59E0B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 2,
          shadowColor: const Color(0xFFF59E0B).withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.flash_1, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Promote Listing',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyerBottomBar() {
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
                  'Condition: ${_listing!.condition ?? 'N/A'}\n'
                  'Found on CampusHub Pro 📚';
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
              'Share on WhatsApp',
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
                  backgroundColor: _kPrimaryGreen.withOpacity(0.1),
                  backgroundImage: seller.avatar != null
                      ? NetworkImage(seller.avatar!)
                      : null,
                  child: seller.avatar == null
                      ? Text(
                          seller.name.isNotEmpty ? seller.name[0] : '?',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: _kPrimaryGreen,
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
                    side: const BorderSide(color: _kPrimaryGreen, width: 1.5),
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
                        color: _kPrimaryGreen,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Buy Now',
                        style: TextStyle(
                          color: _kPrimaryGreen,
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
                    backgroundColor: _kPrimaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.message, color: Colors.white, size: 16.sp),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          'Send Message',
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
    if (_listing == null) return;

    switch (action) {
      case 'edit':
        context.push('/listing/${_listing!.id}/edit', extra: _listing);
        break;
      case 'sold':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Mark as Sold'),
            content: const Text(
              'Are you sure you want to mark this listing as sold?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _listingsBloc.add(
                    ListingMarkAsSoldRequested(listingId: _listing!.id),
                  );
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        );
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Listing'),
            content: const Text(
              'Are you sure you want to delete this listing? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  _listingsBloc.add(
                    ListingDeleteRequested(listingId: _listing!.id),
                  );
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
        break;
    }
  }

  Widget _buildOwnerMenuButton() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 22.sp),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      onSelected: _handleOwnerAction,
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Iconsax.edit, size: 20.sp),
              SizedBox(width: 8.w),
              const Text('Edit Listing'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'sold',
          child: Row(
            children: [
              Icon(Iconsax.tick_circle, size: 20.sp),
              SizedBox(width: 8.w),
              const Text('Mark as Sold'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Iconsax.trash, size: 20.sp, color: Colors.red),
              SizedBox(width: 8.w),
              const Text('Delete Listing', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:book_user_app/features/auth/domain/entities/user.dart';
import 'package:book_user_app/features/listings/domain/repositories/listing_repository.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/listings/domain/usecases/get_listings_usecase.dart';
import 'package:book_user_app/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:book_user_app/features/profile/presentation/pages/seller_profile_page.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:flutter/material.dart';

/// Resolves `/seller/:id` from path (and optional [Listing] in `extra`) for deep links and restore.
class SellerProfileRoutePage extends StatefulWidget {
  final String sellerId;
  final Listing? extraListing;

  const SellerProfileRoutePage({
    super.key,
    required this.sellerId,
    this.extraListing,
  });

  @override
  State<SellerProfileRoutePage> createState() => _SellerProfileRoutePageState();
}

class _SellerProfileRoutePageState extends State<SellerProfileRoutePage> {
  Listing? _listing;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.extraListing != null) {
      _listing = widget.extraListing;
      _loading = false;
    } else if (widget.sellerId.isEmpty) {
      _loading = false;
      _error = 'Seller data not available.';
    } else {
      _resolve();
    }
  }

  Future<void> _resolve() async {
    final listingsResult = await sl<GetListingsUseCase>()(
      ListingsParams(sellerId: widget.sellerId, limit: 20),
    );

    await listingsResult.fold(
      (failure) async {
        if (!mounted) return;
        setState(() {
          _error = failure.message;
          _loading = false;
        });
      },
      (page) async {
        if (page.listings.isNotEmpty) {
          if (!mounted) return;
          setState(() {
            _listing = page.listings.first;
            _loading = false;
          });
          return;
        }

        final userResult = await sl<GetUserProfileUseCase>()(widget.sellerId);
        if (!mounted) return;
        userResult.fold(
          (f) {
            setState(() {
              _error = f.message;
              _loading = false;
            });
          },
          (User user) {
            setState(() {
              _listing = _listingFromUser(user);
              _loading = false;
            });
          },
        );
      },
    );
  }

  Listing _listingFromUser(User user) {
    final now = DateTime.now();
    return Listing(
      id: '',
      title: '',
      description: user.bio ?? '',
      images: const [],
      category: '',
      priceType: 'fixed',
      createdAt: now,
      updatedAt: now,
      seller: SellerInfo(
        id: user.id,
        name: user.name,
        avatar: user.avatar,
        username: user.username,
        isVerified: user.isVerified,
        rating: user.averageRating,
        createdAt: user.createdAt,
      ),
      location: user.location != null
          ? ListingLocation(name: user.location)
          : null,
      educationLevel: user.educationLevel,
      classOrSemester: user.classOrSemester,
      subject: (user.stream != null && user.stream!.trim().isNotEmpty)
          ? user.stream
          : (user.department != null && user.department!.trim().isNotEmpty)
              ? user.department
              : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(_error!)),
      );
    }
    final listing = _listing;
    if (listing == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Seller data not available.')),
      );
    }
    return SellerProfilePage(listing: listing);
  }
}

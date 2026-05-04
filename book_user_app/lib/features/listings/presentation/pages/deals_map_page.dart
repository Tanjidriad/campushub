import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/listings/presentation/widgets/deals_map_view.dart';
import 'package:flutter/material.dart';

/// Full-screen map explore experience (chrome lives inside [DealsMapView]).
class DealsMapPage extends StatelessWidget {
  final List<Listing> listings;
  final double initialLat;
  final double initialLng;

  const DealsMapPage({
    super.key,
    required this.listings,
    required this.initialLat,
    required this.initialLng,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: DealsMapView(
        listings: listings,
        initialLat: initialLat,
        initialLng: initialLng,
      ),
    );
  }
}

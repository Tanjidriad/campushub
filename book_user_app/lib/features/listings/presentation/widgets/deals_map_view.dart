import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/press_scale.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/listings/presentation/pages/listing_detail_page.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';

/// Price bubble marker — optional [selected] draws a light ring for the active pin.
Future<BitmapDescriptor> _buildMarkerIcon(
  String text, {
  bool selected = false,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  const double w = 160, h = 100, tail = 25;

  final Paint bgPaint = Paint()
    ..color = const Color(0xFF2E7D32)
    ..style = PaintingStyle.fill;

  final Path bubble = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, w, h),
        const Radius.circular(50),
      ),
    )
    ..moveTo(w / 2 - 15, h)
    ..lineTo(w / 2, h + tail)
    ..lineTo(w / 2 + 15, h)
    ..close();

  if (selected) {
    final ring = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawPath(bubble, ring);
  }

  canvas.drawShadow(bubble, Colors.black.withValues(alpha: 0.35), 4, false);
  canvas.drawPath(bubble, bgPaint);

  final tp = TextPainter(
    textDirection: TextDirection.ltr,
    text: TextSpan(
      text: text,
      style: const TextStyle(
        fontSize: 42,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  )..layout();
  tp.paint(canvas, Offset((w - tp.width) / 2, (h - tp.height) / 2));

  final img = await recorder.endRecording().toImage(
    w.toInt(),
    (h + tail).toInt(),
  );
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.bytes(data!.buffer.asUint8List());
}

class DealsMapView extends StatefulWidget {
  final List<Listing> listings;
  final double initialLat;
  final double initialLng;

  const DealsMapView({
    super.key,
    required this.listings,
    required this.initialLat,
    required this.initialLng,
  });

  @override
  State<DealsMapView> createState() => _DealsMapViewState();
}

class _DealsMapViewState extends State<DealsMapView> {
  final Completer<GoogleMapController> _mapController = Completer();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final TextEditingController _searchController = TextEditingController();
  late final PageController _pageController;

  String? _selectedListingId;
  final Map<String, BitmapDescriptor> _iconCache = {};

  List<Listing> get _withCoords => widget.listings
      .where(
        (l) =>
            l.location?.latitude != null && l.location?.longitude != null,
      )
      .toList();

  List<Listing> get _visibleListings {
    final q = _searchController.text.trim().toLowerCase();
    final base = _withCoords;
    if (q.isEmpty) return base;
    return base.where((l) {
      final title = l.title.toLowerCase();
      final loc = (l.location?.name ?? '').toLowerCase();
      final sellerRaw = l.seller?.username ?? l.seller?.name ?? '';
      final seller = sellerRaw.toLowerCase();
      return title.contains(q) || loc.contains(q) || seller.contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
    final v = _visibleListings;
    if (v.isNotEmpty) {
      _selectedListingId = v.first.id;
    }
    _precacheIcons();
  }

  @override
  void didUpdateWidget(DealsMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.listings != oldWidget.listings) {
      _iconCache.clear();
      _precacheIcons();
      _syncSelectionAfterFilter();
    }
  }

  void _syncSelectionAfterFilter() {
    final v = _visibleListings;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (v.isEmpty) {
        setState(() => _selectedListingId = null);
        return;
      }
      if (_selectedListingId == null ||
          !v.any((l) => l.id == _selectedListingId)) {
        setState(() => _selectedListingId = v.first.id);
        if (_pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      } else {
        final idx = v.indexWhere((l) => l.id == _selectedListingId);
        if (idx >= 0 && _pageController.hasClients) {
          _pageController.jumpToPage(idx);
        }
      }
    });
  }

  Future<void> _precacheIcons() async {
    for (final listing in widget.listings) {
      for (final sel in [false, true]) {
        final key = '${listing.id}_$sel';
        if (_iconCache.containsKey(key)) continue;
        final label = listing.priceType == 'free'
            ? 'FREE'
            : '\$${listing.price?.toStringAsFixed(0) ?? '0'}';
        _iconCache[key] = await _buildMarkerIcon(label, selected: sel);
      }
    }
    if (mounted) setState(() {});
  }

  Set<Marker> get _markers {
    final set = <Marker>{};
    final visible = _visibleListings;
    for (final listing in visible) {
      final lat = listing.location!.latitude!;
      final lng = listing.location!.longitude!;
      final selected = listing.id == _selectedListingId;
      final icon = _iconCache['${listing.id}_$selected'] ??
          _iconCache['${listing.id}_false'];
      if (icon == null) continue;

      set.add(
        Marker(
          markerId: MarkerId(listing.id),
          position: LatLng(lat, lng),
          zIndexInt: selected ? 3 : 1,
          icon: icon,
          onTap: () => _onMarkerTap(listing),
        ),
      );
    }
    return set;
  }

  void _onMarkerTap(Listing listing) {
    HapticFeedback.selectionClick();
    final visible = _visibleListings;
    final i = visible.indexWhere((l) => l.id == listing.id);
    if (i < 0) return;
    setState(() => _selectedListingId = listing.id);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        i,
        duration: const Duration(milliseconds: 340),
        curve: Curves.easeOutCubic,
      );
    }
    _animateTo(listing.location!.latitude!, listing.location!.longitude!);
  }

  Future<void> _animateTo(double lat, double lng) async {
    final controller = await _mapController.future;
    await controller.animateCamera(
      CameraUpdate.newLatLng(LatLng(lat, lng)),
    );
  }

  Future<void> _fitAllMarkers() async {
    final visible = _visibleListings;
    if (visible.isEmpty) return;
    final controller = await _mapController.future;

    if (visible.length == 1) {
      final l = visible.first;
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(l.location!.latitude!, l.location!.longitude!),
          15,
        ),
      );
      return;
    }

    var minLat = visible.first.location!.latitude!;
    var maxLat = minLat;
    var minLng = visible.first.location!.longitude!;
    var maxLng = minLng;
    for (final l in visible) {
      final lat = l.location!.latitude!;
      final lng = l.location!.longitude!;
      minLat = math.min(minLat, lat);
      maxLat = math.max(maxLat, lat);
      minLng = math.min(minLng, lng);
      maxLng = math.max(maxLng, lng);
    }
    final pad = 0.01;
    final bounds = LatLngBounds(
      southwest: LatLng(minLat - pad, minLng - pad),
      northeast: LatLng(maxLat + pad, maxLng + pad),
    );
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 64),
    );
  }

  Future<void> _recenterOnUser() async {
    HapticFeedback.lightImpact();
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        await _animateTo(widget.initialLat, widget.initialLng);
        return;
      }
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      await _animateTo(p.latitude, p.longitude);
    } catch (_) {
      await _animateTo(widget.initialLat, widget.initialLng);
    }
  }

  void _onSearchChanged() {
    setState(() {});
    _syncSelectionAfterFilter();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final visible = _visibleListings;

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.initialLat, widget.initialLng),
            zoom: 14.5,
          ),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: true,
          padding: EdgeInsets.only(top: 120.h, bottom: 200.h),
          onMapCreated: (c) {
            if (!_mapController.isCompleted) {
              _mapController.complete(c);
            }
            Future<void>.delayed(const Duration(milliseconds: 200), () async {
              if (!mounted) return;
              if (visible.length > 1) {
                await _fitAllMarkers();
              }
            });
          },
        ),

        // Top: gradient scrim + header + search
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.background.withValues(alpha: 0.97),
                  colors.background.withValues(alpha: 0.88),
                  colors.background.withValues(alpha: 0),
                ],
                stops: const [0, 0.45, 1],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Material(
                          color: colors.surface,
                          shape: const CircleBorder(),
                          elevation: 0,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => Navigator.of(context).maybePop(),
                            child: Padding(
                              padding: EdgeInsets.all(10.w),
                              child: Icon(
                                Iconsax.arrow_left,
                                size: 20.sp,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.dealsNearYou,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: colors.textPrimary,
                                ),
                              ),
                              Text(
                                l10n.mapDealsCountNearby(visible.length),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => _onSearchChanged(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: colors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.mapSearchDealsHint,
                        hintStyle: TextStyle(
                          color: colors.textLight,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: colors.surface,
                        prefixIcon: Icon(
                          Iconsax.search_normal,
                          color: colors.textLight,
                          size: 20.sp,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Iconsax.close_circle,
                                  color: colors.textSecondary,
                                  size: 20.sp,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged();
                                  setState(() {});
                                },
                              )
                            : null,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(
                            color: colors.border.withValues(alpha: 0.6),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(
                            color: colors.primary.withValues(alpha: 0.65),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Map controls
        Positioned(
          right: 14.w,
          top: 128.h + MediaQuery.paddingOf(context).top,
          child: Column(
            children: [
              _MapControlButton(
                icon: Iconsax.gps,
                tooltip: l10n.mapRecenter,
                onTap: _recenterOnUser,
              ),
              SizedBox(height: 10.h),
              _MapControlButton(
                icon: Iconsax.maximize_4,
                tooltip: l10n.mapFitAll,
                onTap: () async {
                  HapticFeedback.lightImpact();
                  await _fitAllMarkers();
                },
              ),
            ],
          ),
        ),

        DraggableScrollableSheet(
          controller: _sheetController,
          initialChildSize: 0.38,
          minChildSize: 0.14,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                boxShadow: [
                  BoxShadow(
                    color: colors.textPrimary.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 10.h, bottom: 8.h),
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: colors.border,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            visible.isEmpty
                                ? l10n.mapNoMatchingDeals
                                : l10n.mapSwipeForMore,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                        if (visible.length > 1)
                          TextButton.icon(
                            onPressed: () async {
                              HapticFeedback.selectionClick();
                              await _fitAllMarkers();
                            },
                            icon: Icon(Iconsax.map, size: 16.sp),
                            label: Text(
                              l10n.mapFitAll,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 6.h),
                  if (visible.isEmpty)
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.search_status,
                                size: 48.sp,
                                color: colors.border,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                l10n.mapNoMatchingDeals,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 232.h,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: visible.length,
                        padEnds: false,
                        onPageChanged: (i) {
                          final l = visible[i];
                          setState(() => _selectedListingId = l.id);
                          _animateTo(
                            l.location!.latitude!,
                            l.location!.longitude!,
                          );
                        },
                        itemBuilder: (context, i) {
                          final listing = visible[i];
                          final selected = listing.id == _selectedListingId;
                          return Padding(
                            padding: EdgeInsets.only(
                              left: i == 0 ? 16.w : 6.w,
                              right: 6.w,
                            ),
                            child: _MapCarouselCard(
                              listing: listing,
                              isSelected: selected,
                            ),
                          );
                        },
                      ),
                    ),
                  if (visible.isNotEmpty) SizedBox(height: 12.h),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Material(
      color: colors.surface,
      elevation: 2,
      shadowColor: colors.textPrimary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Icon(icon, size: 22.sp, color: colors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _MapCarouselCard extends StatelessWidget {
  const _MapCarouselCard({
    required this.listing,
    required this.isSelected,
  });

  final Listing listing;
  final bool isSelected;

  String _meetupShort(Listing l) {
    return l.location?.name ??
        l.location?.address ??
        l.district ??
        (l.meetupPreferences == 'campus'
            ? 'Campus'
            : l.meetupPreferences == 'public'
                ? 'Public meetup'
                : 'Flexible');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final imageUrl = listing.primaryImageUrl ?? '';
    final sellerName =
        listing.seller?.username ?? listing.seller?.name ?? l10n.notSpecified;
    final sellerRating = listing.seller?.rating;

    return PressScale(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListingDetailPage(
              heroTag: 'map_${listing.id}',
              imageUrl: imageUrl,
              listingId: listing.id,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.subtleFill,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isSelected ? colors.success : colors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: Stack(
                children: [
                  ColoredBox(
                    color: colors.card,
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            height: 118.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => SizedBox(
                              height: 118.h,
                              child: Center(
                                child: Icon(
                                  Iconsax.image,
                                  color: colors.border,
                                  size: 28.sp,
                                ),
                              ),
                            ),
                            errorWidget: (_, _, _) => SizedBox(
                              height: 118.h,
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: colors.border,
                                size: 28.sp,
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 118.h,
                            child: Icon(
                              Icons.image_outlined,
                              color: colors.border,
                              size: 28.sp,
                            ),
                          ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 48.h,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.45),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10.h,
                    right: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.warning.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        _meetupShort(listing).toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10.w,
                    bottom: 8.h,
                    right: 10.w,
                    child: Text(
                      listing.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        listing.priceType == 'free'
                            ? l10n.free
                            : '\$${listing.price?.toStringAsFixed(0) ?? '0'}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: colors.success,
                          letterSpacing: -0.4,
                        ),
                      ),
                      if (listing.condition.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            listing.condition,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      Icon(Iconsax.star1,
                          size: 14.sp, color: colors.warning),
                      SizedBox(width: 2.w),
                      Text(
                        sellerRating != null
                            ? sellerRating.toStringAsFixed(1)
                            : '—',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14.r,
                        backgroundColor: colors.border,
                        backgroundImage: listing.seller?.avatar != null
                            ? CachedNetworkImageProvider(
                                listing.seller!.avatar!,
                              )
                            : null,
                        child: listing.seller?.avatar == null
                            ? Icon(
                                Icons.person,
                                size: 14.sp,
                                color: colors.textSecondary,
                              )
                            : null,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          sellerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        l10n.viewDetails,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

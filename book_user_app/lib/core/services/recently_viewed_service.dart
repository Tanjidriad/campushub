import 'dart:convert';

import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight snapshot for horizontal "recently viewed" on home.
class RecentlyViewedSnapshot {
  final String id;
  final String title;
  final String? imageUrl;
  final String priceType;
  final double? price;
  final String currency;

  const RecentlyViewedSnapshot({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.priceType,
    this.price,
    this.currency = 'USD',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'imageUrl': imageUrl,
        'priceType': priceType,
        'price': price,
        'currency': currency,
      };

  factory RecentlyViewedSnapshot.fromJson(Map<String, dynamic> json) {
    return RecentlyViewedSnapshot(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String?,
      priceType: json['priceType'] as String? ?? 'fixed',
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'USD',
    );
  }

  /// Minimal [Listing] for card widgets that only need display fields.
  Listing toListingStub() {
    return Listing(
      id: id,
      title: title,
      description: '',
      images: imageUrl != null && imageUrl!.isNotEmpty
          ? [ListingImage(url: imageUrl!, publicId: '')]
          : const [],
      category: 'other',
      priceType: priceType,
      price: price,
      currency: currency,
      condition: 'good',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

class RecentlyViewedService {
  static const _key = 'recently_viewed_listings';
  static const _maxItems = 10;

  /// Bumped when a listing is recorded so home can refresh the carousel.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  Future<List<RecentlyViewedSnapshot>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final out = <RecentlyViewedSnapshot>[];
    for (final s in raw) {
      try {
        out.add(
          RecentlyViewedSnapshot.fromJson(
            jsonDecode(s) as Map<String, dynamic>,
          ),
        );
      } catch (_) {}
    }
    return out;
  }

  Future<void> recordListing(Listing listing) async {
    final snap = RecentlyViewedSnapshot(
      id: listing.id,
      title: listing.title,
      imageUrl: listing.primaryImageUrl,
      priceType: listing.priceType,
      price: listing.price,
      currency: listing.currency,
    );
    final prefs = await SharedPreferences.getInstance();
    final existing = List<String>.from(prefs.getStringList(_key) ?? []);
    final encoded = jsonEncode(snap.toJson());
    existing.removeWhere((e) {
      try {
        final m = jsonDecode(e) as Map<String, dynamic>;
        return m['id'] == listing.id;
      } catch (_) {
        return false;
      }
    });
    existing.insert(0, encoded);
    while (existing.length > _maxItems) {
      existing.removeLast();
    }
    await prefs.setStringList(_key, existing);
    revision.value++;
  }
}

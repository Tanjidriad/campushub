import 'dart:async';

/// Lightweight global notifier that broadcasts when a listing's status changes
/// (e.g. marked as sold after an offer is accepted).
///
/// This allows the ChatBloc to signal the ProfilePage / ListingsBloc
/// to refresh without tight coupling between features.
class ListingStatusNotifier {
  ListingStatusNotifier._();
  static final ListingStatusNotifier instance = ListingStatusNotifier._();

  final _controller = StreamController<String>.broadcast();

  /// Stream of listing IDs whose status has changed.
  Stream<String> get onStatusChanged => _controller.stream;

  /// Call this when a listing's status changes (e.g. sold via offer acceptance).
  void notifyListingSold(String listingId) {
    _controller.add(listingId);
  }
}

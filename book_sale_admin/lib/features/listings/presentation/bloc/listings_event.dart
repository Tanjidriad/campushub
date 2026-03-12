import 'package:equatable/equatable.dart';

abstract class ListingsEvent extends Equatable {
  const ListingsEvent();

  @override
  List<Object?> get props => [];
}

class FetchPendingListingsEvent extends ListingsEvent {
  final int limit;
  const FetchPendingListingsEvent({this.limit = 50});

  @override
  List<Object?> get props => [limit];
}

class FetchAllListingsEvent extends ListingsEvent {
  final int limit;
  final String? search;
  final String? category;
  final bool? isFeatured;

  const FetchAllListingsEvent({
    this.limit = 50,
    this.search,
    this.category,
    this.isFeatured,
  });

  @override
  List<Object?> get props => [limit, search, category, isFeatured];
}

// Action Events
class ApproveListingEvent extends ListingsEvent {
  final String id;
  const ApproveListingEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class RejectListingEvent extends ListingsEvent {
  final String id;
  final String reason;
  const RejectListingEvent(this.id, this.reason);
  @override
  List<Object?> get props => [id, reason];
}

class DeleteListingEvent extends ListingsEvent {
  final String id;
  const DeleteListingEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class ToggleFeatureListingEvent extends ListingsEvent {
  final String id;
  const ToggleFeatureListingEvent(this.id);
  @override
  List<Object?> get props => [id];
}

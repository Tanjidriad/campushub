import 'package:equatable/equatable.dart';
import '../../domain/entities/listing.dart';

abstract class ListingsState extends Equatable {
  const ListingsState();

  @override
  List<Object> get props => [];
}

class ListingsInitial extends ListingsState {}

class ListingsLoading extends ListingsState {}

class ListingsLoaded extends ListingsState {
  final List<Listing> pendingListings;
  final List<Listing> activeListings;

  const ListingsLoaded({
    required this.pendingListings,
    required this.activeListings,
  });

  ListingsLoaded copyWith({
    List<Listing>? pendingListings,
    List<Listing>? activeListings,
  }) {
    return ListingsLoaded(
      pendingListings: pendingListings ?? this.pendingListings,
      activeListings: activeListings ?? this.activeListings,
    );
  }

  @override
  List<Object> get props => [pendingListings, activeListings];
}

class ListingsError extends ListingsState {
  final String message;

  const ListingsError({required this.message});

  @override
  List<Object> get props => [message];
}

// Optional state to indicate success of an action
class ListingActionSuccess extends ListingsState {
  final String message;
  const ListingActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

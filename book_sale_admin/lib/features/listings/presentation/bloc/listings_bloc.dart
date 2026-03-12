import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/listing.dart';
import '../../domain/usecases/get_pending_listings.dart';
import '../../domain/usecases/get_all_listings.dart';
import '../../domain/usecases/listing_actions_usecases.dart';
import 'listings_event.dart';
import 'listings_state.dart';

class ListingsBloc extends Bloc<ListingsEvent, ListingsState> {
  final GetPendingListings getPendingListings;
  final GetAllListings getAllListings;
  final ApproveListing approveListing;
  final RejectListing rejectListing;
  final DeleteListing deleteListing;
  final ToggleFeatureListing toggleFeatureListing;

  ListingsBloc({
    required this.getPendingListings,
    required this.getAllListings,
    required this.approveListing,
    required this.rejectListing,
    required this.deleteListing,
    required this.toggleFeatureListing,
  }) : super(ListingsInitial()) {
    on<FetchPendingListingsEvent>(_onFetchPending);
    on<FetchAllListingsEvent>(_onFetchAll);
    on<ApproveListingEvent>(_onApprove);
    on<RejectListingEvent>(_onReject);
    on<DeleteListingEvent>(_onDelete);
    on<ToggleFeatureListingEvent>(_onToggleFeature);
  }

  Future<void> _onFetchPending(
    FetchPendingListingsEvent event,
    Emitter<ListingsState> emit,
  ) async {
    List<Listing> prevActive = [];
    if (state is ListingsLoaded) {
      prevActive = (state as ListingsLoaded).activeListings;
    }
    emit(ListingsLoading());
    final failureOrListings = await getPendingListings(
      GetPendingParams(limit: event.limit),
    );
    failureOrListings.fold(
      (failure) => emit(
        const ListingsError(message: 'Failed to fetch pending listings'),
      ),
      (listings) => emit(
        ListingsLoaded(pendingListings: listings, activeListings: prevActive),
      ),
    );
  }

  Future<void> _onFetchAll(
    FetchAllListingsEvent event,
    Emitter<ListingsState> emit,
  ) async {
    List<Listing> prevPending = [];
    if (state is ListingsLoaded) {
      prevPending = (state as ListingsLoaded).pendingListings;
    }
    emit(ListingsLoading());
    final failureOrListings = await getAllListings(
      GetAllParams(
        limit: event.limit,
        search: event.search,
        category: event.category,
        isFeatured: event.isFeatured,
      ),
    );
    failureOrListings.fold(
      (failure) =>
          emit(const ListingsError(message: 'Failed to fetch listings')),
      (listings) => emit(
        ListingsLoaded(pendingListings: prevPending, activeListings: listings),
      ),
    );
  }

  Future<void> _onApprove(
    ApproveListingEvent event,
    Emitter<ListingsState> emit,
  ) async {
    final result = await approveListing(event.id);
    result.fold(
      (failure) =>
          emit(const ListingsError(message: 'Failed to approve listing')),
      (_) => emit(const ListingActionSuccess('Successfully approved listing')),
    );
  }

  Future<void> _onReject(
    RejectListingEvent event,
    Emitter<ListingsState> emit,
  ) async {
    final result = await rejectListing(
      RejectParams(id: event.id, reason: event.reason),
    );
    result.fold(
      (failure) =>
          emit(const ListingsError(message: 'Failed to reject listing')),
      (_) => emit(const ListingActionSuccess('Successfully rejected listing')),
    );
  }

  Future<void> _onDelete(
    DeleteListingEvent event,
    Emitter<ListingsState> emit,
  ) async {
    final result = await deleteListing(event.id);
    result.fold(
      (failure) =>
          emit(const ListingsError(message: 'Failed to delete listing')),
      (_) => emit(const ListingActionSuccess('Successfully deleted listing')),
    );
  }

  Future<void> _onToggleFeature(
    ToggleFeatureListingEvent event,
    Emitter<ListingsState> emit,
  ) async {
    final result = await toggleFeatureListing(event.id);
    result.fold(
      (failure) =>
          emit(const ListingsError(message: 'Failed to toggle feature')),
      (_) => emit(const ListingActionSuccess('Successfully toggled feature')),
    );
  }
}

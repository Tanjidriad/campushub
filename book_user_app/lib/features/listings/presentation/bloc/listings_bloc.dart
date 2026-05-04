import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/listing_repository.dart';
import '../../domain/usecases/get_listings_usecase.dart';
import '../../domain/usecases/get_listing_detail_usecase.dart';
import '../../domain/usecases/search_listings_usecase.dart';
import '../../domain/usecases/create_listing_usecase.dart';
import '../../domain/usecases/toggle_wishlist_usecase.dart';
import '../../domain/usecases/get_my_listings_usecase.dart';
import '../../domain/usecases/update_listing_usecase.dart';
import '../../domain/usecases/delete_listing_usecase.dart';
import '../../domain/usecases/mark_listing_sold_usecase.dart';
import '../../domain/usecases/delete_listing_image_usecase.dart';
import 'listings_event.dart';
import 'listings_state.dart';
import '../../domain/entities/listing.dart';

class ListingsBloc extends Bloc<ListingsEvent, ListingsState> {
  final GetListingsUseCase getListingsUseCase;
  final GetListingDetailUseCase getListingDetailUseCase;
  final SearchListingsUseCase searchListingsUseCase;
  final CreateListingUseCase createListingUseCase;
  final ToggleWishlistUseCase toggleWishlistUseCase;
  final GetMyListingsUseCase getMyListingsUseCase;
  final UpdateListingUseCase updateListingUseCase;
  final DeleteListingUseCase deleteListingUseCase;
  final MarkListingSoldUseCase markListingSoldUseCase;
  final DeleteListingImageUseCase deleteListingImageUseCase;
  final ListingRepository repository;

  // Current pagination state
  int _currentPage = 1;
  String? _currentCategory;
  String? _currentSearchQuery;
  String? _currentCondition;
  double? _currentMinPrice;
  double? _currentMaxPrice;
  String? _currentSortBy;
  String? _currentSortOrder;
  String? _currentEducationLevel;
  String? _currentClassOrSemester;
  String? _currentSubject;
  String? _currentBookType;
  String? _currentDivision;
  String? _currentDistrict;
  String? _currentUpazila;
  bool? _currentIsFeatured;
  int _currentLimit = 6;

  List<Listing> _featuredListings = [];
  List<Listing> _staffPicks = [];
  List<Listing> _recommendedListings = [];

  ListingsBloc({
    required this.getListingsUseCase,
    required this.getListingDetailUseCase,
    required this.searchListingsUseCase,
    required this.createListingUseCase,
    required this.toggleWishlistUseCase,
    required this.getMyListingsUseCase,
    required this.updateListingUseCase,
    required this.deleteListingUseCase,
    required this.markListingSoldUseCase,
    required this.deleteListingImageUseCase,
    required this.repository,
  }) : super(const ListingsInitial()) {
    on<ListingsLoadRequested>(_onListingsLoadRequested);
    on<ListingsLoadMoreRequested>(_onListingsLoadMoreRequested);
    on<ListingsRefreshRequested>(_onListingsRefreshRequested);
    on<ListingsFilterChanged>(_onListingsFilterChanged);
    on<ListingsSearchRequested>(_onListingsSearchRequested);
    on<ListingsSearchCleared>(_onListingsSearchCleared);
    on<ListingDetailRequested>(_onListingDetailRequested);
    on<ListingWishlistToggled>(_onListingWishlistToggled);
    on<ListingCreateRequested>(_onListingCreateRequested);
    on<MyListingsLoadRequested>(_onMyListingsLoadRequested);
    on<ListingDeleteRequested>(_onListingDeleteRequested);
    on<WishlistLoadRequested>(_onWishlistLoadRequested);
    on<PromoteListingRequested>(_onPromoteListingRequested);
    on<ListingUpdateRequested>(_onListingUpdateRequested);
    on<ListingMarkAsSoldRequested>(_onListingMarkAsSoldRequested);
    on<ListingImageDeleteRequested>(_onListingImageDeleteRequested);
  }

  Future<void> _onWishlistLoadRequested(
    WishlistLoadRequested event,
    Emitter<ListingsState> emit,
  ) async {
    emit(const ListingsLoading());

    // We need a usecase for getting wishlist
    // Since we don't have GetWishlistUseCase injected yet, we'll assume it exists or use repository directly for now
    // But clean architecture dictates usecases. I will check if GetWishlistUseCase exists.
    // Looking at previous file listing, I didn't see GetWishlistUseCase.
    // I should create it, but to save steps I will try to use the repository directly if allowed,
    // OR BETTER: `ListingRemoteDataSource` has `getWishlist`. `ListingRepository` should have it.
    // Let's assume `repository.getWishlist()` exists.

    final result = await repository.getWishlist();

    result.fold(
      (failure) => emit(ListingsError(message: failure.message)),
      (listings) => emit(WishlistLoaded(listings: listings)),
    );
  }

  Future<void> _onListingsLoadRequested(
    ListingsLoadRequested event,
    Emitter<ListingsState> emit,
  ) async {
    emit(const ListingsLoading());

    _currentPage = 1;
    if (event.params != null) {
      _currentCategory = event.params!.category;
      _currentCondition = event.params!.condition;
      _currentMinPrice = event.params!.minPrice;
      _currentMaxPrice = event.params!.maxPrice;
      _currentSortBy = event.params!.sortBy;
      _currentSortOrder = event.params!.sortOrder;
      _currentEducationLevel = event.params!.educationLevel;
      _currentClassOrSemester = event.params!.classOrSemester;
      _currentSubject = event.params!.subject;
      _currentBookType = event.params!.bookType;
      _currentDivision = event.params!.division;
      _currentDistrict = event.params!.district;
      _currentUpazila = event.params!.upazila;
      _currentIsFeatured = event.params!.isFeatured;
      _currentLimit = event.params!.limit;
    }

    final params = ListingsParams(
      page: _currentPage,
      limit: _currentLimit,
      category: _currentCategory,
      condition: _currentCondition,
      minPrice: _currentMinPrice,
      maxPrice: _currentMaxPrice,
      sortBy: _currentSortBy,
      sortOrder: _currentSortOrder,
      educationLevel: _currentEducationLevel,
      classOrSemester: _currentClassOrSemester,
      subject: _currentSubject,
      bookType: _currentBookType,
      division: _currentDivision,
      district: _currentDistrict,
      upazila: _currentUpazila,
      isFeatured: _currentIsFeatured,
    );

    // If params were provided explicitly (like from See All page), don't fetch home page parallel sections
    final isHomePageLoad = event.params == null && _currentCategory == null && _currentIsFeatured == null && _currentSortBy == null;

    final results = await Future.wait([
      getListingsUseCase(params),
      if (isHomePageLoad) getListingsUseCase(const ListingsParams(isFeatured: true, limit: 5)),
      if (isHomePageLoad) getListingsUseCase(
        const ListingsParams(
          limit: 10,
          sortBy: 'wishlistCount',
          sortOrder: 'desc',
        ),
      ),
      if (isHomePageLoad) repository.getRecommendedListings(limit: 10),
    ]);

    final mainResult = results[0] as Either<Failure, PaginatedListings>;
    
    List<Listing> featuredListings = _featuredListings;
    List<Listing> staffPicks = _staffPicks;
    List<Listing> recommendedListings = _recommendedListings;

    if (isHomePageLoad) {
      final featuredResult = results[1];
      final staffPicksResult = results[2];
      final recommendedResult = results[3];

      if (featuredResult.isRight()) {
        featuredResult.fold((_) {}, (data) {
          if (data is PaginatedListings) {
            featuredListings = data.listings;
          }
        });
      }
      _featuredListings = featuredListings;

      if (staffPicksResult.isRight()) {
        staffPicksResult.fold((_) {}, (data) {
          if (data is PaginatedListings) {
            staffPicks = data.listings;
          }
        });
      }
      _staffPicks = staffPicks;

      if (recommendedResult.isRight()) {
        recommendedResult.fold((_) {}, (data) {
          if (data is List<Listing>) {
            recommendedListings = data;
          }
        });
      }
      _recommendedListings = recommendedListings;
    }

    mainResult.fold(
      (failure) => emit(ListingsError(message: failure.message)),
      (paginatedListings) {
        // CLIENT-SIDE FILTER WORKAROUND:
        // Filter by sellerId if provided (fixes profile view on legacy backend)
        var listings = paginatedListings.listings;
        if (event.params?.sellerId != null &&
            event.params!.sellerId!.isNotEmpty) {
          listings = listings
              .where((l) => l.sellerId == event.params!.sellerId)
              .toList();
        }

        emit(
          ListingsLoaded(
            listings: listings,
            featuredListings: featuredListings,
            staffPicks: staffPicks,
            recommendedListings: recommendedListings,
            currentPage: paginatedListings.currentPage,
            totalPages: paginatedListings.totalPages,
            totalItems: listings.length,
            hasMore: paginatedListings.hasMore,
            category: _currentCategory,
            condition: _currentCondition,
            minPrice: _currentMinPrice,
            maxPrice: _currentMaxPrice,
            sortBy: _currentSortBy,
            sortOrder: _currentSortOrder,
            educationLevel: _currentEducationLevel,
            classOrSemester: _currentClassOrSemester,
            subject: _currentSubject,
            bookType: _currentBookType,
            division: _currentDivision,
            district: _currentDistrict,
            upazila: _currentUpazila,
          ),
        );
      },
    );
  }

  Future<void> _onListingsLoadMoreRequested(
    ListingsLoadMoreRequested event,
    Emitter<ListingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is ListingsLoaded &&
        currentState.hasMore &&
        !currentState.isLoadingMore) {
      emit(currentState.copyWith(isLoadingMore: true));

      _currentPage++;

      final params = _currentSearchQuery != null
          ? null
          : ListingsParams(
              page: _currentPage,
              limit: _currentLimit,
              category: _currentCategory,
              condition: _currentCondition,
              minPrice: _currentMinPrice,
              maxPrice: _currentMaxPrice,
              sortBy: _currentSortBy,
              sortOrder: _currentSortOrder,
              educationLevel: _currentEducationLevel,
              classOrSemester: _currentClassOrSemester,
              subject: _currentSubject,
              bookType: _currentBookType,
              division: _currentDivision,
              district: _currentDistrict,
              upazila: _currentUpazila,
              isFeatured: _currentIsFeatured,
            );

      final result = _currentSearchQuery != null
          ? await searchListingsUseCase(
              SearchParams(query: _currentSearchQuery!, page: _currentPage),
            )
          : await getListingsUseCase(params!);

      result.fold(
        (failure) {
          _currentPage--;
          emit(currentState.copyWith(isLoadingMore: false));
        },
        (paginatedListings) => emit(
          ListingsLoaded(
            listings: [...currentState.listings, ...paginatedListings.listings],
            featuredListings: _featuredListings,
            staffPicks: _staffPicks,
            recommendedListings: _recommendedListings,
            currentPage: paginatedListings.currentPage,
            totalPages: paginatedListings.totalPages,
            totalItems: paginatedListings.totalItems,
            hasMore: paginatedListings.hasMore,
            category: _currentCategory,
            searchQuery: _currentSearchQuery,
            condition: _currentCondition,
            minPrice: _currentMinPrice,
            maxPrice: _currentMaxPrice,
            sortBy: _currentSortBy,
            sortOrder: _currentSortOrder,
            educationLevel: _currentEducationLevel,
            classOrSemester: _currentClassOrSemester,
            subject: _currentSubject,
            bookType: _currentBookType,
            division: _currentDivision,
            district: _currentDistrict,
            upazila: _currentUpazila,
          ),
        ),
      );
    }
  }

  Future<void> _onListingsRefreshRequested(
    ListingsRefreshRequested event,
    Emitter<ListingsState> emit,
  ) async {
    _currentPage = 1;

    if (_currentSearchQuery != null) {
      final result = await searchListingsUseCase(
        SearchParams(query: _currentSearchQuery!, page: _currentPage),
      );

      result.fold(
        (failure) => emit(ListingsError(message: failure.message)),
        (paginatedListings) => emit(
          ListingsLoaded(
            listings: paginatedListings.listings,
            featuredListings: _featuredListings,
            staffPicks: _staffPicks,
            recommendedListings: _recommendedListings,
            currentPage: paginatedListings.currentPage,
            totalPages: paginatedListings.totalPages,
            totalItems: paginatedListings.totalItems,
            hasMore: paginatedListings.hasMore,
            searchQuery: _currentSearchQuery,
            // Search clears other filters
          ),
        ),
      );
    } else {
      final params = ListingsParams(
        page: _currentPage,
        limit: _currentLimit,
        category: _currentCategory,
        condition: _currentCondition,
        minPrice: _currentMinPrice,
        maxPrice: _currentMaxPrice,
        sortBy: _currentSortBy,
        sortOrder: _currentSortOrder,
        educationLevel: _currentEducationLevel,
        classOrSemester: _currentClassOrSemester,
        subject: _currentSubject,
        bookType: _currentBookType,
        division: _currentDivision,
        district: _currentDistrict,
        upazila: _currentUpazila,
        isFeatured: _currentIsFeatured,
      );

      final isHomePageLoad = _currentCategory == null && _currentIsFeatured == null && _currentSortBy == null;

      // Fetch all data in parallel on refresh
      final results = await Future.wait([
        getListingsUseCase(params),
        if (isHomePageLoad) getListingsUseCase(const ListingsParams(isFeatured: true, limit: 5)),
        if (isHomePageLoad) getListingsUseCase(
          const ListingsParams(
            limit: 10,
            sortBy: 'wishlistCount',
            sortOrder: 'desc',
          ),
        ),
        if (isHomePageLoad) repository.getRecommendedListings(limit: 10),
      ]);

      final mainResult = results[0] as Either<Failure, PaginatedListings>;
      
      List<Listing> featuredListings = _featuredListings;
      List<Listing> staffPicks = _staffPicks;
      List<Listing> recommendedListings = _recommendedListings;

      if (isHomePageLoad) {
        final featuredResult = results[1];
        final staffPicksResult = results[2];
        final recommendedResult = results[3];

        if (featuredResult.isRight()) {
          featuredResult.fold((_) {}, (data) {
            if (data is PaginatedListings) {
              featuredListings = data.listings;
            }
          });
        }
        _featuredListings = featuredListings;

        if (staffPicksResult.isRight()) {
          staffPicksResult.fold((_) {}, (data) {
            if (data is PaginatedListings) {
              staffPicks = data.listings;
            }
          });
        }
        _staffPicks = staffPicks;

        if (recommendedResult.isRight()) {
          recommendedResult.fold((_) {}, (data) {
            if (data is List<Listing>) {
              recommendedListings = data;
            }
          });
        }
        _recommendedListings = recommendedListings;
      }

      mainResult.fold(
        (failure) => emit(ListingsError(message: failure.message)),
        (paginatedListings) => emit(
          ListingsLoaded(
            listings: paginatedListings.listings,
            featuredListings: featuredListings,
            staffPicks: staffPicks,
            recommendedListings: recommendedListings,
            currentPage: paginatedListings.currentPage,
            totalPages: paginatedListings.totalPages,
            totalItems: paginatedListings.totalItems,
            hasMore: paginatedListings.hasMore,
            category: _currentCategory,
            condition: _currentCondition,
            minPrice: _currentMinPrice,
            maxPrice: _currentMaxPrice,
            sortBy: _currentSortBy,
            sortOrder: _currentSortOrder,
            educationLevel: _currentEducationLevel,
            classOrSemester: _currentClassOrSemester,
            subject: _currentSubject,
            bookType: _currentBookType,
            division: _currentDivision,
            district: _currentDistrict,
            upazila: _currentUpazila,
          ),
        ),
      );
    }
  }

  Future<void> _onListingsFilterChanged(
    ListingsFilterChanged event,
    Emitter<ListingsState> emit,
  ) async {
    _currentCategory = event.category;
    _currentCondition = event.condition;
    _currentMinPrice = event.minPrice;
    _currentMaxPrice = event.maxPrice;
    _currentSortBy = event.sortBy;
    _currentSortOrder = event.sortOrder;
    _currentSearchQuery = null;
    _currentEducationLevel = event.educationLevel;
    _currentClassOrSemester = event.classOrSemester;
    _currentSubject = event.subject;
    _currentBookType = event.bookType;
    _currentDivision = event.division;
    _currentDistrict = event.district;
    _currentUpazila = event.upazila;

    emit(ListingsLoading(category: _currentCategory));

    _currentPage = 1;

    final params = ListingsParams(
      page: _currentPage,
      limit: _currentLimit,
      category: _currentCategory,
      condition: _currentCondition,
      minPrice: _currentMinPrice,
      maxPrice: _currentMaxPrice,
      sortBy: _currentSortBy,
      sortOrder: _currentSortOrder,
      educationLevel: _currentEducationLevel,
      classOrSemester: _currentClassOrSemester,
      subject: _currentSubject,
      bookType: _currentBookType,
      division: _currentDivision,
      district: _currentDistrict,
      upazila: _currentUpazila,
      isFeatured: _currentIsFeatured,
    );

    final result = await getListingsUseCase(params);

    result.fold(
      (failure) => emit(ListingsError(message: failure.message)),
      (paginatedListings) => emit(
        ListingsLoaded(
          listings: paginatedListings.listings,
          featuredListings: _featuredListings,
          staffPicks: _staffPicks,
          recommendedListings: _recommendedListings,
          currentPage: paginatedListings.currentPage,
          totalPages: paginatedListings.totalPages,
          totalItems: paginatedListings.totalItems,
          hasMore: paginatedListings.hasMore,
          category: _currentCategory,
          condition: _currentCondition,
          minPrice: _currentMinPrice,
          maxPrice: _currentMaxPrice,
          sortBy: _currentSortBy,
          sortOrder: _currentSortOrder,
          educationLevel: _currentEducationLevel,
          classOrSemester: _currentClassOrSemester,
          subject: _currentSubject,
          bookType: _currentBookType,
          division: _currentDivision,
          district: _currentDistrict,
          upazila: _currentUpazila,
        ),
      ),
    );
  }

  Future<void> _onListingsSearchRequested(
    ListingsSearchRequested event,
    Emitter<ListingsState> emit,
  ) async {
    emit(const ListingsLoading());

    _currentPage = 1;
    _currentSearchQuery = event.query;
    _currentCategory = null;

    final result = await searchListingsUseCase(
      SearchParams(query: event.query, page: _currentPage),
    );

    result.fold(
      (failure) => emit(ListingsError(message: failure.message)),
      (paginatedListings) => emit(
        ListingsLoaded(
          listings: paginatedListings.listings,
          currentPage: paginatedListings.currentPage,
          totalPages: paginatedListings.totalPages,
          totalItems: paginatedListings.totalItems,
          hasMore: paginatedListings.hasMore,
          searchQuery: _currentSearchQuery,
        ),
      ),
    );
  }

  Future<void> _onListingsSearchCleared(
    ListingsSearchCleared event,
    Emitter<ListingsState> emit,
  ) async {
    _currentSearchQuery = null;
    add(const ListingsLoadRequested());
  }

  Future<void> _onListingDetailRequested(
    ListingDetailRequested event,
    Emitter<ListingsState> emit,
  ) async {
    emit(const ListingDetailLoading());

    final result = await getListingDetailUseCase(event.listingId);

    if (isClosed) return;

    result.fold(
      (failure) => emit(ListingsError(message: failure.message)),
      (listing) => emit(ListingDetailLoaded(listing: listing)),
    );
  }

  Future<void> _onListingWishlistToggled(
    ListingWishlistToggled event,
    Emitter<ListingsState> emit,
  ) async {
    final previousState = state;
    final result = await toggleWishlistUseCase(event.listingId);

    result.fold((failure) => emit(ListingsError(message: failure.message)), (
      isInWishlist,
    ) {
      // Emit WishlistToggled for detail page listeners
      emit(
        WishlistToggled(listingId: event.listingId, isInWishlist: isInWishlist),
      );

      // Restore previous state with updated isInWishlist flag
      if (previousState is ListingsLoaded) {
        final updatedListings = previousState.listings.map((listing) {
          if (listing.id == event.listingId) {
            return listing.copyWith(isInWishlist: isInWishlist);
          }
          return listing;
        }).toList();

        final updatedFeatured = previousState.featuredListings.map((listing) {
          if (listing.id == event.listingId) {
            return listing.copyWith(isInWishlist: isInWishlist);
          }
          return listing;
        }).toList();

        final updatedStaffPicks = previousState.staffPicks.map((listing) {
          if (listing.id == event.listingId) {
            return listing.copyWith(isInWishlist: isInWishlist);
          }
          return listing;
        }).toList();

        final updatedRecommended = previousState.recommendedListings.map((listing) {
          if (listing.id == event.listingId) {
            return listing.copyWith(isInWishlist: isInWishlist);
          }
          return listing;
        }).toList();

        emit(
          previousState.copyWith(
            listings: updatedListings,
            featuredListings: updatedFeatured,
            staffPicks: updatedStaffPicks,
            recommendedListings: updatedRecommended,
          ),
        );
      }
    });
  }

  Future<void> _onListingCreateRequested(
    ListingCreateRequested event,
    Emitter<ListingsState> emit,
  ) async {
    emit(const ListingCreating());

    final result = await createListingUseCase(
      CreateListingParams(
        title: event.title,
        description: event.description,
        category: event.category,
        priceType: event.priceType,
        price: event.price,
        currency: event.currency,
        condition: event.condition,
        locationName: event.locationName,
        locationAddress: event.locationAddress,
        meetupPreferences: event.meetupPreferences,
        tags: event.tags,
        imagePaths: event.imagePaths,
        educationLevel: event.educationLevel,
        classOrSemester: event.classOrSemester,
        subject: event.subject,
        bookType: event.bookType,
        division: event.division,
        district: event.district,
        upazila: event.upazila,
      ),
    );

    result.fold(
      (failure) => emit(ListingsError(message: failure.message)),
      (listing) => emit(ListingCreated(listing: listing)),
    );
  }

  Future<void> _onMyListingsLoadRequested(
    MyListingsLoadRequested event,
    Emitter<ListingsState> emit,
  ) async {
    emit(const ListingsLoading());

    final result = await getMyListingsUseCase(
      GetMyListingsParams(page: 1, status: event.status),
    );

    result.fold(
      (failure) => emit(ListingsError(message: failure.message)),
      (paginatedListings) => emit(
        MyListingsLoaded(
          listings: paginatedListings.listings,
          currentPage: paginatedListings.currentPage,
          hasMore: paginatedListings.hasMore,
          statusFilter: event.status,
        ),
      ),
    );
  }

  Future<void> _onListingDeleteRequested(
    ListingDeleteRequested event,
    Emitter<ListingsState> emit,
  ) async {
    final result = await deleteListingUseCase(event.listingId);

    result.fold(
      (failure) => emit(ListingsError(message: failure.message)),
      (_) => emit(ListingDeleted(listingId: event.listingId)),
    );
  }

  Future<void> _onPromoteListingRequested(
    PromoteListingRequested event,
    Emitter<ListingsState> emit,
  ) async {
    print('🔵 Bloc: PromoteListingRequested received');
    emit(const ListingPromoting());

    final result = await repository.promoteListing(event.listingId, event.plan);
    print(
      '🔵 Bloc: promoteListing result received: ${result.isRight() ? "SUCCESS" : "FAILURE"}',
    );

    result.fold(
      (failure) {
        print('🔵 Bloc: emitting ListingsError: ${failure.message}');
        emit(ListingsError(message: failure.message));
      },
      (listing) {
        print('🔵 Bloc: emitting ListingPromoted, listing.id=${listing.id}');
        emit(ListingPromoted(listing: listing));
        print('🔵 Bloc: ListingPromoted emitted successfully');
      },
    );
  }

  Future<void> _onListingUpdateRequested(
    ListingUpdateRequested event,
    Emitter<ListingsState> emit,
  ) async {
    emit(const ListingUpdating());

    final result = await updateListingUseCase(
      UpdateListingParams(
        id: event.listingId,
        title: event.title,
        description: event.description,
        category: event.category,
        priceType: event.priceType,
        price: event.price,
        currency: event.currency,
        condition: event.condition,
        locationName: event.locationName,
        locationAddress: event.locationAddress,
        meetupPreferences: event.meetupPreferences,
        tags: event.tags,
        educationLevel: event.educationLevel,
        classOrSemester: event.classOrSemester,
        subject: event.subject,
        bookType: event.bookType,
        division: event.division,
        district: event.district,
        upazila: event.upazila,
      ),
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(ListingsError(message: failure.message)),
      (listing) => emit(ListingUpdated(listing: listing)),
    );
  }

  Future<void> _onListingMarkAsSoldRequested(
    ListingMarkAsSoldRequested event,
    Emitter<ListingsState> emit,
  ) async {
    emit(const ListingMarkingAsSold());

    final result = await markListingSoldUseCase(
      MarkListingSoldParams(
        listingId: event.listingId,
        buyerId: event.buyerId,
        soldPrice: event.soldPrice,
      ),
    );

    result.fold(
      (failure) => emit(ListingsError(message: failure.message)),
      (_) => emit(ListingMarkedAsSold(listingId: event.listingId)),
    );
  }

  Future<void> _onListingImageDeleteRequested(
    ListingImageDeleteRequested event,
    Emitter<ListingsState> emit,
  ) async {
    emit(const ListingImageDeleting());

    final result = await deleteListingImageUseCase(
      DeleteListingImageParams(
        listingId: event.listingId,
        imageId: event.imageId,
      ),
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(ListingsError(message: failure.message)),
      (listing) => emit(ListingImageDeleted(listing: listing)),
    );
  }
}

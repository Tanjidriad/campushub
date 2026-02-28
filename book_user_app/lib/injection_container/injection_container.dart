import 'package:book_user_app/core/network/api_client.dart';
import 'package:book_user_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:book_user_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:book_user_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:book_user_app/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:book_user_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:book_user_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:book_user_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:book_user_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:book_user_app/features/auth/domain/usecases/resend_verification_usecase.dart';
import 'package:book_user_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:book_user_app/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:book_user_app/features/auth/domain/usecases/update_avatar_usecase.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:book_user_app/features/offers/data/datasources/offer_remote_datasource.dart';
import 'package:book_user_app/features/offers/presentation/bloc/offer_bloc.dart';

import '../features/wishlist/data/datasources/wishlist_remote_datasource.dart';
import '../features/wishlist/data/repositories/wishlist_repository_impl.dart';
import '../features/wishlist/domain/repositories/wishlist_repository.dart';
import '../features/wishlist/domain/usecases/add_to_wishlist_usecase.dart';
import '../features/wishlist/domain/usecases/get_wishlist_usecase.dart';
import '../features/wishlist/domain/usecases/remove_from_wishlist_usecase.dart';
import '../features/wishlist/presentation/bloc/wishlist_bloc.dart';

// Listings imports
import 'package:book_user_app/features/listings/data/datasources/listing_remote_datasource.dart';
import 'package:book_user_app/features/listings/data/repositories/listing_repository_impl.dart';
import 'package:book_user_app/features/listings/domain/repositories/listing_repository.dart';
import 'package:book_user_app/features/listings/domain/usecases/get_listings_usecase.dart';
import 'package:book_user_app/features/listings/domain/usecases/get_listing_detail_usecase.dart';
import 'package:book_user_app/features/listings/domain/usecases/search_listings_usecase.dart';
import 'package:book_user_app/features/listings/domain/usecases/create_listing_usecase.dart';
import 'package:book_user_app/features/listings/domain/usecases/toggle_wishlist_usecase.dart';
import 'package:book_user_app/features/listings/domain/usecases/get_my_listings_usecase.dart';
import 'package:book_user_app/features/listings/domain/usecases/update_listing_usecase.dart';
import 'package:book_user_app/features/listings/domain/usecases/delete_listing_usecase.dart';
import 'package:book_user_app/features/listings/domain/usecases/mark_listing_sold_usecase.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_bloc.dart';
import 'package:book_user_app/features/create_listing/presentation/bloc/create_listing_bloc.dart';
import 'package:book_user_app/features/create_listing/data/datasources/create_listing_remote_datasource.dart';
import 'package:book_user_app/features/create_listing/data/repositories/create_listing_repository_impl.dart';
import 'package:book_user_app/features/create_listing/domain/repositories/create_listing_repository.dart';
import 'package:book_user_app/features/create_listing/domain/usecases/submit_listing_usecase.dart';

// Categories imports
import 'package:book_user_app/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:book_user_app/features/categories/data/repositories/category_repository_impl.dart';
import 'package:book_user_app/features/categories/domain/repositories/category_repository.dart';
import 'package:book_user_app/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:book_user_app/features/categories/presentation/bloc/categories_bloc.dart';

// Chat imports
import 'package:book_user_app/core/services/socket_service.dart';
import 'package:book_user_app/core/services/fcm_service.dart';
import 'package:book_user_app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:book_user_app/features/chat/data/repositories/chat_repository.dart';
import 'package:book_user_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:book_user_app/features/chat/presentation/bloc/conversations_bloc.dart';

// Profile imports
import 'package:book_user_app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:book_user_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:book_user_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:book_user_app/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:book_user_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:book_user_app/features/reviews/data/datasources/reviews_remote_datasource.dart';
import 'package:book_user_app/features/reviews/data/repositories/reviews_repository_impl.dart';
import 'package:book_user_app/features/reviews/domain/repositories/reviews_repository.dart';
import 'package:book_user_app/features/reviews/domain/usecases/get_seller_reviews_usecase.dart';
import 'package:book_user_app/features/reviews/domain/usecases/create_review_usecase.dart';
import 'package:book_user_app/features/reviews/presentation/bloc/reviews_bloc.dart';

// Notifications imports
import 'package:book_user_app/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:book_user_app/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:book_user_app/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:book_user_app/features/notifications/presentation/bloc/notifications_bloc.dart';

// Report imports
import 'package:book_user_app/features/report/data/datasources/report_remote_datasource.dart';
import 'package:book_user_app/features/report/data/repositories/report_repository_impl.dart';
import 'package:book_user_app/features/report/domain/repositories/report_repository.dart';

import 'package:get_it/get_it.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton(() => ApiClient());

  // Features - Auth
  await _initAuth();

  // Features - Listings
  await _initListings();

  // Features - Categories
  await _initCategories();

  // Features - Chat
  await _initChat();

  // Features - Profile
  await _initProfile();

  // Features - Reviews
  await _initReviews();

  // Features - Create Listing
  await _initCreateListing();

  // Features - Notifications
  await _initNotifications();

  // Services - FCM
  sl.registerLazySingleton<FCMService>(() => FCMService(apiClient: sl()));

  // Features - Report
  await _initReport();

  // Features - Offers
  await _initOffers();

  // Features - Wishlist
  await _initWishlist();
}

Future<void> _initAuth() async {
  // Datasources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), apiClient: sl()),
  );

  // Usecases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ResendVerificationUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAvatarUseCase(sl()));

  // Blocs
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      forgotPasswordUseCase: sl(),
      resendVerificationUseCase: sl(),
      resetPasswordUseCase: sl(),
      updateProfileUseCase: sl(),
      updateAvatarUseCase: sl(),
    ),
  );
}

Future<void> _initListings() async {
  // Datasources
  sl.registerLazySingleton<ListingRemoteDataSource>(
    () => ListingRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ListingRepository>(
    () => ListingRepositoryImpl(remoteDataSource: sl()),
  );

  // Usecases
  sl.registerLazySingleton(() => GetListingsUseCase(sl()));
  sl.registerLazySingleton(() => GetListingDetailUseCase(sl()));
  sl.registerLazySingleton(() => SearchListingsUseCase(sl()));
  sl.registerLazySingleton(() => CreateListingUseCase(sl()));
  sl.registerLazySingleton(() => ToggleWishlistUseCase(sl()));
  sl.registerLazySingleton(() => GetMyListingsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateListingUseCase(sl()));
  sl.registerLazySingleton(() => DeleteListingUseCase(sl()));
  sl.registerLazySingleton(() => MarkListingSoldUseCase(sl()));

  // Blocs
  sl.registerFactory(
    () => ListingsBloc(
      getListingsUseCase: sl(),
      getListingDetailUseCase: sl(),
      searchListingsUseCase: sl(),
      createListingUseCase: sl(),
      toggleWishlistUseCase: sl(),
      getMyListingsUseCase: sl(),
      updateListingUseCase: sl(),
      deleteListingUseCase: sl(),
      markListingSoldUseCase: sl(),
      repository: sl(),
    ),
  );
}

Future<void> _initCreateListing() async {
  // Datasources
  sl.registerLazySingleton<CreateListingRemoteDataSource>(
    () => CreateListingRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<CreateListingRepository>(
    () => CreateListingRepositoryImpl(remoteDataSource: sl()),
  );

  // Usecases
  sl.registerLazySingleton(() => SubmitListingUseCase(sl()));

  // Blocs
  sl.registerFactory(() => CreateListingBloc(submitListingUseCase: sl()));
}

Future<void> _initCategories() async {
  // Datasources
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl()),
  );

  // Usecases
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));

  // Blocs - Use LazySingleton so categories are loaded once and shared
  sl.registerLazySingleton(() => CategoriesBloc(getCategoriesUseCase: sl()));
}

Future<void> _initChat() async {
  // Services
  sl.registerLazySingleton<SocketService>(() => SocketService());

  // Datasources
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSource(apiClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepository(remoteDataSource: sl(), socketService: sl()),
  );

  // Blocs
  // Use Factory to ensure currentUserId is refreshed based on current session
  sl.registerFactory(() => ConversationsBloc(repository: sl()));

  sl.registerFactory(() => ChatBloc(repository: sl()));
}

Future<void> _initProfile() async {
  // Datasources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  // Usecases
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));

  // Blocs
  sl.registerFactory(() => ProfileBloc(getUserProfileUseCase: sl()));
}

Future<void> _initReviews() async {
  // Datasources
  sl.registerLazySingleton<ReviewsRemoteDataSource>(
    () => ReviewsRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ReviewsRepository>(
    () => ReviewsRepositoryImpl(remoteDataSource: sl()),
  );

  // Usecases
  sl.registerLazySingleton(() => GetSellerReviewsUseCase(sl()));
  sl.registerLazySingleton(() => CreateReviewUseCase(sl()));

  // Blocs
  sl.registerFactory(
    () => ReviewsBloc(getSellerReviewsUseCase: sl(), createReviewUseCase: sl()),
  );
}

Future<void> _initNotifications() async {
  // Datasources
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(remoteDataSource: sl()),
  );

  // Blocs
  sl.registerFactory(() => NotificationsBloc(repository: sl()));
}

Future<void> _initReport() async {
  // Datasources
  sl.registerLazySingleton<ReportRemoteDataSource>(
    () => ReportRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(remoteDataSource: sl()),
  );
}

Future<void> _initOffers() async {
  // Datasources
  sl.registerLazySingleton<OfferRemoteDataSource>(
    () => OfferRemoteDataSource(sl()),
  );

  // Blocs
  sl.registerFactory(() => OfferBloc(sl()));
}

Future<void> _initWishlist() async {
  // Datasources
  sl.registerLazySingleton<WishlistRemoteDataSource>(
    () => WishlistRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<WishlistRepository>(
    () => WishlistRepositoryImpl(remoteDataSource: sl()),
  );

  // Usecases
  sl.registerLazySingleton(() => GetWishlistUseCase(sl()));
  sl.registerLazySingleton(() => AddToWishlistUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFromWishlistUseCase(sl()));

  // Blocs
  sl.registerFactory(
    () => WishlistBloc(
      getWishlist: sl(),
      addToWishlist: sl(),
      removeFromWishlist: sl(),
    ),
  );
}

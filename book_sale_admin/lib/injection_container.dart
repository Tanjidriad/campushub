import 'package:get_it/get_it.dart';
import 'core/api_client.dart';

// === Auth ===
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/auth_usecases.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// === Users ===
import 'features/users/data/datasources/user_remote_data_source.dart';
import 'features/users/data/repositories/user_repository_impl.dart';
import 'features/users/domain/repositories/user_repository.dart';
import 'features/users/domain/usecases/user_usecases.dart';
import 'features/users/presentation/bloc/users_bloc.dart';

// === Dashboard ===
import 'features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/domain/usecases/dashboard_usecases.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';

// === Listings ===
import 'features/listings/data/datasources/listing_remote_data_source.dart';
import 'features/listings/data/repositories/listing_repository_impl.dart';
import 'features/listings/domain/repositories/listing_repository.dart';
import 'features/listings/domain/usecases/get_all_listings.dart';
import 'features/listings/domain/usecases/get_pending_listings.dart';
import 'features/listings/domain/usecases/listing_actions_usecases.dart';
import 'features/listings/presentation/bloc/listings_bloc.dart';

// === Category Config ===
import 'features/category_config/data/datasources/category_remote_data_source.dart';
import 'features/category_config/data/repositories/category_repository_impl.dart';
import 'features/category_config/domain/repositories/category_repository.dart';
import 'features/category_config/domain/usecases/category_usecases.dart';
import 'features/category_config/domain/usecases/listing_category_usecases.dart';
import 'features/category_config/presentation/bloc/category_bloc.dart';

// === Reports ===
import 'features/reports/data/datasources/report_remote_data_source.dart';
import 'features/reports/data/repositories/report_repository_impl.dart';
import 'features/reports/domain/repositories/report_repository.dart';
import 'features/reports/domain/usecases/report_usecases.dart';
import 'features/reports/presentation/bloc/reports_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ==================== BLoCs ====================
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      checkAuthUseCase: sl(),
      logoutUseCase: sl(),
      getSavedUserUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => DashboardBloc(getDashboardStats: sl(), getActivity: sl()),
  );

  sl.registerFactory(
    () => ListingsBloc(
      getPendingListings: sl(),
      getAllListings: sl(),
      approveListing: sl(),
      rejectListing: sl(),
      deleteListing: sl(),
      toggleFeatureListing: sl(),
    ),
  );

  sl.registerFactory(
    () => CategoryBloc(
      getConfig: sl(),
      saveConfig: sl(),
      getCategories: sl(),
      createCategory: sl(),
      updateCategory: sl(),
      deleteCategory: sl(),
      toggleStatus: sl(),
    ),
  );

  sl.registerFactory(() => ReportsBloc(getReports: sl(), reviewReport: sl()));

  sl.registerFactory(
    () => UsersBloc(getUsers: sl(), toggleBan: sl(), changeRole: sl()),
  );

  // ==================== Use Cases ====================
  // Auth
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetSavedUserUseCase(sl()));

  // Dashboard
  sl.registerLazySingleton(() => GetDashboardStats(sl()));
  sl.registerLazySingleton(() => GetActivity(sl()));

  // Listings
  sl.registerLazySingleton(() => GetPendingListings(sl()));
  sl.registerLazySingleton(() => GetAllListings(sl()));
  sl.registerLazySingleton(() => ApproveListing(sl()));
  sl.registerLazySingleton(() => RejectListing(sl()));
  sl.registerLazySingleton(() => DeleteListing(sl()));
  sl.registerLazySingleton(() => ToggleFeatureListing(sl()));

  // Category Config
  sl.registerLazySingleton(() => GetConfig(sl()));
  sl.registerLazySingleton(() => SaveConfig(sl()));
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => CreateListingCategory(sl()));
  sl.registerLazySingleton(() => UpdateListingCategory(sl()));
  sl.registerLazySingleton(() => DeleteListingCategory(sl()));
  sl.registerLazySingleton(() => ToggleListingCategoryStatus(sl()));

  // Reports
  sl.registerLazySingleton(() => GetReports(sl()));
  sl.registerLazySingleton(() => ReviewReport(sl()));

  // Users
  sl.registerLazySingleton(() => GetUsersUseCase(sl()));
  sl.registerLazySingleton(() => ToggleBanUseCase(sl()));
  sl.registerLazySingleton(() => ChangeRoleUseCase(sl()));

  // ==================== Repositories ====================
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ListingRepository>(
    () => ListingRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl()),
  );

  // ==================== Data Sources ====================
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<ListingRemoteDataSource>(
    () => ListingRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<ReportRemoteDataSource>(
    () => ReportRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(apiClient: sl()),
  );

  // ==================== Core ====================
  sl.registerLazySingleton(() => ApiClient());
}

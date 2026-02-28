import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/listing.dart';
import '../../domain/repositories/listing_repository.dart';
import '../datasources/listing_remote_datasource.dart';

class ListingRepositoryImpl implements ListingRepository {
  final ListingRemoteDataSource remoteDataSource;

  ListingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaginatedListings>> getListings(
    ListingsParams params,
  ) async {
    try {
      final result = await remoteDataSource.getListings(params);
      return Right(result);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(
        const ServerFailure('Failed to fetch listings. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, Listing>> getListingById(String id) async {
    try {
      final result = await remoteDataSource.getListingById(id);
      return Right(result);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(
        const ServerFailure('Failed to fetch listing. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, PaginatedListings>> searchListings({
    required String query,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final result = await remoteDataSource.searchListings(
        query: query,
        page: page,
        limit: limit,
      );
      return Right(result);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(
        const ServerFailure('Failed to search listings. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, PaginatedListings>> getListingsByCategory({
    required String category,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final result = await remoteDataSource.getListings(
        ListingsParams(page: page, limit: limit, category: category),
      );
      return Right(result);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(
        const ServerFailure('Failed to fetch listings. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, PaginatedListings>> getMyListings({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final result = await remoteDataSource.getMyListings(
        page: page,
        limit: limit,
        status: status,
      );
      return Right(result);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(
        const ServerFailure('Failed to fetch your listings. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, Listing>> createListing({
    required String title,
    required String description,
    required String category,
    required String priceType,
    double? price,
    String? currency,
    String? condition,
    String? locationName,
    String? locationAddress,
    String? meetupPreferences,
    List<String>? tags,
    required List<String> imagePaths,
    String? educationLevel,
    String? classOrSemester,
    String? subject,
    String? bookType,
    String? division,
    String? district,
    String? upazila,
  }) async {
    try {
      final result = await remoteDataSource.createListing(
        title: title,
        description: description,
        category: category,
        priceType: priceType,
        price: price,
        currency: currency,
        condition: condition,
        locationName: locationName,
        locationAddress: locationAddress,
        meetupPreferences: meetupPreferences,
        tags: tags,
        imagePaths: imagePaths,
        educationLevel: educationLevel,
        classOrSemester: classOrSemester,
        subject: subject,
        bookType: bookType,
        division: division,
        district: district,
        upazila: upazila,
      );
      return Right(result);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(
        const ServerFailure('Failed to create listing. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, Listing>> updateListing({
    required String id,
    String? title,
    String? description,
    String? category,
    String? priceType,
    double? price,
    String? condition,
  }) async {
    try {
      final result = await remoteDataSource.updateListing(
        id: id,
        title: title,
        description: description,
        category: category,
        priceType: priceType,
        price: price,
        condition: condition,
      );
      return Right(result);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(
        const ServerFailure('Failed to update listing. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteListing(String id) async {
    try {
      await remoteDataSource.deleteListing(id);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(
        const ServerFailure('Failed to delete listing. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> toggleWishlist(String listingId) async {
    try {
      // First try to add, if it fails (already in wishlist), remove it
      final result = await remoteDataSource.addToWishlist(listingId);
      return Right(result);
    } on ApiException catch (e) {
      // If already in wishlist, try to remove
      if (e.statusCode == 400 || e.message.contains('already')) {
        try {
          final result = await remoteDataSource.removeFromWishlist(listingId);
          return Right(result);
        } on ApiException catch (e2) {
          return Left(_handleApiException(e2));
        }
      }
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(
        const ServerFailure('Failed to update wishlist. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Listing>>> getWishlist() async {
    try {
      final result = await remoteDataSource.getWishlist();
      return Right(result);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(
        const ServerFailure('Failed to fetch wishlist. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    // Hardcoded for now - can be fetched from backend later
    const categories = [
      'Textbooks',
      'Electronics',
      'Furniture',
      'Clothing',
      'Sports',
      'Music',
      'Art',
      'Other',
    ];
    return const Right(categories);
  }

  @override
  Future<Either<Failure, Listing>> promoteListing(
    String listingId,
    String plan,
  ) async {
    try {
      final result = await remoteDataSource.promoteListing(listingId, plan);
      return Right(result);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(
        const ServerFailure('Failed to promote listing. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markAsSold(
    String listingId, {
    String? buyerId,
    double? soldPrice,
  }) async {
    try {
      await remoteDataSource.markAsSold(
        listingId,
        buyerId: buyerId,
        soldPrice: soldPrice,
      );
      return const Right(null);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(
        const ServerFailure(
          'Failed to mark listing as sold. Please try again.',
        ),
      );
    }
  }

  // Helper method to handle API exceptions
  Failure _handleApiException(ApiException exception) {
    final statusCode = exception.statusCode;
    final message = exception.message;

    if (statusCode == 401) {
      return AuthFailure(
        message.isNotEmpty ? message : 'Please login to continue',
      );
    } else if (statusCode == 403) {
      return UnauthorizedFailure(
        message.isNotEmpty ? message : 'Access denied',
      );
    } else if (statusCode == 400) {
      return ValidationFailure(message.isNotEmpty ? message : 'Invalid input');
    } else if (statusCode == 404) {
      return const ServerFailure('Listing not found');
    }

    return ServerFailure(message.isNotEmpty ? message : 'Something went wrong');
  }

  // Helper method to handle Dio exceptions
  Failure _handleDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timeout');
      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        final rawMessage = exception.response?.data['message'];
        final message = parseErrorMessage(rawMessage);
        if (statusCode == 401) {
          return AuthFailure(
            message.isNotEmpty ? message : 'Please login to continue',
          );
        } else if (statusCode == 403) {
          return UnauthorizedFailure(
            message.isNotEmpty ? message : 'Access denied',
          );
        } else if (statusCode == 400) {
          return ValidationFailure(
            message.isNotEmpty ? message : 'Invalid input',
          );
        }
        return ServerFailure(
          message.isNotEmpty ? message : 'Something went wrong',
        );
      case DioExceptionType.cancel:
        return const ServerFailure('Request cancelled');
      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection');
      case DioExceptionType.unknown:
        return const NetworkFailure('Network error occurred');
      default:
        return const ServerFailure('Something went wrong. Please try again.');
    }
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/listing.dart';
import '../../domain/repositories/listing_repository.dart';
import '../datasources/listing_remote_data_source.dart';

class ListingRepositoryImpl implements ListingRepository {
  final ListingRemoteDataSource remoteDataSource;

  ListingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Listing>>> getPendingListings({
    int limit = 50,
  }) async {
    try {
      final remoteListings = await remoteDataSource.getPendingListings(
        limit: limit,
      );
      return Right(remoteListings);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Listing>>> getAllListings({
    int limit = 50,
    String? search,
    String? category,
    bool? isFeatured,
  }) async {
    try {
      final remoteListings = await remoteDataSource.getAllListings(
        limit: limit,
        search: search,
        category: category,
        isFeatured: isFeatured,
      );
      return Right(remoteListings);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> approveListing(String id) async {
    try {
      await remoteDataSource.approveListing(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectListing(String id, String reason) async {
    try {
      await remoteDataSource.rejectListing(id, reason);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteListing(String id) async {
    try {
      await remoteDataSource.deleteListing(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFeatureListing(String id) async {
    try {
      await remoteDataSource.toggleFeatureListing(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/listing.dart';

abstract class ListingRepository {
  Future<Either<Failure, List<Listing>>> getPendingListings({int limit = 50});
  Future<Either<Failure, List<Listing>>> getAllListings({
    int limit = 50,
    String? search,
    String? category,
    bool? isFeatured,
  });
  Future<Either<Failure, void>> approveListing(String id);
  Future<Either<Failure, void>> rejectListing(String id, String reason);
  Future<Either<Failure, void>> deleteListing(String id);
  Future<Either<Failure, void>> toggleFeatureListing(String id);
}

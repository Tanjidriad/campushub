import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../listings/domain/entities/listing.dart';

/// Abstract repository interface for creating listings
abstract class CreateListingRepository {
  /// Create a new listing
  Future<Either<Failure, Listing>> createListing({
    required String title,
    required String description,
    required String category,
    required String priceType,
    double? price,
    String? condition,
    String? locationName,
    String? meetupPreferences,
    required List<String> imagePaths,
    String? educationLevel,
    String? classOrSemester,
    String? subject,
    String? bookType,
    String? division,
    String? district,
    String? upazila,
  });
}

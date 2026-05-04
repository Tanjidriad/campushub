import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../listings/domain/entities/listing.dart';
import '../../domain/repositories/create_listing_repository.dart';
import '../datasources/create_listing_remote_datasource.dart';

class CreateListingRepositoryImpl implements CreateListingRepository {
  final CreateListingRemoteDataSource remoteDataSource;

  CreateListingRepositoryImpl({required this.remoteDataSource});

  @override
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
    String? stream,
    String? department,
    String? classOrSemester,
    String? subject,
    String? bookType,
    String? division,
    String? district,
    String? upazila,
  }) async {
    try {
      final listing = await remoteDataSource.createListing(
        title: title,
        description: description,
        category: category,
        priceType: priceType,
        price: price,
        condition: condition,
        locationName: locationName,
        meetupPreferences: meetupPreferences,
        imagePaths: imagePaths,
        educationLevel: educationLevel,
        stream: stream,
        department: department,
        classOrSemester: classOrSemester,
        subject: subject,
        bookType: bookType,
        division: division,
        district: district,
        upazila: upazila,
      );
      return Right(listing);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

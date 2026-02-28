import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../listings/domain/entities/listing.dart';
import '../repositories/create_listing_repository.dart';

class SubmitListingParams {
  final String title;
  final String description;
  final String category;
  final String priceType;
  final double? price;
  final String? condition;
  final String? locationName;
  final String? meetupPreferences;
  final List<String> imagePaths;
  final String? educationLevel;
  final String? classOrSemester;
  final String? subject;
  final String? bookType;
  final String? division;
  final String? district;
  final String? upazila;

  const SubmitListingParams({
    required this.title,
    required this.description,
    required this.category,
    required this.priceType,
    this.price,
    this.condition,
    this.locationName,
    this.meetupPreferences,
    required this.imagePaths,
    this.educationLevel,
    this.classOrSemester,
    this.subject,
    this.bookType,
    this.division,
    this.district,
    this.upazila,
  });
}

class SubmitListingUseCase implements UseCase<Listing, SubmitListingParams> {
  final CreateListingRepository repository;

  SubmitListingUseCase(this.repository);

  @override
  Future<Either<Failure, Listing>> call(SubmitListingParams params) {
    return repository.createListing(
      title: params.title,
      description: params.description,
      category: params.category,
      priceType: params.priceType,
      price: params.price,
      condition: params.condition,
      locationName: params.locationName,
      meetupPreferences: params.meetupPreferences,
      imagePaths: params.imagePaths,
      educationLevel: params.educationLevel,
      classOrSemester: params.classOrSemester,
      subject: params.subject,
      bookType: params.bookType,
      division: params.division,
      district: params.district,
      upazila: params.upazila,
    );
  }
}

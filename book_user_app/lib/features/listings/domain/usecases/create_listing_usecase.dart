import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/listing.dart';
import '../repositories/listing_repository.dart';

class CreateListingParams {
  final String title;
  final String description;
  final String category;
  final String priceType;
  final double? price;
  final String? currency;
  final String? condition;
  final String? locationName;
  final String? locationAddress;
  final String? meetupPreferences;
  final List<String>? tags;
  final List<String> imagePaths;
  final String? educationLevel;
  final String? classOrSemester;
  final String? subject;
  final String? bookType;
  final String? division;
  final String? district;
  final String? upazila;

  const CreateListingParams({
    required this.title,
    required this.description,
    required this.category,
    required this.priceType,
    this.price,
    this.currency,
    this.condition,
    this.locationName,
    this.locationAddress,
    this.meetupPreferences,
    this.tags,
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

class CreateListingUseCase implements UseCase<Listing, CreateListingParams> {
  final ListingRepository repository;

  CreateListingUseCase(this.repository);

  @override
  Future<Either<Failure, Listing>> call(CreateListingParams params) async {
    return await repository.createListing(
      title: params.title,
      description: params.description,
      category: params.category,
      priceType: params.priceType,
      price: params.price,
      currency: params.currency,
      condition: params.condition,
      locationName: params.locationName,
      locationAddress: params.locationAddress,
      meetupPreferences: params.meetupPreferences,
      tags: params.tags,
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

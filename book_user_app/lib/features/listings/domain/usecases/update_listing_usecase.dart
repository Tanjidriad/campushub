import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/listing.dart';
import '../repositories/listing_repository.dart';

class UpdateListingParams {
  final String id;
  final String? title;
  final String? description;
  final String? category;
  final String? priceType;
  final double? price;
  final String? condition;

  final String? currency;
  final String? locationName;
  final String? locationAddress;
  final String? meetupPreferences;
  final List<String>? tags;
  final String? educationLevel;
  final String? classOrSemester;
  final String? subject;
  final String? bookType;
  final String? division;
  final String? district;
  final String? upazila;

  const UpdateListingParams({
    required this.id,
    this.title,
    this.description,
    this.category,
    this.priceType,
    this.price,
    this.condition,
    this.currency,
    this.locationName,
    this.locationAddress,
    this.meetupPreferences,
    this.tags,
    this.educationLevel,
    this.classOrSemester,
    this.subject,
    this.bookType,
    this.division,
    this.district,
    this.upazila,
  });
}

class UpdateListingUseCase {
  final ListingRepository repository;

  UpdateListingUseCase(this.repository);

  Future<Either<Failure, Listing>> call(UpdateListingParams params) async {
    return await repository.updateListing(
      id: params.id,
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

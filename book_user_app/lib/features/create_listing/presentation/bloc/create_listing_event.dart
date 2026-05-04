part of 'create_listing_bloc.dart';

abstract class CreateListingEvent extends Equatable {
  const CreateListingEvent();

  @override
  List<Object?> get props => [];
}

/// User selected photos in step 1
class PhotosSelected extends CreateListingEvent {
  final List<String> imagePaths;

  const PhotosSelected({required this.imagePaths});

  @override
  List<Object?> get props => [imagePaths];
}

/// User filled details in step 2
class DetailsUpdated extends CreateListingEvent {
  final String title;
  final String category;
  final String condition;
  final String description;
  final String? educationLevel;
  final String? stream;
  final String? department;
  final String? classOrSemester;
  final String? subject;
  final String? bookType;
  final String? division;
  final String? district;
  final String? upazila;

  const DetailsUpdated({
    required this.title,
    required this.category,
    required this.condition,
    required this.description,
    this.educationLevel,
    this.stream,
    this.department,
    this.classOrSemester,
    this.subject,
    this.bookType,
    this.division,
    this.district,
    this.upazila,
  });

  @override
  List<Object?> get props => [
    title,
    category,
    condition,
    description,
    educationLevel,
    stream,
    department,
    classOrSemester,
    subject,
    bookType,
    division,
    district,
    upazila,
  ];
}

/// User filled price/location in step 3
class PriceUpdated extends CreateListingEvent {
  final double price;
  final String priceType;
  final bool isOpenToOffers;
  final String locationName;
  final String? meetupPreferences;

  const PriceUpdated({
    required this.price,
    required this.priceType,
    required this.isOpenToOffers,
    required this.locationName,
    this.meetupPreferences,
  });

  @override
  List<Object?> get props => [
    price,
    priceType,
    isOpenToOffers,
    locationName,
    meetupPreferences,
  ];
}

/// Submit the listing
class SubmitListing extends CreateListingEvent {
  const SubmitListing();
}

/// Reset the form
class ResetCreateListingForm extends CreateListingEvent {
  const ResetCreateListingForm();
}

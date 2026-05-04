part of 'create_listing_bloc.dart';

abstract class CreateListingState extends Equatable {
  const CreateListingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CreateListingInitial extends CreateListingState {
  const CreateListingInitial();
}

/// Form is being filled (holds current data)
class CreateListingInProgress extends CreateListingState {
  final List<String> imagePaths;
  final String? title;
  final String? category;
  final String? condition;
  final String? description;
  final double? price;
  final String? priceType;
  final bool isOpenToOffers;
  final String? locationName;
  final String? meetupPreferences;
  final String? educationLevel;
  final String? stream;
  final String? department;
  final String? classOrSemester;
  final String? subject;
  final String? bookType;
  final String? division;
  final String? district;
  final String? upazila;

  const CreateListingInProgress({
    this.imagePaths = const [],
    this.title,
    this.category,
    this.condition,
    this.description,
    this.price,
    this.priceType,
    this.isOpenToOffers = true,
    this.locationName,
    this.meetupPreferences,
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

  CreateListingInProgress copyWith({
    List<String>? imagePaths,
    String? title,
    String? category,
    String? condition,
    String? description,
    double? price,
    String? priceType,
    bool? isOpenToOffers,
    String? locationName,
    String? meetupPreferences,
    String? educationLevel,
    String? stream,
    String? department,
    String? classOrSemester,
    String? subject,
    String? bookType,
    String? division,
    String? district,
    String? upazila,
  }) {
    return CreateListingInProgress(
      imagePaths: imagePaths ?? this.imagePaths,
      title: title ?? this.title,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      price: price ?? this.price,
      priceType: priceType ?? this.priceType,
      isOpenToOffers: isOpenToOffers ?? this.isOpenToOffers,
      locationName: locationName ?? this.locationName,
      meetupPreferences: meetupPreferences ?? this.meetupPreferences,
      educationLevel: educationLevel ?? this.educationLevel,
      stream: stream ?? this.stream,
      department: department ?? this.department,
      classOrSemester: classOrSemester ?? this.classOrSemester,
      subject: subject ?? this.subject,
      bookType: bookType ?? this.bookType,
      division: division ?? this.division,
      district: district ?? this.district,
      upazila: upazila ?? this.upazila,
    );
  }

  @override
  List<Object?> get props => [
    imagePaths,
    title,
    category,
    condition,
    description,
    price,
    priceType,
    isOpenToOffers,
    locationName,
    meetupPreferences,
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

/// Submitting listing
class CreateListingSubmitting extends CreateListingState {
  const CreateListingSubmitting();
}

/// Listing created successfully
class CreateListingSuccess extends CreateListingState {
  final String listingId;

  const CreateListingSuccess({required this.listingId});

  @override
  List<Object?> get props => [listingId];
}

/// Error occurred
class CreateListingFailure extends CreateListingState {
  final String message;

  const CreateListingFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class ListingFormData {
  List<String> imagePaths;
  String? title;
  String? description;
  String? category;
  String? condition;
  String? priceType; // 'fixed', 'negotiable', 'free'
  double? price;
  bool isOpenToOffers;
  String? locationName;
  String? locationAddress;
  String? meetupPreferences;
  List<String> tags;
  // Education metadata
  String? educationLevel; // school, college, university, other
  String? stream;
  String? department;
  String? classOrSemester;
  String? subject;
  String? bookType; // nctb, guide, reference, university_textbook, other
  // Bangladesh location
  String? division;
  String? district;
  String? upazila;

  ListingFormData({
    this.imagePaths = const [],
    this.title,
    this.description,
    this.category,
    this.condition = 'good',
    this.priceType = 'fixed',
    this.price,
    this.isOpenToOffers = true,
    this.locationName,
    this.locationAddress,
    this.meetupPreferences,
    this.tags = const [],
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

  ListingFormData copyWith({
    List<String>? imagePaths,
    String? title,
    String? description,
    String? category,
    String? condition,
    String? priceType,
    double? price,
    bool? isOpenToOffers,
    String? locationName,
    String? locationAddress,
    String? meetupPreferences,
    List<String>? tags,
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
    return ListingFormData(
      imagePaths: imagePaths ?? this.imagePaths,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      priceType: priceType ?? this.priceType,
      price: price ?? this.price,
      isOpenToOffers: isOpenToOffers ?? this.isOpenToOffers,
      locationName: locationName ?? this.locationName,
      locationAddress: locationAddress ?? this.locationAddress,
      meetupPreferences: meetupPreferences ?? this.meetupPreferences,
      tags: tags ?? this.tags,
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
}

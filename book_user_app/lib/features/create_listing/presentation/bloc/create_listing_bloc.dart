import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/submit_listing_usecase.dart';

part 'create_listing_event.dart';
part 'create_listing_state.dart';

class CreateListingBloc extends Bloc<CreateListingEvent, CreateListingState> {
  final SubmitListingUseCase _submitListingUseCase;

  /// Cached form data — survives Submitting/Failure state transitions
  CreateListingInProgress? _lastFormData;

  CreateListingBloc({required SubmitListingUseCase submitListingUseCase})
    : _submitListingUseCase = submitListingUseCase,
      super(const CreateListingInitial()) {
    on<PhotosSelected>(_onPhotosSelected);
    on<DetailsUpdated>(_onDetailsUpdated);
    on<PriceUpdated>(_onPriceUpdated);
    on<SubmitListing>(_onSubmitListing);
    on<ResetCreateListingForm>(_onResetForm);
  }

  /// Resolve current form data from state or cache
  CreateListingInProgress? get _formData {
    final s = state;
    if (s is CreateListingInProgress) return s;
    return _lastFormData;
  }

  void _onPhotosSelected(
    PhotosSelected event,
    Emitter<CreateListingState> emit,
  ) {
    final current = _formData;
    final next = current != null
        ? current.copyWith(imagePaths: event.imagePaths)
        : CreateListingInProgress(imagePaths: event.imagePaths);
    _lastFormData = next;
    emit(next);
  }

  void _onDetailsUpdated(
    DetailsUpdated event,
    Emitter<CreateListingState> emit,
  ) {
    final current = _formData;
    final next = current != null
        ? current.copyWith(
            title: event.title,
            category: event.category,
            condition: event.condition,
            description: event.description,
            educationLevel: event.educationLevel,
            classOrSemester: event.classOrSemester,
            subject: event.subject,
            bookType: event.bookType,
            division: event.division,
            district: event.district,
            upazila: event.upazila,
          )
        : CreateListingInProgress(
            title: event.title,
            category: event.category,
            condition: event.condition,
            description: event.description,
            educationLevel: event.educationLevel,
            classOrSemester: event.classOrSemester,
            subject: event.subject,
            bookType: event.bookType,
            division: event.division,
            district: event.district,
            upazila: event.upazila,
          );
    _lastFormData = next;
    emit(next);
  }

  void _onPriceUpdated(PriceUpdated event, Emitter<CreateListingState> emit) {
    final current = _formData;
    if (current == null) return;
    final next = current.copyWith(
      price: event.price,
      priceType: event.priceType,
      isOpenToOffers: event.isOpenToOffers,
      locationName: event.locationName,
      meetupPreferences: event.meetupPreferences,
    );
    _lastFormData = next;
    emit(next);
  }

  Future<void> _onSubmitListing(
    SubmitListing event,
    Emitter<CreateListingState> emit,
  ) async {
    final formData = _formData;
    if (formData == null) {
      emit(const CreateListingFailure(message: 'No listing data to submit'));
      return;
    }

    // Validate
    if (formData.imagePaths.isEmpty) {
      emit(
        const CreateListingFailure(message: 'Please add at least one photo'),
      );
      return;
    }
    if (formData.title == null || formData.title!.isEmpty) {
      emit(const CreateListingFailure(message: 'Please enter a title'));
      return;
    }
    if (formData.category == null) {
      emit(const CreateListingFailure(message: 'Please select a category'));
      return;
    }

    emit(const CreateListingSubmitting());

    final result = await _submitListingUseCase(
      SubmitListingParams(
        title: formData.title!,
        description: formData.description ?? '',
        category: formData.category!,
        priceType: formData.priceType ?? 'fixed',
        price: formData.price,
        condition: formData.condition,
        locationName: formData.locationName,
        meetupPreferences: formData.meetupPreferences,
        imagePaths: formData.imagePaths,
        educationLevel: formData.educationLevel,
        classOrSemester: formData.classOrSemester,
        subject: formData.subject,
        bookType: formData.bookType,
        division: formData.division,
        district: formData.district,
        upazila: formData.upazila,
      ),
    );

    result.fold(
      (failure) => emit(CreateListingFailure(message: failure.message)),
      (listing) {
        _lastFormData = null;
        emit(CreateListingSuccess(listingId: listing.id));
      },
    );
  }

  void _onResetForm(
    ResetCreateListingForm event,
    Emitter<CreateListingState> emit,
  ) {
    _lastFormData = null;
    emit(const CreateListingInitial());
  }
}

import 'package:book_user_app/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:book_user_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:book_user_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;

  ProfileBloc({required this.getUserProfileUseCase}) : super(ProfileInitial()) {
    on<UserProfileLoadRequested>(_onUserProfileLoadRequested);
  }

  Future<void> _onUserProfileLoadRequested(
    UserProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await getUserProfileUseCase(event.userId);

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (user) => emit(ProfileLoaded(user: user)),
    );
  }
}

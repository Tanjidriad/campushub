import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_user_app/core/services/fcm_service.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/resend_verification_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:book_user_app/features/auth/domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/update_avatar_usecase.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResendVerificationUseCase resendVerificationUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UpdateAvatarUseCase updateAvatarUseCase;
  final ChangePasswordUseCase changePasswordUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.forgotPasswordUseCase,
    required this.resendVerificationUseCase,
    required this.resetPasswordUseCase,
    required this.updateProfileUseCase,
    required this.updateAvatarUseCase,
    required this.changePasswordUseCase,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthGetCurrentUserRequested>(_onGetCurrentUserRequested);
    on<AuthUserUpdated>(_onUserUpdated);
    on<AuthForgotPasswordRequested>(_onForgotPasswordRequested);
    on<AuthResendVerificationRequested>(_onResendVerificationRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);
    on<AuthUpdateProfileRequested>(_onUpdateProfileRequested);
    on<AuthUpdateAvatarRequested>(_onUpdateAvatarRequested);
    on<AuthChangePasswordRequested>(_onChangePasswordRequested);
  }

  Future<void> _onChangePasswordRequested(
    AuthChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = state is AuthAuthenticated
        ? (state as AuthAuthenticated).user
        : null;
    emit(const AuthChangePasswordLoading());
    final result = await changePasswordUseCase(
      ChangePasswordParams(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) {
        emit(const AuthChangePasswordSuccess());
        if (currentUser != null) {
          // Keep auth identity state stable after password update.
          emit(AuthAuthenticated(currentUser));
        }
      },
    );
  }

  Future<void> _onForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthForgotPasswordLoading());
    final result = await forgotPasswordUseCase(
      ForgotPasswordParams(email: event.email),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthForgotPasswordSuccess()),
    );
  }

  Future<void> _onResendVerificationRequested(
    AuthResendVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    // We don't want to change the main state to loading for this,
    // as it usually happens on a screen where user is already viewing something
    // But we might want to show a loading indicator on the button.
    // For now we'll rely on the result to show success/error toast.
    final result = await resendVerificationUseCase(const NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthResendVerificationSuccess()),
    );
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await getCurrentUserUseCase(const NoParams());

    result.fold((failure) => emit(const AuthUnauthenticated()), (user) {
      emit(AuthAuthenticated(user));
      if (user.isVerified) {
        // Register FCM token only for verified users because backend
        // protects token endpoints with requireVerified.
        sl<FCMService>().registerToken();
      }
    });
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoginLoading());

    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    result.fold((failure) => emit(AuthError(failure.message)), (user) {
      emit(AuthAuthenticated(user));
      if (user.isVerified) {
        // Register FCM token only for verified users because backend
        // protects token endpoints with requireVerified.
        sl<FCMService>().registerToken();
      }
    });
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthRegisterLoading());

    final result = await registerUseCase(
      RegisterParams(
        email: event.email,
        password: event.password,
        name: event.name,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthRegistrationSuccess(user)),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // Remove FCM token before logout
    await sl<FCMService>().removeToken();

    final result = await logoutUseCase(const NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onGetCurrentUserRequested(
    AuthGetCurrentUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await getCurrentUserUseCase(const NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onUserUpdated(
    AuthUserUpdated event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthAuthenticated(event.user));
  }

  Future<void> _onResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthResetPasswordLoading());
    final result = await resetPasswordUseCase(
      ResetPasswordParams(token: event.token, newPassword: event.newPassword),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthResetPasswordSuccess()),
    );
  }

  Future<void> _onUpdateProfileRequested(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Keep current state but show loading indicator if possible, or just emit loading
    // Since we are on a form screen, we can emit loading
    emit(const AuthLoading());

    final result = await updateProfileUseCase(
      UpdateProfileParams(
        name: event.name,
        username: event.username,
        phone: event.phone,
        bio: event.bio,
        location: event.location,
        educationLevel: event.educationLevel,
        stream: event.stream,
        department: event.department,
        classOrSemester: event.classOrSemester,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onUpdateAvatarRequested(
    AuthUpdateAvatarRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthAvatarUploading());

    final result = await updateAvatarUseCase(event.imageFile);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}

import 'package:bloc_test/bloc_test.dart';
import 'package:book_user_app/core/errors/failures.dart';
import 'package:book_user_app/core/usecases/usecase.dart';
import 'package:book_user_app/features/auth/domain/entities/user.dart';
import 'package:book_user_app/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:book_user_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:book_user_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:book_user_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:book_user_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:book_user_app/features/auth/domain/usecases/resend_verification_usecase.dart';
import 'package:book_user_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:book_user_app/features/auth/domain/usecases/update_avatar_usecase.dart';
import 'package:book_user_app/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:book_user_app/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:book_user_app/core/services/fcm_service.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockForgotPasswordUseCase extends Mock implements ForgotPasswordUseCase {}

class MockResendVerificationUseCase extends Mock
    implements ResendVerificationUseCase {}

class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}

class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

class MockUpdateAvatarUseCase extends Mock implements UpdateAvatarUseCase {}

class MockChangePasswordUseCase extends Mock implements ChangePasswordUseCase {}

class MockFCMService extends Mock implements FCMService {}

// Fallback values
class FakeLoginParams extends Fake implements LoginParams {}

class FakeRegisterParams extends Fake implements RegisterParams {}

class FakeNoParams extends Fake implements NoParams {}

class FakeForgotPasswordParams extends Fake implements ForgotPasswordParams {}

class FakeResetPasswordParams extends Fake implements ResetPasswordParams {}

class FakeUpdateProfileParams extends Fake implements UpdateProfileParams {}

const tUser = User(
  id: '1',
  email: 'test@test.com',
  name: 'Test User',
  role: 'student',
  isVerified: true,
);

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockForgotPasswordUseCase mockForgotPasswordUseCase;
  late MockResendVerificationUseCase mockResendVerificationUseCase;
  late MockResetPasswordUseCase mockResetPasswordUseCase;
  late MockUpdateProfileUseCase mockUpdateProfileUseCase;
  late MockUpdateAvatarUseCase mockUpdateAvatarUseCase;
  late MockChangePasswordUseCase mockChangePasswordUseCase;
  late MockFCMService mockFCMService;

  setUpAll(() {
    registerFallbackValue(FakeLoginParams());
    registerFallbackValue(FakeRegisterParams());
    registerFallbackValue(FakeNoParams());
    registerFallbackValue(FakeForgotPasswordParams());
    registerFallbackValue(FakeResetPasswordParams());
    registerFallbackValue(FakeUpdateProfileParams());
  });

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockForgotPasswordUseCase = MockForgotPasswordUseCase();
    mockResendVerificationUseCase = MockResendVerificationUseCase();
    mockResetPasswordUseCase = MockResetPasswordUseCase();
    mockUpdateProfileUseCase = MockUpdateProfileUseCase();
    mockUpdateAvatarUseCase = MockUpdateAvatarUseCase();
    mockChangePasswordUseCase = MockChangePasswordUseCase();
    mockFCMService = MockFCMService();

    // Register FCMService mock in GetIt
    final getIt = GetIt.instance;
    if (getIt.isRegistered<FCMService>()) {
      getIt.unregister<FCMService>();
    }
    getIt.registerSingleton<FCMService>(mockFCMService);

    when(() => mockFCMService.registerToken()).thenAnswer((_) async {});
    when(() => mockFCMService.removeToken()).thenAnswer((_) async {});
  });

  tearDown(() {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<FCMService>()) {
      getIt.unregister<FCMService>();
    }
  });

  AuthBloc buildBloc() => AuthBloc(
    loginUseCase: mockLoginUseCase,
    registerUseCase: mockRegisterUseCase,
    logoutUseCase: mockLogoutUseCase,
    getCurrentUserUseCase: mockGetCurrentUserUseCase,
    forgotPasswordUseCase: mockForgotPasswordUseCase,
    resendVerificationUseCase: mockResendVerificationUseCase,
    resetPasswordUseCase: mockResetPasswordUseCase,
    updateProfileUseCase: mockUpdateProfileUseCase,
    updateAvatarUseCase: mockUpdateAvatarUseCase,
    changePasswordUseCase: mockChangePasswordUseCase,
  );

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, const AuthInitial());
      bloc.close();
    });

    // --- Login ---
    group('AuthLoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoginLoading, AuthAuthenticated] on success',
        build: () {
          when(
            () => mockLoginUseCase(any()),
          ).thenAnswer((_) async => const Right(tUser));
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const AuthLoginRequested(
            email: 'test@test.com',
            password: 'password',
          ),
        ),
        expect: () => [
          const AuthLoginLoading(),
          const AuthAuthenticated(tUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoginLoading, AuthError] on failure',
        build: () {
          when(() => mockLoginUseCase(any())).thenAnswer(
            (_) async => const Left(ServerFailure('Invalid credentials')),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const AuthLoginRequested(email: 'test@test.com', password: 'wrong'),
        ),
        expect: () => [
          const AuthLoginLoading(),
          const AuthError('Invalid credentials'),
        ],
      );
    });

    // --- Register ---
    group('AuthRegisterRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthRegisterLoading, AuthRegistrationSuccess] on success',
        build: () {
          when(
            () => mockRegisterUseCase(any()),
          ).thenAnswer((_) async => const Right(tUser));
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const AuthRegisterRequested(
            email: 'test@test.com',
            password: 'password',
            name: 'Test',
          ),
        ),
        expect: () => [
          const AuthRegisterLoading(),
          const AuthRegistrationSuccess(tUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthRegisterLoading, AuthError] on failure',
        build: () {
          when(() => mockRegisterUseCase(any())).thenAnswer(
            (_) async => const Left(ServerFailure('Email already exists')),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const AuthRegisterRequested(
            email: 'test@test.com',
            password: 'password',
            name: 'Test',
          ),
        ),
        expect: () => [
          const AuthRegisterLoading(),
          const AuthError('Email already exists'),
        ],
      );
    });

    // --- Auth Check ---
    group('AuthCheckRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when session exists',
        build: () {
          when(
            () => mockGetCurrentUserUseCase(any()),
          ).thenAnswer((_) async => const Right(tUser));
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [const AuthLoading(), const AuthAuthenticated(tUser)],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when no session',
        build: () {
          when(
            () => mockGetCurrentUserUseCase(any()),
          ).thenAnswer((_) async => const Left(AuthFailure('Not logged in')));
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [const AuthLoading(), const AuthUnauthenticated()],
      );
    });

    // --- Logout ---
    group('AuthLogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] on success',
        build: () {
          when(
            () => mockLogoutUseCase(any()),
          ).thenAnswer((_) async => const Right(null));
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthLogoutRequested()),
        expect: () => [const AuthLoading(), const AuthUnauthenticated()],
      );
    });

    // --- Forgot Password ---
    group('AuthForgotPasswordRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthForgotPasswordLoading, AuthForgotPasswordSuccess] on success',
        build: () {
          when(
            () => mockForgotPasswordUseCase(any()),
          ).thenAnswer((_) async => const Right(null));
          return buildBloc();
        },
        act: (bloc) =>
            bloc.add(const AuthForgotPasswordRequested(email: 'test@test.com')),
        expect: () => [
          const AuthForgotPasswordLoading(),
          const AuthForgotPasswordSuccess(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthForgotPasswordLoading, AuthError] on failure',
        build: () {
          when(() => mockForgotPasswordUseCase(any())).thenAnswer(
            (_) async => const Left(ServerFailure('User not found')),
          );
          return buildBloc();
        },
        act: (bloc) =>
            bloc.add(const AuthForgotPasswordRequested(email: 'bad@test.com')),
        expect: () => [
          const AuthForgotPasswordLoading(),
          const AuthError('User not found'),
        ],
      );
    });

    // --- Reset Password ---
    group('AuthResetPasswordRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthResetPasswordLoading, AuthResetPasswordSuccess] on success',
        build: () {
          when(
            () => mockResetPasswordUseCase(any()),
          ).thenAnswer((_) async => const Right(null));
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const AuthResetPasswordRequested(
            token: 'token123',
            newPassword: 'newpass',
          ),
        ),
        expect: () => [
          const AuthResetPasswordLoading(),
          const AuthResetPasswordSuccess(),
        ],
      );
    });

    // --- User Updated ---
    group('AuthUserUpdated', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthAuthenticated] with updated user',
        build: buildBloc,
        act: (bloc) => bloc.add(const AuthUserUpdated(tUser)),
        expect: () => [const AuthAuthenticated(tUser)],
      );
    });

    // --- Update Profile ---
    group('AuthUpdateProfileRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on success',
        build: () {
          when(
            () => mockUpdateProfileUseCase(any()),
          ).thenAnswer((_) async => const Right(tUser));
          return buildBloc();
        },
        act: (bloc) =>
            bloc.add(const AuthUpdateProfileRequested(name: 'New Name')),
        expect: () => [const AuthLoading(), const AuthAuthenticated(tUser)],
      );
    });
  });
}

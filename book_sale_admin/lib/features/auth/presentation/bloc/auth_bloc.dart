import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final CheckAuthUseCase checkAuthUseCase;
  final LogoutUseCase logoutUseCase;
  final GetSavedUserUseCase getSavedUserUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.checkAuthUseCase,
    required this.logoutUseCase,
    required this.getSavedUserUseCase,
  }) : super(AuthInitial()) {
    on<CheckAuthEvent>(_onCheckAuth);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuth(
    CheckAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await checkAuthUseCase(NoParams());
    final hasToken = result.fold((_) => false, (v) => v);
    if (!hasToken) {
      emit(Unauthenticated());
      return;
    }
    // Restore saved user profile so name/avatar are available immediately
    final userResult = await getSavedUserUseCase(NoParams());
    final savedUser = userResult.fold((_) => null, (u) => u);
    emit(Authenticated(savedUser ?? const AdminUser()));
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold((failure) {
      String msg = failure.message;
      if (msg.startsWith('Exception: ')) {
        msg = msg.replaceFirst('Exception: ', '');
      }
      emit(AuthError(msg));
    }, (user) => emit(Authenticated(user)));
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await logoutUseCase(NoParams());
    emit(Unauthenticated());
  }
}

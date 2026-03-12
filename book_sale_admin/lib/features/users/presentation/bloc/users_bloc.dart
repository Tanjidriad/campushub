import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/user_usecases.dart';
import 'users_event.dart';
import 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetUsersUseCase getUsers;
  final ToggleBanUseCase toggleBan;
  final ChangeRoleUseCase changeRole;

  String? _lastSearch;
  String? _lastRole;
  String? _lastStatus;

  UsersBloc({
    required this.getUsers,
    required this.toggleBan,
    required this.changeRole,
  }) : super(UsersInitial()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<ToggleBanEvent>(_onToggleBan);
    on<ChangeRoleEvent>(_onChangeRole);
  }

  Future<void> _onLoadUsers(
    LoadUsersEvent event,
    Emitter<UsersState> emit,
  ) async {
    emit(UsersLoading());

    _lastSearch = event.search;
    _lastRole = event.role;
    _lastStatus = event.status;

    final result = await getUsers(
      GetUsersParams(
        search: event.search,
        role: event.role,
        status: event.status,
      ),
    );

    result.fold(
      (failure) => emit(UsersError(failure.message)),
      (response) =>
          emit(UsersLoaded(users: response.users, stats: response.stats)),
    );
  }

  Future<void> _onToggleBan(
    ToggleBanEvent event,
    Emitter<UsersState> emit,
  ) async {
    final result = await toggleBan(event.userId);

    result.fold((failure) => emit(UsersError(failure.message)), (_) {
      add(
        LoadUsersEvent(
          search: _lastSearch,
          role: _lastRole,
          status: _lastStatus,
        ),
      );
    });
  }

  Future<void> _onChangeRole(
    ChangeRoleEvent event,
    Emitter<UsersState> emit,
  ) async {
    final result = await changeRole(
      ChangeRoleParams(userId: event.userId, newRole: event.newRole),
    );

    result.fold((failure) => emit(UsersError(failure.message)), (_) {
      add(
        LoadUsersEvent(
          search: _lastSearch,
          role: _lastRole,
          status: _lastStatus,
        ),
      );
    });
  }
}

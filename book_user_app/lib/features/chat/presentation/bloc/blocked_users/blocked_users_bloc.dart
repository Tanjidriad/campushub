import 'package:book_user_app/core/usecases/usecase.dart';
import 'package:book_user_app/features/chat/domain/usecases/get_blocked_users_usecase.dart';
import 'package:book_user_app/features/chat/domain/usecases/unblock_user_usecase.dart';
import 'package:book_user_app/features/chat/presentation/bloc/blocked_users/blocked_users_event.dart';
import 'package:book_user_app/features/chat/presentation/bloc/blocked_users/blocked_users_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlockedUsersBloc extends Bloc<BlockedUsersEvent, BlockedUsersState> {
  final GetBlockedUsersUseCase getBlockedUsersUseCase;
  final UnblockUserUseCase unblockUserUseCase;

  BlockedUsersBloc({
    required this.getBlockedUsersUseCase,
    required this.unblockUserUseCase,
  }) : super(BlockedUsersInitial()) {
    on<FetchBlockedUsers>(_onFetchBlockedUsers);
    on<UnblockUserEvent>(_onUnblockUser);
  }

  Future<void> _onFetchBlockedUsers(
    FetchBlockedUsers event,
    Emitter<BlockedUsersState> emit,
  ) async {
    emit(BlockedUsersLoading());
    final result = await getBlockedUsersUseCase(NoParams());
    result.fold(
      (failure) => emit(BlockedUsersError(message: failure.message)),
      (users) => emit(BlockedUsersLoaded(blockedUsers: users)),
    );
  }

  Future<void> _onUnblockUser(
    UnblockUserEvent event,
    Emitter<BlockedUsersState> emit,
  ) async {
    // Keep reference to previous state to restore it if unblock fails
    final currentState = state;
    
    emit(BlockedUsersLoading());
    final result = await unblockUserUseCase(
      UnblockUserParams(userId: event.userId),
    );
    
    result.fold(
      (failure) {
        emit(BlockedUsersError(message: failure.message));
        if (currentState is BlockedUsersLoaded) {
          emit(currentState); // Restore list
        }
      },
      (_) {
        // First emit success to trigger listener (e.g. snackbar)
        emit(UnblockUserSuccess(unblockedUserId: event.userId));
        
        // Then update the list locally if we had it loaded previously to avoid refetching
        if (currentState is BlockedUsersLoaded) {
          final updatedList = currentState.blockedUsers
              .where((user) => user.id != event.userId)
              .toList();
          emit(BlockedUsersLoaded(blockedUsers: updatedList));
        } else {
           add(FetchBlockedUsers()); // fallback
        }
      },
    );
  }
}

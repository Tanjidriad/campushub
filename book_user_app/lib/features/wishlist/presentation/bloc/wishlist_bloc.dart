import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/add_to_wishlist_usecase.dart';
import '../../domain/usecases/get_wishlist_usecase.dart';
import '../../domain/usecases/remove_from_wishlist_usecase.dart';
import './wishlist_event.dart';
import './wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final GetWishlistUseCase getWishlist;
  final AddToWishlistUseCase addToWishlist;
  final RemoveFromWishlistUseCase removeFromWishlist;

  WishlistBloc({
    required this.getWishlist,
    required this.addToWishlist,
    required this.removeFromWishlist,
  }) : super(WishlistInitial()) {
    on<LoadWishlist>(_onLoadWishlist);
    on<AddToWishlist>(_onAddToWishlist);
    on<RemoveFromWishlist>(_onRemoveFromWishlist);
  }

  Future<void> _onLoadWishlist(
    LoadWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    emit(WishlistLoading());
    final result = await getWishlist(NoParams());
    result.fold(
      (failure) => emit(WishlistError(failure.message)),
      (wishlist) => emit(WishlistLoaded(wishlist)),
    );
  }

  Future<void> _onAddToWishlist(
    AddToWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    // Optimistic update or just success message? Let's just do operation success and then maybe reload?
    // Actually, usually we want to see the updated list or just a snackbar.
    // Let's emit a specific success state that UI can listen to, but keep the list loaded if possible.
    // However, Bloc state is single. If we emit OperationSuccess, we lose the list data if we don't include it.
    // For now, let's keep it simple: emit loading/result.
    // Better pattern: The Bloc that has the list should probably just update the list locally if possible, or reload.

    // Let's try to keep the current list if we are in Loaded state?
    // For simplicity start, just emit success and let UI trigger reload if needed or just show snackbar.
    // But wait, if I am in the Wishlist Page, I want to see the item removed immediately.

    final result = await addToWishlist(event.listingId);
    result.fold((failure) => emit(WishlistError(failure.message)), (_) {
      emit(const WishlistOperationSuccess('Added to wishlist'));
      add(LoadWishlist()); // Reload to get fresh data
    });
  }

  Future<void> _onRemoveFromWishlist(
    RemoveFromWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    // Optimistic update: immediately remove the item from the list so the UI
    // doesn't transition through WishlistOperationSuccess → empty state → loading,
    // which unmounts the ListView mid-render and causes a crash.
    if (state is WishlistLoaded) {
      final updatedList = (state as WishlistLoaded).wishlist
          .where((item) => item.id != event.listingId)
          .toList();
      emit(WishlistLoaded(updatedList));
    }

    final result = await removeFromWishlist(event.listingId);
    result.fold(
      (failure) {
        // On failure, reload the list to restore the removed item.
        emit(WishlistError(failure.message));
        add(LoadWishlist());
      },
      (_) {
        // Success — list was already updated optimistically, nothing more to do.
      },
    );
  }
}

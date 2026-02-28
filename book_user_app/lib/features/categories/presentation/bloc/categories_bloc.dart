import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_user_app/core/usecases/usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import 'categories_event.dart';
import 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final GetCategoriesUseCase _getCategoriesUseCase;

  CategoriesBloc({required GetCategoriesUseCase getCategoriesUseCase})
    : _getCategoriesUseCase = getCategoriesUseCase,
      super(const CategoriesInitial()) {
    on<CategoriesLoadRequested>(_onLoadRequested);
    on<CategoriesRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    CategoriesLoadRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    // Don't reload if already loaded
    if (state is CategoriesLoaded) return;

    emit(const CategoriesLoading());

    final result = await _getCategoriesUseCase(NoParams());

    result.fold(
      (failure) => emit(CategoriesError(message: failure.message)),
      (categories) => emit(CategoriesLoaded(categories: categories)),
    );
  }

  Future<void> _onRefreshRequested(
    CategoriesRefreshRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    final result = await _getCategoriesUseCase(NoParams());

    result.fold(
      (failure) => emit(CategoriesError(message: failure.message)),
      (categories) => emit(CategoriesLoaded(categories: categories)),
    );
  }
}

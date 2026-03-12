import 'package:book_sale_admin/core/usecases/usecase.dart';
import 'package:book_sale_admin/features/category_config/domain/usecases/listing_category_usecases.dart';
import 'package:book_sale_admin/features/category_config/domain/entities/category.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/category_usecases.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetConfig getConfig;
  final SaveConfig saveConfig;
  final GetCategories getCategories;
  final CreateListingCategory createCategory;
  final UpdateListingCategory updateCategory;
  final DeleteListingCategory deleteCategory;
  final ToggleListingCategoryStatus toggleStatus;

  CategoryBloc({
    required this.getConfig,
    required this.saveConfig,
    required this.getCategories,
    required this.createCategory,
    required this.updateCategory,
    required this.deleteCategory,
    required this.toggleStatus,
  }) : super(CategoryInitial()) {
    on<LoadConfigEvent>(_onLoadConfig);
    on<SaveConfigEvent>(_onSaveConfig);
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<CreateCategoryEvent>(_onCreateCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<ToggleCategoryStatusEvent>(_onToggleStatus);
  }

  Future<void> _onLoadConfig(
    LoadConfigEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    final result = await getConfig(NoParams());
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (config) => emit(CategoryLoaded(config: config)),
    );
  }

  Future<void> _onSaveConfig(
    SaveConfigEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategorySaving());
    final result = await saveConfig(event.config);
    result.fold((failure) => emit(CategoryError(failure.message)), (_) {
      emit(CategorySaved());
      add(LoadConfigEvent());
    });
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is CategoryLoaded) {
      emit(currentState.copyWith(isCategoriesLoading: true));
    }

    final result = await getCategories(event.includeInactive);

    // We must handle the async reload path outside fold() to keep await in scope.
    List<Category>? categoriesToReload;

    result.fold(
      (failure) {
        if (state is CategoryLoaded) {
          emit(
            (state as CategoryLoaded).copyWith(
              isCategoriesLoading: false,
              categoryError: failure.message,
            ),
          );
        } else {
          emit(CategoryError(failure.message));
        }
      },
      (categories) {
        if (state is CategoryLoaded) {
          emit(
            (state as CategoryLoaded).copyWith(
              categories: categories,
              isCategoriesLoading: false,
            ),
          );
        } else {
          // State is not CategoryLoaded (e.g. after CRUD action).
          // Defer the async reload to after fold completes so we can await it.
          categoriesToReload = categories;
        }
      },
    );

    // Reload config + emit outside fold so we can properly await
    if (categoriesToReload != null) {
      final configResult = await getConfig(NoParams());
      configResult.fold(
        (failure) => emit(CategoryError(failure.message)),
        (config) => emit(
          CategoryLoaded(config: config, categories: categoriesToReload!),
        ),
      );
    }
  }

  Future<void> _onCreateCategory(
    CreateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final result = await createCategory(
      CreateCategoryParams(
        name: event.name,
        description: event.description,
        icon: event.icon,
        displayOrder: event.displayOrder,
        imageBytes: event.imageBytes,
        hasEducationConfig: event.hasEducationConfig,
      ),
    );

    result.fold((failure) => emit(CategoryError(failure.message)), (_) {
      emit(const CategoryActionSuccess('Category created successfully'));
      add(const LoadCategoriesEvent());
    });
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final result = await updateCategory(
      UpdateCategoryParams(
        id: event.id,
        name: event.name,
        description: event.description,
        icon: event.icon,
        displayOrder: event.displayOrder,
        imageBytes: event.imageBytes,
        hasEducationConfig: event.hasEducationConfig,
      ),
    );

    result.fold((failure) => emit(CategoryError(failure.message)), (_) {
      final currentState = state;
      if (currentState is CategoryLoaded) {
        emit(const CategoryActionSuccess('Category updated successfully'));
        add(const LoadCategoriesEvent());
      }
    });
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final result = await deleteCategory(event.id);
    result.fold((failure) => emit(CategoryError(failure.message)), (_) {
      emit(const CategoryActionSuccess('Category deleted successfully'));
      add(const LoadCategoriesEvent());
    });
  }

  Future<void> _onToggleStatus(
    ToggleCategoryStatusEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final result = await toggleStatus(event.id);
    result.fold((failure) => emit(CategoryError(failure.message)), (_) {
      emit(const CategoryActionSuccess('Status updated successfully'));
      add(const LoadCategoriesEvent());
    });
  }
}

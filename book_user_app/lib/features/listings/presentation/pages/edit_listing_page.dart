import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/app_snackbar.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_event.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_state.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:book_user_app/core/widgets/app_loader.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:book_user_app/core/services/education_config_service.dart';
import 'package:book_user_app/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:book_user_app/features/categories/presentation/bloc/categories_event.dart';
import 'package:cached_network_image/cached_network_image.dart';


class EditListingPage extends StatefulWidget {
  final Listing listing;

  const EditListingPage({super.key, required this.listing});

  @override
  State<EditListingPage> createState() => _EditListingPageState();
}

class _EditListingPageState extends State<EditListingPage> {
  late final ListingsBloc _listingsBloc;
  final _formKey = GlobalKey<FormState>();

  late Listing _currentListing;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  String? _selectedCategory;
  String? _selectedCondition;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Textbooks',
    'Electronics',
    'Furniture',
    'Clothing',
    'Sports',
    'Music',
    'Art',
    'Other',
  ];
  final List<String> _conditions = ['new', 'like_new', 'good', 'fair', 'poor'];

  // Education fields (dynamic from API)
  String? _selectedEducationLevel;
  String? _selectedClassOrSemester;
  String? _selectedBookType;
  late TextEditingController _subjectController;
  final _configService = EducationConfigService();
  EducationConfig? _eduConfig;

  List<EducationLevel> get _educationLevels =>
      (_eduConfig ?? EducationConfig.fallback).levels;

  List<BookType> get _bookTypes =>
      (_eduConfig ?? EducationConfig.fallback).bookTypes;

  List<String> get _classOrSemesterOptions {
    if (_selectedEducationLevel == null) return [];
    final config = _eduConfig ?? EducationConfig.fallback;
    final level = config.levels
        .where((l) => l.key == _selectedEducationLevel)
        .toList();
    if (level.isEmpty) return [];
    return level.first.subLevels.map((s) => s.label).toList();
  }

  @override
  void initState() {
    super.initState();
    _currentListing = widget.listing;
    _loadConfig();
    sl<CategoriesBloc>().add(const CategoriesLoadRequested());

    _listingsBloc = sl<ListingsBloc>();

    _titleController = TextEditingController(text: _currentListing.title);
    _descriptionController = TextEditingController(
      text: _currentListing.description,
    );
    _priceController = TextEditingController(
      text: _currentListing.price?.toString() ?? '',
    );
    _subjectController = TextEditingController(
      text: _currentListing.subject ?? '',
    );
    _selectedEducationLevel = _currentListing.educationLevel;
    _selectedClassOrSemester = _currentListing.classOrSemester;
    _selectedBookType = _currentListing.bookType;

    final matchingCategories = _categories
        .where((c) => c.toLowerCase() == _currentListing.category.toLowerCase())
        .toList();
    _selectedCategory = matchingCategories.isNotEmpty
        ? matchingCategories.first
        : 'Other';

    // Best effort mapping of condition
    final c = _currentListing.condition.toLowerCase();
    _selectedCondition = _conditions.contains(c) ? c : 'good';
  }

  Future<void> _loadConfig() async {
    final config = await _configService.fetchConfig();
    if (mounted) setState(() => _eduConfig = config);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_isSubmitting) return;
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      final title = _titleController.text != _currentListing.title
          ? _titleController.text
          : null;
      final description =
          _descriptionController.text != _currentListing.description
          ? _descriptionController.text
          : null;
      final category = _selectedCategory != _currentListing.category
          ? _selectedCategory
          : null;

      final currentConditionFormatted =
          _conditions.contains(_currentListing.condition.toLowerCase())
          ? _currentListing.condition.toLowerCase()
          : 'good';
      final condition = _selectedCondition != currentConditionFormatted
          ? _selectedCondition
          : null;

      final currentPriceString = _currentListing.price?.toString() ?? '';
      final priceStr = _priceController.text;
      final price = priceStr != currentPriceString
          ? double.tryParse(priceStr)
          : null;

      final educationLevel =
          _selectedEducationLevel != _currentListing.educationLevel
          ? _selectedEducationLevel
          : null;
      final classOrSemester =
          _selectedClassOrSemester != _currentListing.classOrSemester
          ? _selectedClassOrSemester
          : null;
      final bookType = _selectedBookType != _currentListing.bookType
          ? _selectedBookType
          : null;
      final subjectStr =
          _subjectController.text != (_currentListing.subject ?? '')
          ? _subjectController.text
          : null;

      // Only send if there are actual changes
      if (title == null &&
          description == null &&
          category == null &&
          condition == null &&
          price == null &&
          educationLevel == null &&
          classOrSemester == null &&
          bookType == null &&
          subjectStr == null) {
        setState(() => _isSubmitting = false);
        Navigator.pop(context);
        return;
      }

      _listingsBloc.add(
        ListingUpdateRequested(
          listingId: _currentListing.id,
          title: title,
          description: description,
          category: category,
          condition: condition,
          priceType: 'fixed',
          price: price,
          educationLevel: educationLevel,
          classOrSemester: classOrSemester,
          bookType: bookType,
          subject: subjectStr,
        ),
      );
    }
  }

  String _formatCondition(String condition) {
    if (condition == 'like_new') return 'Like New';
    return condition[0].toUpperCase() + condition.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => _listingsBloc),
        BlocProvider.value(value: sl<CategoriesBloc>()),
      ],
      child: HeroMode(
        enabled: false,
        child: BlocConsumer<ListingsBloc, ListingsState>(
          listener: (context, state) {
            if (!mounted) return;
            final l10n = AppLocalizations.of(context)!;
            if (state is ListingUpdated) {
              final isPending = state.listing.status == 'pending';
              final currentStatus = state.listing.status;

              if (isPending || currentStatus == 'pending') {
                AppSnackBar.showWarning(context, l10n.listingUpdatedPending);
              } else {
                AppSnackBar.showSuccess(context, l10n.listingUpdatedSuccess);
              }
              Navigator.pop(context, true);
            } else if (state is ListingImageDeleted) {
              setState(() {
                _currentListing = state.listing;
                _isSubmitting = false;
              });
              AppSnackBar.showSuccess(context, 'Image deleted successfully');
            } else if (state is ListingImageDeleting) {
              setState(() => _isSubmitting = true);
            } else if (state is ListingsError) {
              setState(() => _isSubmitting = false);
              AppSnackBar.showError(context, state.message);
            }
          },
          builder: (context, state) {
            final l10n = AppLocalizations.of(context)!;
            return PopScope(
              canPop: !_isSubmitting,
              child: Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: !_isSubmitting,
                  title: Text(l10n.editListing),
                  backgroundColor: AppColors.of(context).background,
                  elevation: 0,
                  iconTheme: IconThemeData(
                    color: AppColors.of(context).textPrimary,
                  ),
                  titleTextStyle: TextStyle(
                    color: AppColors.of(context).textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: AppColors.of(context).subtleFill,
                body: state is ListingUpdating || state is ListingImageDeleting
                    ? const Center(child: AppLoaderFullPage())
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(16.w),
                        child: Form(
                          key: _formKey,
                          child: Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: AppColors.of(context).card,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_currentListing.images.isNotEmpty) ...[
                                  Text(
                                    'Existing Images',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  SizedBox(
                                    height: 120.h,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _currentListing.images.length,
                                      separatorBuilder: (context, index) =>
                                          SizedBox(width: 12.w),
                                      itemBuilder: (context, index) {
                                        final image = _currentListing.images[index];
                                        return Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(12.r),
                                              child: CachedNetworkImage(
                                                imageUrl: image.url,
                                                height: 120.h,
                                                width: 120.h,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) => Container(
                                                  height: 120.h,
                                                  width: 120.h,
                                                  color: AppColors.of(context).border,
                                                  child: const Center(child: CircularProgressIndicator()),
                                                ),
                                                errorWidget: (context, url, error) => Container(
                                                  height: 120.h,
                                                  width: 120.h,
                                                  color: AppColors.of(context).border,
                                                  child: const Icon(Icons.error),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 4.h,
                                              right: 4.w,
                                              child: InkWell(
                                                onTap: () {
                                                  _listingsBloc.add(
                                                    ListingImageDeleteRequested(
                                                      listingId: _currentListing.id,
                                                      imageId: image.publicId,
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(4.w),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black54,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 16.sp,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 32.h),
                                ],
                                Text(
                                  l10n.basicInfo,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                TextFormField(
                                  controller: _titleController,
                                  decoration: InputDecoration(
                                    labelText: l10n.title,
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? l10n.titleRequired
                                      : null,
                                ),
                                SizedBox(height: 16.h),
                                TextFormField(
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: l10n.price,
                                    border: OutlineInputBorder(),
                                    prefixText: '\$',
                                  ),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? l10n.priceRequired
                                      : null,
                                ),
                                SizedBox(height: 16.h),
                                DropdownButtonFormField<String>(
                                  value: _selectedCategory,
                                  decoration: InputDecoration(
                                    labelText: l10n.category,
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _categories
                                      .map(
                                        (c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(c),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) {
                                    setState(() {
                                      _selectedCategory = v;
                                      if (v?.toLowerCase() != 'textbooks') {
                                        _selectedEducationLevel = null;
                                        _selectedClassOrSemester = null;
                                        _selectedBookType = null;
                                        _subjectController.clear();
                                      }
                                    });
                                  },
                                  validator: (value) => value == null
                                      ? l10n.categoryRequired
                                      : null,
                                ),
                                SizedBox(height: 16.h),
                                DropdownButtonFormField<String>(
                                  value: _selectedCondition,
                                  decoration: InputDecoration(
                                    labelText: l10n.condition,
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _conditions
                                      .map(
                                        (c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(_formatCondition(c)),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedCondition = v),
                                  validator: (value) => value == null
                                      ? l10n.conditionRequired
                                      : null,
                                ),
                                SizedBox(height: 16.h),
                                TextFormField(
                                  controller: _descriptionController,
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    labelText: l10n.description,
                                    border: OutlineInputBorder(),
                                    alignLabelWithHint: true,
                                  ),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? l10n.descriptionRequired
                                      : null,
                                ),
                                if (_selectedCategory?.toLowerCase() ==
                                    'textbooks') ...[
                                  SizedBox(height: 32.h),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.menu_book_rounded,
                                              size: 20.sp,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              l10n.bookDetails,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          l10n.bookDetailsSubtitle,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.of(
                                                  context,
                                                ).textSecondary,
                                              ),
                                        ),
                                        SizedBox(height: 16.h),

                                        // Education Level
                                        Text(
                                          l10n.educationLevel,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Wrap(
                                          spacing: 8.w,
                                          runSpacing: 8.h,
                                          children: _educationLevels.map((
                                            level,
                                          ) {
                                            final isSelected =
                                                _selectedEducationLevel ==
                                                level.key;
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedEducationLevel =
                                                      level.key;
                                                  _selectedClassOrSemester =
                                                      null;
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 16.w,
                                                  vertical: 8.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? Theme.of(
                                                          context,
                                                        ).colorScheme.primary
                                                      : AppColors.of(
                                                          context,
                                                        ).surface,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        999,
                                                      ),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? Theme.of(
                                                            context,
                                                          ).colorScheme.primary
                                                        : AppColors.of(
                                                            context,
                                                          ).border,
                                                  ),
                                                ),
                                                child: Text(
                                                  level.label,
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: isSelected
                                                        ? AppColors.of(
                                                            context,
                                                          ).onPrimary
                                                        : Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.color,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),

                                        // Class / Semester
                                        if (_selectedEducationLevel != null &&
                                            _classOrSemesterOptions
                                                .isNotEmpty) ...[
                                          SizedBox(height: 16.h),
                                          Text(
                                            _selectedEducationLevel ==
                                                    'university'
                                                ? l10n.semester
                                                : l10n.classLabel,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          SizedBox(height: 8.h),
                                          Wrap(
                                            spacing: 8.w,
                                            runSpacing: 8.h,
                                            children: _classOrSemesterOptions.map(
                                              (opt) {
                                                final isSelected =
                                                    _selectedClassOrSemester ==
                                                    opt;
                                                return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedClassOrSemester =
                                                          opt;
                                                    });
                                                  },
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 14.w,
                                                          vertical: 7.h,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? Theme.of(context)
                                                                .colorScheme
                                                                .primary
                                                          : AppColors.of(
                                                              context,
                                                            ).surface,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            999,
                                                          ),
                                                      border: Border.all(
                                                        color: isSelected
                                                            ? Theme.of(context)
                                                                  .colorScheme
                                                                  .primary
                                                            : AppColors.of(
                                                                context,
                                                              ).border,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      opt,
                                                      style: TextStyle(
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: isSelected
                                                            ? AppColors.of(
                                                                context,
                                                              ).onPrimary
                                                            : Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.color,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ).toList(),
                                          ),
                                        ],

                                        // Subject
                                        SizedBox(height: 16.h),
                                        Text(
                                          l10n.subjectOptional,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        SizedBox(height: 8.h),
                                        TextField(
                                          controller: _subjectController,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          decoration: InputDecoration(
                                            hintText: l10n.subjectHint,
                                            hintStyle: TextStyle(
                                              color: AppColors.of(
                                                context,
                                              ).textLight,
                                            ),
                                            filled: true,
                                            fillColor: AppColors.of(
                                              context,
                                            ).surface,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              borderSide: BorderSide(
                                                color: AppColors.of(
                                                  context,
                                                ).border,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              borderSide: BorderSide(
                                                color: AppColors.of(
                                                  context,
                                                ).border,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              borderSide: BorderSide(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Book Type
                                        SizedBox(height: 16.h),
                                        Text(
                                          l10n.bookType,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Wrap(
                                          spacing: 8.w,
                                          runSpacing: 8.h,
                                          children: _bookTypes.map((bt) {
                                            final isSelected =
                                                _selectedBookType == bt.key;
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedBookType = bt.key;
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 14.w,
                                                  vertical: 7.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? Theme.of(
                                                          context,
                                                        ).colorScheme.primary
                                                      : AppColors.of(
                                                          context,
                                                        ).surface,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        999,
                                                      ),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? Theme.of(
                                                            context,
                                                          ).colorScheme.primary
                                                        : AppColors.of(
                                                            context,
                                                          ).border,
                                                  ),
                                                ),
                                                child: Text(
                                                  bt.label,
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: isSelected
                                                        ? AppColors.of(
                                                            context,
                                                          ).onPrimary
                                                        : Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.color,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                SizedBox(height: 32.h),
                                ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.of(
                                      context,
                                    ).accent,
                                    foregroundColor: AppColors.of(
                                      context,
                                    ).onPrimary,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.saveChanges,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}

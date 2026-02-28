import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_event.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_state.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:book_user_app/core/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class EditListingPage extends StatefulWidget {
  final Listing listing;

  const EditListingPage({super.key, required this.listing});

  @override
  State<EditListingPage> createState() => _EditListingPageState();
}

class _EditListingPageState extends State<EditListingPage> {
  late final ListingsBloc _listingsBloc;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  String? _selectedCategory;
  String? _selectedCondition;

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

  @override
  void initState() {
    super.initState();
    _listingsBloc = sl<ListingsBloc>();

    _titleController = TextEditingController(text: widget.listing.title);
    _descriptionController = TextEditingController(
      text: widget.listing.description,
    );
    _priceController = TextEditingController(
      text: widget.listing.price?.toString() ?? '',
    );

    final matchingCategories = _categories
        .where((c) => c.toLowerCase() == widget.listing.category.toLowerCase())
        .toList();
    _selectedCategory = matchingCategories.isNotEmpty
        ? matchingCategories.first
        : 'Other';

    // Best effort mapping of condition
    final c = widget.listing.condition.toLowerCase();
    _selectedCondition = _conditions.contains(c) ? c : 'good';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _listingsBloc.close();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text != widget.listing.title
          ? _titleController.text
          : null;
      final description =
          _descriptionController.text != widget.listing.description
          ? _descriptionController.text
          : null;
      final category = _selectedCategory != widget.listing.category
          ? _selectedCategory
          : null;

      final currentConditionFormatted =
          _conditions.contains(widget.listing.condition.toLowerCase())
          ? widget.listing.condition.toLowerCase()
          : 'good';
      final condition = _selectedCondition != currentConditionFormatted
          ? _selectedCondition
          : null;

      final currentPriceString = widget.listing.price?.toString() ?? '';
      final priceStr = _priceController.text;
      final price = priceStr != currentPriceString
          ? double.tryParse(priceStr)
          : null;

      // Only send if there are actual changes
      if (title == null &&
          description == null &&
          category == null &&
          condition == null &&
          price == null) {
        context.pop();
        return;
      }

      _listingsBloc.add(
        ListingUpdateRequested(
          listingId: widget.listing.id,
          title: title,
          description: description,
          category: category,
          condition: condition,
          priceType: 'fixed',
          price: price,
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
    return BlocProvider.value(
      value: _listingsBloc,
      child: BlocConsumer<ListingsBloc, ListingsState>(
        listener: (context, state) {
          if (state is ListingUpdated) {
            final isPending = state.listing.status == 'pending';
            final currentStatus = state.listing.status;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isPending || currentStatus == 'pending'
                      ? 'Listing updated. It is now pending admin approval.'
                      : 'Listing updated successfully',
                ),
                backgroundColor: isPending ? Colors.orange : Colors.green,
                duration: const Duration(seconds: 4),
              ),
            );
            context.pop();
          } else if (state is ListingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Edit Listing'),
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: const Color(0xFFF6F7F8),
            body: state is ListingUpdating
                ? const Center(child: AppLoaderFullPage())
                : SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Form(
                      key: _formKey,
                      child: Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Basic Info',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Title',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Please enter a title'
                                  : null,
                            ),
                            SizedBox(height: 16.h),
                            TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Price',
                                border: OutlineInputBorder(),
                                prefixText: '\$',
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Please enter a price'
                                  : null,
                            ),
                            SizedBox(height: 16.h),
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Category',
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
                              onChanged: (v) =>
                                  setState(() => _selectedCategory = v),
                              validator: (value) => value == null
                                  ? 'Please select a category'
                                  : null,
                            ),
                            SizedBox(height: 16.h),
                            DropdownButtonFormField<String>(
                              value: _selectedCondition,
                              decoration: const InputDecoration(
                                labelText: 'Condition',
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
                                  ? 'Please select a condition'
                                  : null,
                            ),
                            SizedBox(height: 16.h),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true,
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Please enter a description'
                                  : null,
                            ),
                            SizedBox(height: 32.h),
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4794E6),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                'Save Changes',
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
          );
        },
      ),
    );
  }
}

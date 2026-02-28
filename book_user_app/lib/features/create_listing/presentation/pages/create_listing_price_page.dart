// ignore_for_file: deprecated_member_use

import 'package:book_user_app/features/create_listing/presentation/pages/listing_confirmation_page.dart';
import 'package:book_user_app/core/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/create_listing_bloc.dart';

class CreateListingPricePage extends StatefulWidget {
  const CreateListingPricePage({super.key});

  @override
  State<CreateListingPricePage> createState() => _CreateListingPricePageState();
}

class _CreateListingPricePageState extends State<CreateListingPricePage> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isOpenToOffers = true;

  @override
  void initState() {
    super.initState();
    _locationController.text = '';
  }

  @override
  void dispose() {
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: CircleAvatar(
                      radius: 20.r,
                      backgroundColor: isDark
                          ? Colors.grey[800]
                          : Colors.grey[200],
                      child: Icon(
                        Icons.arrow_back,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Create Listing',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 40.w), // Balance back button
                ],
              ),
            ),

            // Progress Indicators
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildProgressDot(
                    isActive: false,
                    isCompleted: true,
                    theme: theme,
                  ),
                  SizedBox(width: 8.w),
                  _buildProgressDot(
                    isActive: false,
                    isCompleted: true,
                    theme: theme,
                  ),
                  SizedBox(width: 8.w),
                  _buildProgressDot(
                    isActive: true,
                    isCompleted: false,
                    theme: theme,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
                    Text(
                      'Price & Pickup',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Set a fair price and choose a safe meeting spot on campus.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                        fontSize: 16.sp,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Price Input
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isDark ? Colors.grey[800]! : Colors.grey[100]!,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PRICE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.2,
                                  ),
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '\$',
                                  style: TextStyle(
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _priceController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 48.sp,
                                      fontWeight: FontWeight.w800,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '0',
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Open to offers?',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Allow buyers to suggest a price',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _isOpenToOffers,
                                onChanged: (val) {
                                  setState(() {
                                    _isOpenToOffers = val;
                                  });
                                },
                                activeColor: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    Text(
                      'Meeting Spot',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Safety Tip
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8.r),
                          bottomRight: Radius.circular(8.r),
                        ),
                        border: Border(
                          left: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 4,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.security,
                            color: theme.colorScheme.primary,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Safety Tip',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                Text(
                                  'Meet in public areas like the Student Union or Library. Avoid dorm rooms.',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Location Input
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.location_on_outlined,
                          color: Colors.grey,
                        ),
                        hintText: 'Enter pickup location',
                        filled: true,
                        fillColor: theme.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.grey[700]!
                                : Colors.grey[200]!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.grey[700]!
                                : Colors.grey[200]!,
                          ),
                        ),
                      ),
                      style: theme.textTheme.bodyMedium,
                    ),

                    SizedBox(height: 12.h),

                    // Suggested locations
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        _buildLocationChip('Campus Library', theme),
                        _buildLocationChip('Student Center', theme),
                        _buildLocationChip('Main Gate', theme),
                        _buildLocationChip('Cafeteria', theme),
                      ],
                    ),

                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          bottom: 32.h,
          top: 16.h,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.95),
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 56.h,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    backgroundColor: isDark
                        ? Colors.grey[800]
                        : Colors.grey[100],
                    foregroundColor: theme.textTheme.bodyLarge?.color,
                    side: BorderSide.none,
                  ),
                  child: const Text(
                    "Back",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 56.h,
                child: BlocConsumer<CreateListingBloc, CreateListingState>(
                  listener: (context, state) {
                    if (state is CreateListingSuccess) {
                      // Navigate to confirmation page
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ListingConfirmationPage(),
                        ),
                      );
                    } else if (state is CreateListingFailure) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.message)));
                    }
                  },
                  builder: (context, state) {
                    if (state is CreateListingSubmitting) {
                      return const Center(child: AppLoaderFullPage());
                    }

                    return ElevatedButton(
                      onPressed: () {
                        if (_priceController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a price'),
                            ),
                          );
                          return;
                        }

                        final price = double.tryParse(_priceController.text);
                        if (price == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid price')),
                          );
                          return;
                        }

                        // Dispatch price update
                        context.read<CreateListingBloc>().add(
                          PriceUpdated(
                            price: price,
                            priceType: _isOpenToOffers ? 'negotiable' : 'fixed',
                            isOpenToOffers: _isOpenToOffers,
                            locationName: _locationController.text.isNotEmpty
                                ? _locationController.text
                                : 'Not specified',
                            meetupPreferences:
                                'campus', // Default to campus meetup
                          ),
                        );

                        // Trigger submission
                        context.read<CreateListingBloc>().add(
                          const SubmitListing(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 4,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Publish Listing",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDot({
    required bool isActive,
    required bool isCompleted,
    required ThemeData theme,
  }) {
    // 3 Dots logic: Completed=Light Grey, Active=Primary, Pending=Light Grey
    // Actually the design shows: Grey, Grey, Primary. (So previous steps are Grey? or maybe completed steps should be Primary too? The HTML shows:
    // <div class="h-1.5 w-8 rounded-full bg-[#d1dbe6]"></div>
    // <div class="h-1.5 w-8 rounded-full bg-[#d1dbe6]"></div>
    // <div class="h-1.5 w-8 rounded-full bg-primary"></div>
    // This implies Step 3 (active) has color, others don't.
    // But usually filled means done. Let's follow HTML: Active is Primary.

    Color color;
    if (isActive) {
      color = theme.colorScheme.primary;
    } else {
      color = theme.brightness == Brightness.dark
          ? Colors.grey[700]!
          : const Color(0xFFD1DBE6);
    }

    return Container(
      width: 32.w,
      height: 6.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  Widget _buildLocationChip(String label, ThemeData theme) {
    final isSelected = _locationController.text == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _locationController.text = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (theme.brightness == Brightness.dark
                      ? Colors.grey[700]!
                      : Colors.grey[200]!),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 14.sp,
              color: isSelected ? theme.colorScheme.primary : Colors.grey[500],
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : (theme.brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[600]),
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

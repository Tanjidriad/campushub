// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:book_user_app/config/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/create_listing_bloc.dart';

class CreateListingPhotosPage extends StatefulWidget {
  const CreateListingPhotosPage({super.key});

  @override
  State<CreateListingPhotosPage> createState() =>
      _CreateListingPhotosPageState();
}

class _CreateListingPhotosPageState extends State<CreateListingPhotosPage> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedPhotos = [];

  Future<void> _pickImage() async {
    // Pick multiple images
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      if (_selectedPhotos.length + images.length > 10) {
        // Show invalid snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can only upload up to 10 photos'),
            ),
          );
        }
        return;
      }
      setState(() {
        _selectedPhotos.addAll(images);
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  void _clearAll() {
    setState(() {
      _selectedPhotos.clear();
    });
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
            // TopAppBar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: SizedBox(
                      width: 48.w,
                      height: 48.w,
                      child: Icon(Icons.close, size: 24.sp),
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
                  GestureDetector(
                    onTap: () {
                      // Help action
                    },
                    child: SizedBox(
                      width: 48.w,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Help',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF507295),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Progress Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step 1 of 4',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '25% completed',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF507295),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 8.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[700]
                          : const Color(0xFFD1DBE6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.25,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
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
                    SizedBox(height: 24.h),
                    Text(
                      'Add Photos',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Upload up to 10 photos. Choose your best shot as the cover.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF507295),
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 16.h),
                    // Tip Banner
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? theme.colorScheme.primary.withOpacity(0.1)
                            : Colors.blue[50],
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isDark
                              ? theme.colorScheme.primary.withOpacity(0.2)
                              : Colors.blue[100]!,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: theme.colorScheme.primary,
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'QUICK TIP',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Good lighting helps items sell 50% faster! Try using natural light near a window.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 14.sp,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Main Cover Photo
                    if (_selectedPhotos.isNotEmpty)
                      Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 4 / 3,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.grey[700]!
                                      : Colors.grey[200]!,
                                ),
                                image: DecorationImage(
                                  image: FileImage(
                                    File(_selectedPhotos[0].path),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 12.h,
                            left: 12.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 12.sp,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Cover Photo',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 12.h,
                            right: 12.w,
                            child: GestureDetector(
                              onTap: () => _removePhoto(0),
                              child: Container(
                                width: 32.w,
                                height: 32.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? Colors.black.withOpacity(0.6)
                                      : Colors.white.withOpacity(0.9),
                                ),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 18.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      GestureDetector(
                        onTap: _pickImage,
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              color: isDark
                                  ? Colors.grey[800]
                                  : Colors.grey[100],
                              border: Border.all(
                                color: isDark
                                    ? Colors.grey[700]!
                                    : Colors.grey[200]!,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 48.sp,
                                  color: theme.colorScheme.primary,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "Add Cover Photo",
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    SizedBox(height: 12.h),

                    // Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12.w,
                        crossAxisSpacing: 12.w,
                      ),
                      itemCount: _selectedPhotos.length > 0
                          ? (_selectedPhotos.length - 1) + 1
                          : 1, // Photos excluding cover + Add button
                      itemBuilder: (context, index) {
                        // If we have selected photos, we skip the first one (cover)
                        // But we also need to show the "Add" button at the end

                        int actualIndex = index + 1; // Skip cover
                        bool isAddButton = false;

                        if (_selectedPhotos.isEmpty) {
                          // If empty, we already showed the big cover placeholder above.
                          // But usually we might want small placeholders?
                          // The design shows a grid below the cover.
                          // If cover is not set, maybe we hide grid?
                          return const SizedBox.shrink(); // Simplify for now
                        }

                        if (index >= _selectedPhotos.length - 1) {
                          isAddButton = true;
                        }

                        if (isAddButton) {
                          return GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                                color: theme.colorScheme.primary.withOpacity(
                                  0.05,
                                ),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.4,
                                  ),
                                  style: BorderStyle
                                      .values[1], // dash? No native dash in Border.all
                                ), // dashed border requires custom painter or package
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(6.w),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.add_a_photo,
                                      color: theme.colorScheme.primary,
                                      size: 20.sp,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Add More',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Actual photo
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                                image: DecorationImage(
                                  image: FileImage(
                                    File(_selectedPhotos[actualIndex].path),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4.h,
                              right: 4.w,
                              child: GestureDetector(
                                onTap: () => _removePhoto(actualIndex),
                                child: Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 12.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 100.h), // Space for footer
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
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedPhotos.length} photos selected',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                GestureDetector(
                  onTap: _clearAll,
                  child: Text(
                    'Clear All',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedPhotos.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select at least one photo'),
                      ),
                    );
                    return;
                  }

                  // Dispatch photos to BLoC
                  context.read<CreateListingBloc>().add(
                    PhotosSelected(
                      imagePaths: _selectedPhotos.map((e) => e.path).toList(),
                    ),
                  );

                  context.push(AppRouter.createListingDetails);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 4,
                  shadowColor: Colors.blue.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next: Details',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.arrow_forward, size: 18.sp),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

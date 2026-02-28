// ignore_for_file: deprecated_member_use

import 'package:book_user_app/config/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../bloc/create_listing_bloc.dart';

class CreateListingDetailsPage extends StatefulWidget {
  const CreateListingDetailsPage({super.key});

  @override
  State<CreateListingDetailsPage> createState() =>
      _CreateListingDetailsPageState();
}

class _CreateListingDetailsPageState extends State<CreateListingDetailsPage> {
  String? _selectedCategory;
  String _selectedCondition = 'good';
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  // Education fields
  String? _selectedEducationLevel;
  String? _selectedClassOrSemester;
  String? _selectedBookType;

  final List<Map<String, String>> _categories = [
    {'value': 'textbooks', 'label': 'Textbooks'},
    {'value': 'electronics', 'label': 'Electronics'},
    {'value': 'furniture', 'label': 'Dorm Furniture'},
    {'value': 'clothing', 'label': 'Clothing & Merch'},
    {'value': 'school_supplies', 'label': 'School Supplies'},
    {'value': 'other', 'label': 'Other'},
  ];

  final List<Map<String, dynamic>> _conditions = [
    {'value': 'new', 'label': 'New', 'icon': Icons.verified},
    {'value': 'like-new', 'label': 'Like New', 'icon': Icons.favorite},
    {'value': 'good', 'label': 'Good', 'icon': Icons.thumb_up},
    {'value': 'fair', 'label': 'Fair', 'icon': Icons.build},
  ];

  final List<Map<String, String>> _educationLevels = [
    {'value': 'school', 'label': 'School'},
    {'value': 'college', 'label': 'College'},
    {'value': 'university', 'label': 'University'},
    {'value': 'other', 'label': 'Other'},
  ];

  final List<Map<String, String>> _bookTypes = [
    {'value': 'nctb', 'label': 'NCTB'},
    {'value': 'guide', 'label': 'Guide'},
    {'value': 'reference', 'label': 'Reference'},
    {'value': 'university_textbook', 'label': 'Uni Book'},
    {'value': 'other', 'label': 'Other'},
  ];

  List<String> get _classOrSemesterOptions {
    switch (_selectedEducationLevel) {
      case 'school':
        return ['Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10'];
      case 'college':
        return ['HSC 1st Year', 'HSC 2nd Year'];
      case 'university':
        return List.generate(12, (i) => 'Semester ${i + 1}');
      default:
        return [];
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _titleController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor =
        isDark ? const Color(0xFF344155) : const Color(0xFFD1DBE6);
    final surfaceColor =
        isDark ? const Color(0xFF1A242F) : const Color(0xFFFFFFFF);

    final bool showBookFields =
        _selectedCategory == 'textbooks' ||
        _selectedCategory == 'school_supplies';

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
                    child: CircleAvatar(
                      radius: 20.r,
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                      child: Icon(
                        Icons.arrow_back,
                        color: theme.textTheme.bodyLarge?.color,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Add Details',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 40.w),
                ],
              ),
            ),

            // PageIndicators
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary
                              .withOpacity(isDark ? 0.2 : 0.3),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        width: 32.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: borderColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Step 2 of 3",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
                    Text(
                      'Item Information',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Fill in the details to help buyers find your item.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Category Field
                    Text(
                      'Category',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          hint: Text(
                            "Select a category",
                            style: TextStyle(
                              color: theme.disabledColor,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          isExpanded: true,
                          icon: Icon(Icons.expand_more, color: Colors.grey[500]),
                          items: _categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category['value'],
                              child: Text(category['label']!),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                              _selectedEducationLevel = null;
                              _selectedClassOrSemester = null;
                              _selectedBookType = null;
                            });
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Condition Field
                    Text(
                      'Condition',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.w,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _conditions.length,
                      itemBuilder: (context, index) {
                        final condition = _conditions[index];
                        final isSelected =
                            _selectedCondition == condition['value'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCondition =
                                  condition['value'] as String;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                      .withOpacity(isDark ? 0.2 : 0.1)
                                  : surfaceColor,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : borderColor,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  condition['icon'] as IconData,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : Colors.grey,
                                  size: 24.sp,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  condition['label'] as String,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 24.h),

                    // Title Field
                    Text(
                      'Title',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _titleController,
                      maxLength: 50,
                      decoration: InputDecoration(
                        hintText: "What are you selling?",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: surfaceColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide:
                              BorderSide(color: theme.colorScheme.primary),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Description Field
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Description',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '0/500',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            "Describe what you are selling (e.g., Author, Edition, specific flaws)...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: surfaceColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide:
                              BorderSide(color: theme.colorScheme.primary),
                        ),
                      ),
                    ),

                    // ── Book Details Section (textbooks / school_supplies) ────
                    if (showBookFields) ...[
                      SizedBox(height: 32.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary
                              .withOpacity(isDark ? 0.08 : 0.05),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.menu_book_rounded,
                                  size: 20.sp,
                                  color: theme.colorScheme.primary,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Book Details',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Help students find the right book for their level.',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                            SizedBox(height: 16.h),

                            // Education Level
                            Text(
                              'Education Level',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: _educationLevels.map((level) {
                                final isSelected =
                                    _selectedEducationLevel == level['value'];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedEducationLevel = level['value'];
                                      _selectedClassOrSemester = null;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : surfaceColor,
                                      borderRadius:
                                          BorderRadius.circular(999),
                                      border: Border.all(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : borderColor,
                                      ),
                                    ),
                                    child: Text(
                                      level['label']!,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white
                                            : theme
                                                .textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            // Class / Semester
                            if (_selectedEducationLevel != null &&
                                _classOrSemesterOptions.isNotEmpty) ...[
                              SizedBox(height: 16.h),
                              Text(
                                _selectedEducationLevel == 'university'
                                    ? 'Semester'
                                    : 'Class',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 8.h,
                                children: _classOrSemesterOptions.map((opt) {
                                  final isSelected =
                                      _selectedClassOrSemester == opt;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedClassOrSemester = opt;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14.w,
                                        vertical: 7.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : surfaceColor,
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        border: Border.all(
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                              : borderColor,
                                        ),
                                      ),
                                      child: Text(
                                        opt,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : theme
                                                  .textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],

                            // Subject
                            SizedBox(height: 16.h),
                            Text(
                              'Subject (optional)',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            TextField(
                              controller: _subjectController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                hintText:
                                    "e.g. Mathematics, Physics, Bengali...",
                                hintStyle:
                                    TextStyle(color: Colors.grey[400]),
                                filled: true,
                                fillColor: surfaceColor,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),

                            // Book Type
                            SizedBox(height: 16.h),
                            Text(
                              'Book Type',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: _bookTypes.map((bt) {
                                final isSelected =
                                    _selectedBookType == bt['value'];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedBookType = bt['value'];
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                      vertical: 7.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : surfaceColor,
                                      borderRadius:
                                          BorderRadius.circular(999),
                                      border: Border.all(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : borderColor,
                                      ),
                                    ),
                                    child: Text(
                                      bt['label']!,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white
                                            : theme
                                                .textTheme.bodyMedium?.color,
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

                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor.withOpacity(0.9),
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : borderColor.withOpacity(0.5),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () {
                if (_selectedCategory == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a category')),
                  );
                  return;
                }
                if (_titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a title')),
                  );
                  return;
                }
                if (_descriptionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a description'),
                    ),
                  );
                  return;
                }

                context.read<CreateListingBloc>().add(
                  DetailsUpdated(
                    title: _titleController.text,
                    category: _selectedCategory!,
                    condition: _selectedCondition,
                    description: _descriptionController.text,
                    educationLevel:
                        showBookFields ? _selectedEducationLevel : null,
                    classOrSemester:
                        showBookFields ? _selectedClassOrSemester : null,
                    subject: showBookFields &&
                            _subjectController.text.isNotEmpty
                        ? _subjectController.text
                        : null,
                    bookType: showBookFields ? _selectedBookType : null,
                  ),
                );

                context.push(AppRouter.createListingPrice);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 4,
                shadowColor: theme.colorScheme.primary.withOpacity(0.25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Next: Price & Pickup",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_forward, size: 20.sp),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

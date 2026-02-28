// ignore_for_file: deprecated_member_use
import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/features/report/domain/entities/report.dart';
import 'package:book_user_app/features/report/presentation/bloc/report_bloc.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

class ReportDialog extends StatefulWidget {
  final ReportTargetType targetType;
  final String targetId;
  final String? targetName;

  const ReportDialog({
    super.key,
    required this.targetType,
    required this.targetId,
    this.targetName,
  });

  static Future<void> show(
    BuildContext context, {
    required ReportTargetType targetType,
    required String targetId,
    String? targetName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReportDialog(
        targetType: targetType,
        targetId: targetId,
        targetName: targetName,
      ),
    );
  }

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  ReportReason? _selectedReason;
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<ReportReason> get _availableReasons {
    switch (widget.targetType) {
      case ReportTargetType.listing:
        return ReportReason.values;
      case ReportTargetType.user:
        return [
          ReportReason.spam,
          ReportReason.inappropriate,
          ReportReason.fraud,
          ReportReason.harassment,
          ReportReason.other,
        ];
      case ReportTargetType.message:
        return [
          ReportReason.spam,
          ReportReason.inappropriate,
          ReportReason.harassment,
          ReportReason.other,
        ];
    }
  }

  String get _title {
    switch (widget.targetType) {
      case ReportTargetType.listing:
        return 'Report Listing';
      case ReportTargetType.user:
        return 'Report User';
      case ReportTargetType.message:
        return 'Report Message';
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportBloc(repository: sl()),
      child: BlocConsumer<ReportBloc, ReportState>(
        listener: (context, state) {
          if (state is ReportSuccess) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8.w),
                    const Expanded(
                      child: Text(
                        'Report submitted. We\'ll review it shortly.',
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppPalette.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                margin: EdgeInsets.all(16.w),
              ),
            );
          } else if (state is ReportFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(child: Text(state.error)),
                  ],
                ),
                backgroundColor: AppPalette.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                margin: EdgeInsets.all(16.w),
              ),
            );
          }
        },
        builder: (context, state) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHandle(),
                  _buildHeader(),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.targetName != null) ...[
                            _buildTargetInfo(),
                            SizedBox(height: 16.h),
                          ],
                          _buildReasonSection(),
                          SizedBox(height: 20.h),
                          _buildDescriptionField(),
                          SizedBox(height: 24.h),
                          _buildSubmitButton(context, state),
                          SizedBox(
                            height:
                                MediaQuery.of(context).viewInsets.bottom + 20.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: AppPalette.gray400,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppPalette.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Iconsax.flag, color: AppPalette.error, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Help us keep the community safe',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppPalette.textLight,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppPalette.gray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 18.sp,
                color: AppPalette.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetInfo() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppPalette.gray50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppPalette.border),
      ),
      child: Row(
        children: [
          Icon(
            widget.targetType == ReportTargetType.user
                ? Iconsax.profile_circle
                : widget.targetType == ReportTargetType.listing
                ? Iconsax.book_1
                : Iconsax.message,
            size: 20.sp,
            color: AppPalette.textSecondary,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              widget.targetName!,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppPalette.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why are you reporting this?',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppPalette.textPrimary,
          ),
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _availableReasons.map((reason) {
            final isSelected = _selectedReason == reason;
            return GestureDetector(
              onTap: () => setState(() => _selectedReason = reason),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppPalette.error.withOpacity(0.08)
                      : AppPalette.gray50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected
                        ? AppPalette.error.withOpacity(0.4)
                        : AppPalette.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(reason.icon, style: TextStyle(fontSize: 14.sp)),
                    SizedBox(width: 6.w),
                    Text(
                      reason.label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? AppPalette.error
                            : AppPalette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Additional details',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppPalette.textPrimary,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              '(optional)',
              style: TextStyle(fontSize: 12.sp, color: AppPalette.textLight),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          maxLength: 500,
          style: TextStyle(fontSize: 14.sp, color: AppPalette.textPrimary),
          decoration: InputDecoration(
            hintText: 'Tell us more about the issue...',
            hintStyle: TextStyle(fontSize: 13.sp, color: AppPalette.textLight),
            filled: true,
            fillColor: AppPalette.gray50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: AppPalette.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: AppPalette.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: AppPalette.primary, width: 1.5),
            ),
            contentPadding: EdgeInsets.all(14.w),
            counterStyle: TextStyle(
              fontSize: 11.sp,
              color: AppPalette.textLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, ReportState state) {
    final isLoading = state is ReportLoading;
    final isEnabled = _selectedReason != null && !isLoading;

    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                context.read<ReportBloc>().add(
                  ReportSubmitted(
                    ReportParams(
                      targetType: widget.targetType,
                      targetId: widget.targetId,
                      reason: _selectedReason!,
                      description: _descriptionController.text.trim().isEmpty
                          ? null
                          : _descriptionController.text.trim(),
                    ),
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.error,
          disabledBackgroundColor: AppPalette.error.withOpacity(0.3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.flag, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Submit Report',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

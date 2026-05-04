// ignore_for_file: deprecated_member_use
import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/app_snackbar.dart';
import 'package:book_user_app/features/report/domain/entities/report.dart';
import 'package:book_user_app/features/report/presentation/bloc/report_bloc.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    switch (widget.targetType) {
      case ReportTargetType.listing:
        return l10n.reportListing;
      case ReportTargetType.user:
        return l10n.reportUser;
      case ReportTargetType.message:
        return l10n.reportMessage;
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
            final l10n = AppLocalizations.of(context)!;
            AppSnackBar.showSuccess(context, l10n.reportSubmittedSuccess);
          } else if (state is ReportFailure) {
            AppSnackBar.showError(context, state.error);
          }
        },
        builder: (context, state) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: AppColors.of(context).card,
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
          color: AppColors.of(context).textLight,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.of(context).error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Iconsax.flag,
              color: AppColors.of(context).error,
              size: 20.sp,
            ),
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
                    color: AppColors.of(context).textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  l10n.helpKeepCommunitySafe,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.of(context).textLight,
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
                color: AppColors.of(context).subtleFill,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 18.sp,
                color: AppColors.of(context).textSecondary,
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
        color: AppColors.of(context).subtleFill,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.of(context).border),
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
            color: AppColors.of(context).textSecondary,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              widget.targetName!,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.of(context).textPrimary,
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.whyReporting,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.of(context).textPrimary,
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
                      ? AppColors.of(context).error.withOpacity(0.08)
                      : AppColors.of(context).subtleFill,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.of(context).error.withOpacity(0.4)
                        : AppColors.of(context).border,
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
                            ? AppColors.of(context).error
                            : AppColors.of(context).textSecondary,
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.additionalDetails,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.of(context).textPrimary,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              l10n.optional,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.of(context).textLight,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          maxLength: 500,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.of(context).textPrimary,
          ),
          decoration: InputDecoration(
            hintText: l10n.tellUsMoreHint,
            hintStyle: TextStyle(
              fontSize: 13.sp,
              color: AppColors.of(context).textLight,
            ),
            filled: true,
            fillColor: AppColors.of(context).subtleFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: AppColors.of(context).border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: AppColors.of(context).border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(
                color: AppColors.of(context).primary,
                width: 1.5,
              ),
            ),
            contentPadding: EdgeInsets.all(14.w),
            counterStyle: TextStyle(
              fontSize: 11.sp,
              color: AppColors.of(context).textLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, ReportState state) {
    final l10n = AppLocalizations.of(context)!;
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
          backgroundColor: AppColors.of(context).error,
          disabledBackgroundColor: AppColors.of(context).error.withOpacity(0.3),
          foregroundColor: AppColors.of(context).onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.of(context).card,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.flag, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    l10n.submitReport,
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

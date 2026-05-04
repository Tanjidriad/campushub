import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool isObscure;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final bool enabled;
  final String? Function(String?)? validator;
  final int maxLines;

  const AuthTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    this.isObscure = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.enabled = true,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.of(context).textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(
          prefixIcon,
          color: AppColors.of(context).textSecondary,
          size: 22.sp,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.of(context).surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: AppColors.of(context).border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: AppColors.of(context).primary, width: 1.5),
        ),
      ),
    );
  }
}

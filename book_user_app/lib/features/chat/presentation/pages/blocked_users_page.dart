import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/app_snackbar.dart';
import 'package:book_user_app/features/chat/presentation/bloc/blocked_users/blocked_users_bloc.dart';
import 'package:book_user_app/features/chat/presentation/bloc/blocked_users/blocked_users_event.dart';
import 'package:book_user_app/features/chat/presentation/bloc/blocked_users/blocked_users_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../injection_container/injection_container.dart';

class BlockedUsersPage extends StatelessWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<BlockedUsersBloc>()..add(FetchBlockedUsers()),
      child: Scaffold(
        backgroundColor: AppColors.of(context).background,
        appBar: AppBar(
          backgroundColor: AppColors.of(context).background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 20.sp,
              color: AppColors.of(context).textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Blocked Users',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.of(context).textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<BlockedUsersBloc, BlockedUsersState>(
          listener: (context, state) {
            if (state is BlockedUsersError) {
              AppSnackBar.showError(context, state.message);
            } else if (state is UnblockUserSuccess) {
              AppSnackBar.showSuccess(
                context,
                'User unblocked successfully',
              );
            }
          },
          builder: (context, state) {
            if (state is BlockedUsersLoading || state is BlockedUsersInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BlockedUsersLoaded) {
              if (state.blockedUsers.isEmpty) {
                return _buildEmptyState(context);
              }

              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                itemCount: state.blockedUsers.length,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final user = state.blockedUsers[index];
                  return Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.of(context).card,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.of(context).border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24.r,
                          backgroundColor: AppColors.of(context).card,
                          backgroundImage: user.avatar != null &&
                                  user.avatar!.isNotEmpty
                              ? CachedNetworkImageProvider(user.avatar!)
                              : null,
                          child: user.avatar == null || user.avatar!.isEmpty
                              ? Icon(
                                  FluentIcons.person_24_regular,
                                  color: AppColors.of(context).textSecondary,
                                )
                              : null,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.of(context).textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<BlockedUsersBloc>().add(
                                  UnblockUserEvent(userId: user.id),
                                );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.of(context).primary,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                          ),
                          child: const Text(
                            'Unblock',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: AppColors.of(context).primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FluentIcons.presence_blocked_24_regular,
              size: 48.sp,
              color: AppColors.of(context).primary,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No Blocked Users',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.of(context).textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You haven\'t blocked anyone yet.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.of(context).textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

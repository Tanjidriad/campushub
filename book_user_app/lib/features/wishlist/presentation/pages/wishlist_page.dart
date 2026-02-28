import 'package:book_user_app/core/widgets/app_loader.dart';
import 'package:book_user_app/features/listings/presentation/widgets/staff_picks_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../injection_container/injection_container.dart';
import '../bloc/wishlist_bloc.dart';
import '../bloc/wishlist_event.dart';
import '../bloc/wishlist_state.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WishlistBloc>()..add(LoadWishlist()),
      child: const _WishlistPageBody(),
    );
  }
}

class _WishlistPageBody extends StatelessWidget {
  const _WishlistPageBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('My Wishlist'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocConsumer<WishlistBloc, WishlistState>(
        listener: (context, state) {
          if (state is WishlistOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is WishlistError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WishlistLoading) {
            return const AppLoaderFullPage();
          } else if (state is WishlistLoaded) {
            if (state.wishlist.isEmpty) {
              return _buildEmptyState(context);
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<WishlistBloc>().add(LoadWishlist());
              },
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: state.wishlist.length,
                itemBuilder: (context, index) {
                  final listing = state.wishlist[index];
                  return StaffPickCard(
                    listing: listing,
                    onWishlistTap: () {
                      context.read<WishlistBloc>().add(
                        RemoveFromWishlist(listing.id),
                      );
                    },
                  );
                },
              ),
            );
          }
          return _buildEmptyState(context);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.heart, size: 60.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            "Your wishlist is empty",
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Save items you want to watch or buy later",
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              // Navigate to Home/Search if possible, or just pop
              // For now, assuming this page push on stack
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: const Text("Explore Listings"),
          ),
        ],
      ),
    );
  }
}

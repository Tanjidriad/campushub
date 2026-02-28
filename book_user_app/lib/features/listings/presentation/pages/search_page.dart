import 'dart:async';
import 'package:book_user_app/core/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../injection_container/injection_container.dart';
import '../bloc/listings_bloc.dart';
import '../bloc/listings_event.dart';
import '../bloc/listings_state.dart';
import '../widgets/listing_card.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ListingsBloc>(),
      child: const _SearchPageBody(),
    );
  }
}

class _SearchPageBody extends StatefulWidget {
  const _SearchPageBody();

  @override
  State<_SearchPageBody> createState() => _SearchPageBodyState();
}

class _SearchPageBodyState extends State<_SearchPageBody> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isEmpty) {
        context.read<ListingsBloc>().add(const ListingsSearchCleared());
      } else {
        context.read<ListingsBloc>().add(
          ListingsSearchRequested(query: query.trim()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: "Search your dream books",
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            prefixIcon: Icon(
              Iconsax.search_normal,
              color: Colors.grey[600],
              size: 20.sp,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey[600],
                      size: 20.sp,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                      setState(() {});
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
            isDense: true,
          ),
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          onChanged: (value) {
            setState(() {});
            _onSearchChanged(value);
          },
        ),
      ),
      body: _searchController.text.isEmpty
          ? _buildEmptyState()
          : _buildSearchResults(),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Icon(Iconsax.search_normal_1, size: 80.sp, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text(
              "Search for books, sellers, or items",
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Start typing to discover great deals",
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
            ),
            SizedBox(height: 32.h),
            _buildRecentSearches(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    final recentSearches = [
      "Calculus",
      "Mini Fridge",
      "Calculator",
      "Chemistry Book",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          child: Text(
            "Recent Searches",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        ...recentSearches.map(
          (search) => ListTile(
            leading: Icon(Iconsax.clock, color: Colors.grey[400], size: 20.sp),
            title: Text(
              search,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            ),
            trailing: Icon(
              Iconsax.arrow_right_3,
              color: Colors.grey[400],
              size: 18.sp,
            ),
            onTap: () {
              _searchController.text = search;
              _searchController.selection = TextSelection.fromPosition(
                TextPosition(offset: search.length),
              );
              _onSearchChanged(search);
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<ListingsBloc, ListingsState>(
      builder: (context, state) {
        // Loading state
        if (state is ListingsLoading) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 60.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLoader(color: Colors.black, size: 30),
                  SizedBox(height: 16.h),
                  Text(
                    "Searching...",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Error state
        if (state is ListingsError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.warning_2, size: 50.sp, color: Colors.red[300]),
                  SizedBox(height: 16.h),
                  Text(
                    "Something went wrong",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          );
        }

        // Loaded state
        if (state is ListingsLoaded) {
          final listings = state.listings;

          if (listings.isEmpty) {
            return _buildNoResults();
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: listings.length + 1, // +1 for header
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  child: Text(
                    "${state.totalItems} result${state.totalItems != 1 ? 's' : ''} for \"${_searchController.text}\"",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              }
              final listing = listings[index - 1];
              return ListingCard.fromListing(listing: listing);
            },
          );
        }

        // Default / Initial state while typing
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 60.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ),
                SizedBox(height: 16.h),
                Text(
                  "Searching...",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.search_status, size: 60.sp, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text(
              "No results found",
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Try searching with different keywords",
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}

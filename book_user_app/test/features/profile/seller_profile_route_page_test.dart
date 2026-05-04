import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/profile/presentation/pages/seller_profile_route_page.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('empty sellerId shows error without service locator', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: SellerProfileRoutePage(sellerId: ''),
      ),
    );
    await tester.pump();
    expect(find.text('Seller data not available.'), findsOneWidget);
  });

  testWidgets('extra listing skips network and shows seller profile shell', (
    WidgetTester tester,
  ) async {
    final listing = Listing(
      id: 'l1',
      title: 'Book',
      description: 'Desc',
      images: const [],
      category: 'books',
      priceType: 'fixed',
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
      seller: const SellerInfo(id: 's1', name: 'TestSeller'),
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: SellerProfileRoutePage(
              sellerId: 's1',
              extraListing: listing,
            ),
          );
        },
      ),
    );
    await tester.pump();
    expect(find.text('TestSeller'), findsWidgets);
  });
}

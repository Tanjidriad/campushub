import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'CampusHub'**
  String get appTitle;

  /// Full branded app name
  ///
  /// In en, this message translates to:
  /// **'CampusHub Pro'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @listings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get listings;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @systemMode.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemMode;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @createListing.
  ///
  /// In en, this message translates to:
  /// **'Create Listing'**
  String get createListing;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// No description provided for @makeOffer.
  ///
  /// In en, this message translates to:
  /// **'Make Offer'**
  String get makeOffer;

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlist;

  /// No description provided for @noListingsFound.
  ///
  /// In en, this message translates to:
  /// **'No listings found'**
  String get noListingsFound;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessages;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String itemCount(int count);

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @sold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get sold;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get free;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @declined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get declined;

  /// No description provided for @countered.
  ///
  /// In en, this message translates to:
  /// **'Countered'**
  String get countered;

  /// No description provided for @counter.
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get counter;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @promoted.
  ///
  /// In en, this message translates to:
  /// **'Promoted'**
  String get promoted;

  /// No description provided for @detail.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get detail;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'(optional)'**
  String get optional;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The exclusive marketplace for students.'**
  String get loginSubtitle;

  /// No description provided for @studentLogin.
  ///
  /// In en, this message translates to:
  /// **'Student Login'**
  String get studentLogin;

  /// No description provided for @enterEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmailHint;

  /// No description provided for @enterPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPasswordHint;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccountPrompt;

  /// No description provided for @loginEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get loginEmailRequired;

  /// No description provided for @validEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validEmailRequired;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get loginPasswordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join the exclusive student marketplace.'**
  String get registerSubtitle;

  /// No description provided for @studentRegistration.
  ///
  /// In en, this message translates to:
  /// **'Student Registration'**
  String get studentRegistration;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullNameHint;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @enterStudentEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your student email'**
  String get enterStudentEmailHint;

  /// No description provided for @createPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createPasswordHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmPasswordHint;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get fullNameRequired;

  /// No description provided for @emailAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get emailAddressRequired;

  /// No description provided for @createPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please create a password'**
  String get createPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @accountCreatedVerifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Account created! Please verify your email.'**
  String get accountCreatedVerifyEmail;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry! It happens. Please enter the email address associated with your account.'**
  String get forgotPasswordDescription;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email'**
  String get resetLinkSent;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter your new password below.'**
  String get resetPasswordDescription;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @enterNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPasswordHint;

  /// No description provided for @confirmNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPasswordHint;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordButton;

  /// No description provided for @newPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get newPasswordRequired;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully! Please login.'**
  String get passwordResetSuccess;

  /// No description provided for @verifyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyYourEmail;

  /// No description provided for @verifyEmailDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a verification link to your email address. Please click the link to verify your account.'**
  String get verifyEmailDescription;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get resendEmail;

  /// No description provided for @verifiedMyEmail.
  ///
  /// In en, this message translates to:
  /// **'I\'ve verified my email'**
  String get verifiedMyEmail;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @emailVerifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully!'**
  String get emailVerifiedSuccess;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent!'**
  String get verificationEmailSent;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Your Campus.\nYour Marketplace.'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDescription1.
  ///
  /// In en, this message translates to:
  /// **'Turn your old textbooks into cash and find great deals on dorm essentials. Safe, local, and student-verified.'**
  String get onboardingDescription1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Shop Your Campus'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDescription2.
  ///
  /// In en, this message translates to:
  /// **'Safe, local deals from students near you. Buy textbooks, furniture, and more.'**
  String get onboardingDescription2;

  /// No description provided for @onboardingStepSearchFilter.
  ///
  /// In en, this message translates to:
  /// **'Search & Filter'**
  String get onboardingStepSearchFilter;

  /// No description provided for @onboardingStepSearchFilterDesc.
  ///
  /// In en, this message translates to:
  /// **'Find exactly what you need by category or dorm location.'**
  String get onboardingStepSearchFilterDesc;

  /// No description provided for @onboardingStepChatSecurely.
  ///
  /// In en, this message translates to:
  /// **'Chat Securely'**
  String get onboardingStepChatSecurely;

  /// No description provided for @onboardingStepChatSecurelyDesc.
  ///
  /// In en, this message translates to:
  /// **'Message sellers directly in-app to ask questions and negotiate.'**
  String get onboardingStepChatSecurelyDesc;

  /// No description provided for @onboardingStepMeetOnCampus.
  ///
  /// In en, this message translates to:
  /// **'Meet on Campus'**
  String get onboardingStepMeetOnCampus;

  /// No description provided for @onboardingStepMeetOnCampusDesc.
  ///
  /// In en, this message translates to:
  /// **'Safe exchange at designated campus spots like the student union.'**
  String get onboardingStepMeetOnCampusDesc;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Sell in Seconds'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDescription3.
  ///
  /// In en, this message translates to:
  /// **'Turn your clutter into cash. Post textbooks, gadgets, and gear to students on your campus.'**
  String get onboardingDescription3;

  /// No description provided for @onboardingStepSnapPhoto.
  ///
  /// In en, this message translates to:
  /// **'Snap a Photo'**
  String get onboardingStepSnapPhoto;

  /// No description provided for @onboardingStepSnapPhotoDesc.
  ///
  /// In en, this message translates to:
  /// **'Take a clear picture of your item directly in the app.'**
  String get onboardingStepSnapPhotoDesc;

  /// No description provided for @onboardingStepSetPrice.
  ///
  /// In en, this message translates to:
  /// **'Set Your Price'**
  String get onboardingStepSetPrice;

  /// No description provided for @onboardingStepSetPriceDesc.
  ///
  /// In en, this message translates to:
  /// **'Add a description and set a fair price for students.'**
  String get onboardingStepSetPriceDesc;

  /// No description provided for @onboardingStepMeetDeal.
  ///
  /// In en, this message translates to:
  /// **'Chat securely and arrange a safe meetup spot nearby.'**
  String get onboardingStepMeetDeal;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get statusLabel;

  /// No description provided for @studentVerified.
  ///
  /// In en, this message translates to:
  /// **'Student Verified'**
  String get studentVerified;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @forStudentsOnly.
  ///
  /// In en, this message translates to:
  /// **'For students only'**
  String get forStudentsOnly;

  /// No description provided for @markAsSold.
  ///
  /// In en, this message translates to:
  /// **'Mark as Sold'**
  String get markAsSold;

  /// No description provided for @confirmMarkAsSold.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to mark this listing as sold?'**
  String get confirmMarkAsSold;

  /// No description provided for @markAsSoldWarning.
  ///
  /// In en, this message translates to:
  /// **'This will cancel all pending offers and notify buyers.'**
  String get markAsSoldWarning;

  /// No description provided for @listingMarkedAsSold.
  ///
  /// In en, this message translates to:
  /// **'Listing marked as sold!'**
  String get listingMarkedAsSold;

  /// No description provided for @failedToLoadMessages.
  ///
  /// In en, this message translates to:
  /// **'Failed to load messages'**
  String get failedToLoadMessages;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @startTheConversation.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation!'**
  String get startTheConversation;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get locationUnavailable;

  /// No description provided for @sharedLocation.
  ///
  /// In en, this message translates to:
  /// **'Shared Location'**
  String get sharedLocation;

  /// No description provided for @imageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get imageUnavailable;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'offline'**
  String get offline;

  /// No description provided for @isTyping.
  ///
  /// In en, this message translates to:
  /// **'is typing...'**
  String get isTyping;

  /// No description provided for @noConversationsYet.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversationsYet;

  /// No description provided for @startChattingWithSellers.
  ///
  /// In en, this message translates to:
  /// **'Start chatting with sellers!'**
  String get startChattingWithSellers;

  /// No description provided for @failedToLoadConversations.
  ///
  /// In en, this message translates to:
  /// **'Failed to load conversations'**
  String get failedToLoadConversations;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @makeAnOffer.
  ///
  /// In en, this message translates to:
  /// **'Make an Offer'**
  String get makeAnOffer;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Message...'**
  String get messageHint;

  /// No description provided for @contactForPrice.
  ///
  /// In en, this message translates to:
  /// **'Contact for price'**
  String get contactForPrice;

  /// No description provided for @viewListing.
  ///
  /// In en, this message translates to:
  /// **'View Listing'**
  String get viewListing;

  /// No description provided for @markSold.
  ///
  /// In en, this message translates to:
  /// **'Mark Sold'**
  String get markSold;

  /// No description provided for @quickReplyStillAvailable.
  ///
  /// In en, this message translates to:
  /// **'Yes, still available'**
  String get quickReplyStillAvailable;

  /// No description provided for @quickReplyWhereToMeet.
  ///
  /// In en, this message translates to:
  /// **'Where to meet?'**
  String get quickReplyWhereToMeet;

  /// No description provided for @quickReplyPriceNegotiable.
  ///
  /// In en, this message translates to:
  /// **'Is price negotiable?'**
  String get quickReplyPriceNegotiable;

  /// No description provided for @quickReplyImHere.
  ///
  /// In en, this message translates to:
  /// **'I\'m here'**
  String get quickReplyImHere;

  /// No description provided for @safetyTipPublicPlaces.
  ///
  /// In en, this message translates to:
  /// **'Safety Tip: Always meet in public places like the library.'**
  String get safetyTipPublicPlaces;

  /// No description provided for @maxPhotosWarning.
  ///
  /// In en, this message translates to:
  /// **'You can only upload up to 10 photos'**
  String get maxPhotosWarning;

  /// No description provided for @stepOneOfFour.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 4'**
  String get stepOneOfFour;

  /// No description provided for @twentyFivePercentCompleted.
  ///
  /// In en, this message translates to:
  /// **'25% completed'**
  String get twentyFivePercentCompleted;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get addPhotos;

  /// No description provided for @addPhotosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload up to 10 photos. Choose your best shot as the cover.'**
  String get addPhotosSubtitle;

  /// No description provided for @quickTip.
  ///
  /// In en, this message translates to:
  /// **'QUICK TIP'**
  String get quickTip;

  /// No description provided for @lightingTip.
  ///
  /// In en, this message translates to:
  /// **'Good lighting helps items sell 50% faster! Try using natural light near a window.'**
  String get lightingTip;

  /// No description provided for @coverPhoto.
  ///
  /// In en, this message translates to:
  /// **'Cover Photo'**
  String get coverPhoto;

  /// No description provided for @addCoverPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Cover Photo'**
  String get addCoverPhoto;

  /// No description provided for @addMore.
  ///
  /// In en, this message translates to:
  /// **'Add More'**
  String get addMore;

  /// No description provided for @addDetails.
  ///
  /// In en, this message translates to:
  /// **'Add Details'**
  String get addDetails;

  /// No description provided for @stepTwoOfThree.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 3'**
  String get stepTwoOfThree;

  /// No description provided for @itemInformation.
  ///
  /// In en, this message translates to:
  /// **'Item Information'**
  String get itemInformation;

  /// No description provided for @itemInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details to help buyers find your item.'**
  String get itemInfoSubtitle;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectCategory;

  /// No description provided for @conditionNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get conditionNew;

  /// No description provided for @conditionLikeNew.
  ///
  /// In en, this message translates to:
  /// **'Like New'**
  String get conditionLikeNew;

  /// No description provided for @conditionGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get conditionGood;

  /// No description provided for @conditionFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get conditionFair;

  /// No description provided for @whatAreYouSellingHint.
  ///
  /// In en, this message translates to:
  /// **'What are you selling?'**
  String get whatAreYouSellingHint;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what you are selling (e.g., Author, Edition, specific flaws)...'**
  String get descriptionHint;

  /// No description provided for @bookDetails.
  ///
  /// In en, this message translates to:
  /// **'Book Details'**
  String get bookDetails;

  /// No description provided for @bookDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help students find the right book for their level.'**
  String get bookDetailsSubtitle;

  /// No description provided for @educationLevel.
  ///
  /// In en, this message translates to:
  /// **'Education Level'**
  String get educationLevel;

  /// No description provided for @priceAndPickup.
  ///
  /// In en, this message translates to:
  /// **'Price & Pickup'**
  String get priceAndPickup;

  /// No description provided for @pricePickupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a fair price and choose a safe meeting spot on campus.'**
  String get pricePickupSubtitle;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'PRICE'**
  String get priceLabel;

  /// No description provided for @openToOffers.
  ///
  /// In en, this message translates to:
  /// **'Open to offers?'**
  String get openToOffers;

  /// No description provided for @allowBuyersSuggestPrice.
  ///
  /// In en, this message translates to:
  /// **'Allow buyers to suggest a price'**
  String get allowBuyersSuggestPrice;

  /// No description provided for @meetingSpot.
  ///
  /// In en, this message translates to:
  /// **'Meeting Spot'**
  String get meetingSpot;

  /// No description provided for @safetyTip.
  ///
  /// In en, this message translates to:
  /// **'Safety Tip'**
  String get safetyTip;

  /// No description provided for @meetingSpotSafetyTip.
  ///
  /// In en, this message translates to:
  /// **'Meet in public areas like the Student Union or Library. Avoid dorm rooms.'**
  String get meetingSpotSafetyTip;

  /// No description provided for @enterPickupLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter pickup location'**
  String get enterPickupLocationHint;

  /// No description provided for @campusLibrary.
  ///
  /// In en, this message translates to:
  /// **'Campus Library'**
  String get campusLibrary;

  /// No description provided for @studentCenter.
  ///
  /// In en, this message translates to:
  /// **'Student Center'**
  String get studentCenter;

  /// No description provided for @mainGate.
  ///
  /// In en, this message translates to:
  /// **'Main Gate'**
  String get mainGate;

  /// No description provided for @cafeteria.
  ///
  /// In en, this message translates to:
  /// **'Cafeteria'**
  String get cafeteria;

  /// No description provided for @priceRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a price'**
  String get priceRequired;

  /// No description provided for @validPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price greater than 0'**
  String get validPriceRequired;

  /// No description provided for @publishListing.
  ///
  /// In en, this message translates to:
  /// **'Publish Listing'**
  String get publishListing;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @listingSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Listing Submitted!'**
  String get listingSubmitted;

  /// No description provided for @listingSubmittedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your listing has been submitted for review. Our team will review it and you\'ll be notified once it\'s approved.'**
  String get listingSubmittedDescription;

  /// No description provided for @pendingApproval.
  ///
  /// In en, this message translates to:
  /// **'PENDING APPROVAL'**
  String get pendingApproval;

  /// No description provided for @listingBeingReviewed.
  ///
  /// In en, this message translates to:
  /// **'Your listing is being reviewed'**
  String get listingBeingReviewed;

  /// No description provided for @usuallyWithin24Hours.
  ///
  /// In en, this message translates to:
  /// **'Usually within 24 hours'**
  String get usuallyWithin24Hours;

  /// No description provided for @wellNotifyYou.
  ///
  /// In en, this message translates to:
  /// **'We\'ll notify you'**
  String get wellNotifyYou;

  /// No description provided for @visibleAfterApproval.
  ///
  /// In en, this message translates to:
  /// **'Visible after approval'**
  String get visibleAfterApproval;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @viewMyListings.
  ///
  /// In en, this message translates to:
  /// **'View My Listings'**
  String get viewMyListings;

  /// No description provided for @latestAds.
  ///
  /// In en, this message translates to:
  /// **'Latest Ads'**
  String get latestAds;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @listingDataNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Listing data not loaded yet'**
  String get listingDataNotLoaded;

  /// No description provided for @sellerInfoNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Seller information not available'**
  String get sellerInfoNotAvailable;

  /// No description provided for @listingDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Listing deleted successfully'**
  String get listingDeletedSuccess;

  /// No description provided for @listingMarkedAsSoldMsg.
  ///
  /// In en, this message translates to:
  /// **'Listing marked as sold'**
  String get listingMarkedAsSoldMsg;

  /// No description provided for @adDetails.
  ///
  /// In en, this message translates to:
  /// **'Ad Details'**
  String get adDetails;

  /// No description provided for @shareCheckItOut.
  ///
  /// In en, this message translates to:
  /// **'Check it out on CampusHub Pro!'**
  String get shareCheckItOut;

  /// No description provided for @seeMap.
  ///
  /// In en, this message translates to:
  /// **'see map'**
  String get seeMap;

  /// No description provided for @locationNotSet.
  ///
  /// In en, this message translates to:
  /// **'Location not set'**
  String get locationNotSet;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available.'**
  String get noDescriptionAvailable;

  /// No description provided for @safetyTipsForDeal.
  ///
  /// In en, this message translates to:
  /// **'Safety tips for deal'**
  String get safetyTipsForDeal;

  /// No description provided for @safetyTipMeetSeller.
  ///
  /// In en, this message translates to:
  /// **'Use a safe location to meet seller'**
  String get safetyTipMeetSeller;

  /// No description provided for @safetyTipAvoidCash.
  ///
  /// In en, this message translates to:
  /// **'Avoid cash transactions'**
  String get safetyTipAvoidCash;

  /// No description provided for @safetyTipUnrealisticOffers.
  ///
  /// In en, this message translates to:
  /// **'Beware of unrealistic offers'**
  String get safetyTipUnrealisticOffers;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfile;

  /// No description provided for @ratingAndReview.
  ///
  /// In en, this message translates to:
  /// **'Rating & Review'**
  String get ratingAndReview;

  /// No description provided for @couldNotLoadReviews.
  ///
  /// In en, this message translates to:
  /// **'Could not load reviews'**
  String get couldNotLoadReviews;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @writeAReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeAReview;

  /// No description provided for @promoteListing.
  ///
  /// In en, this message translates to:
  /// **'Promote Listing'**
  String get promoteListing;

  /// No description provided for @shareOnWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Share on WhatsApp'**
  String get shareOnWhatsApp;

  /// No description provided for @foundOnCampusHub.
  ///
  /// In en, this message translates to:
  /// **'Found on CampusHub Pro 📚'**
  String get foundOnCampusHub;

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buyNow;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @deleteListing.
  ///
  /// In en, this message translates to:
  /// **'Delete Listing'**
  String get deleteListing;

  /// No description provided for @confirmDeleteListing.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this listing? This action cannot be undone.'**
  String get confirmDeleteListing;

  /// No description provided for @editListing.
  ///
  /// In en, this message translates to:
  /// **'Edit Listing'**
  String get editListing;

  /// No description provided for @searchDreamBooksHint.
  ///
  /// In en, this message translates to:
  /// **'Search your dream books'**
  String get searchDreamBooksHint;

  /// No description provided for @searchForBooksPrompt.
  ///
  /// In en, this message translates to:
  /// **'Search for books, sellers, or items'**
  String get searchForBooksPrompt;

  /// No description provided for @startTypingDiscover.
  ///
  /// In en, this message translates to:
  /// **'Start typing to discover great deals'**
  String get startTypingDiscover;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @tryDifferentKeywords.
  ///
  /// In en, this message translates to:
  /// **'Try searching with different keywords'**
  String get tryDifferentKeywords;

  /// No description provided for @listingUpdatedPending.
  ///
  /// In en, this message translates to:
  /// **'Listing updated. It is now pending admin approval.'**
  String get listingUpdatedPending;

  /// No description provided for @listingUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Listing updated successfully'**
  String get listingUpdatedSuccess;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicInfo;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get titleRequired;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get categoryRequired;

  /// No description provided for @conditionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a condition'**
  String get conditionRequired;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get descriptionRequired;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @listingPromotedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Listing promoted successfully!'**
  String get listingPromotedSuccess;

  /// No description provided for @previewOnFeed.
  ///
  /// In en, this message translates to:
  /// **'PREVIEW ON FEED'**
  String get previewOnFeed;

  /// No description provided for @featuredBadge.
  ///
  /// In en, this message translates to:
  /// **'FEATURED'**
  String get featuredBadge;

  /// No description provided for @previewDescription.
  ///
  /// In en, this message translates to:
  /// **'This is how your listing will appear to other students.'**
  String get previewDescription;

  /// No description provided for @whyFeature.
  ///
  /// In en, this message translates to:
  /// **'Why Feature?'**
  String get whyFeature;

  /// No description provided for @fiveXMoreViews.
  ///
  /// In en, this message translates to:
  /// **'5x More\nViews'**
  String get fiveXMoreViews;

  /// No description provided for @sellTwoXFaster.
  ///
  /// In en, this message translates to:
  /// **'Sell 2x\nFaster'**
  String get sellTwoXFaster;

  /// No description provided for @buildTrust.
  ///
  /// In en, this message translates to:
  /// **'Build\nTrust'**
  String get buildTrust;

  /// No description provided for @selectDuration.
  ///
  /// In en, this message translates to:
  /// **'Select Duration'**
  String get selectDuration;

  /// No description provided for @threeDays.
  ///
  /// In en, this message translates to:
  /// **'3 Days'**
  String get threeDays;

  /// No description provided for @sevenDays.
  ///
  /// In en, this message translates to:
  /// **'7 Days'**
  String get sevenDays;

  /// No description provided for @thirtyDays.
  ///
  /// In en, this message translates to:
  /// **'30 Days'**
  String get thirtyDays;

  /// No description provided for @goodForQuickSales.
  ///
  /// In en, this message translates to:
  /// **'Good for quick sales'**
  String get goodForQuickSales;

  /// No description provided for @recommendedDuration.
  ///
  /// In en, this message translates to:
  /// **'Recommended duration'**
  String get recommendedDuration;

  /// No description provided for @maximumExposure.
  ///
  /// In en, this message translates to:
  /// **'Maximum exposure'**
  String get maximumExposure;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostPopular;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get bestValue;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @filterAndSort.
  ///
  /// In en, this message translates to:
  /// **'Filter & Sort'**
  String get filterAndSort;

  /// No description provided for @searchWithKeywords.
  ///
  /// In en, this message translates to:
  /// **'Search with keywords...'**
  String get searchWithKeywords;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get newestFirst;

  /// No description provided for @priceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get priceLowToHigh;

  /// No description provided for @priceHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get priceHighToLow;

  /// No description provided for @filtered.
  ///
  /// In en, this message translates to:
  /// **'Filtered'**
  String get filtered;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @featuredSection.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featuredSection;

  /// No description provided for @staffPicks.
  ///
  /// In en, this message translates to:
  /// **'Staff Picks'**
  String get staffPicks;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @dealsNearYou.
  ///
  /// In en, this message translates to:
  /// **'Deals Near You'**
  String get dealsNearYou;

  /// No description provided for @dealsNearYouMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get dealsNearYouMap;

  /// No description provided for @dealsNearYouRadiusKm.
  ///
  /// In en, this message translates to:
  /// **'10 km radius'**
  String get dealsNearYouRadiusKm;

  /// No description provided for @dealsNearYouLocationOff.
  ///
  /// In en, this message translates to:
  /// **'Location is off'**
  String get dealsNearYouLocationOff;

  /// No description provided for @dealsNearYouLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Turn on location to see listings near you.'**
  String get dealsNearYouLocationHint;

  /// No description provided for @dealsNearYouOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get dealsNearYouOpenSettings;

  /// No description provided for @dealsNearYouEmpty.
  ///
  /// In en, this message translates to:
  /// **'No deals in this area yet. Check back soon.'**
  String get dealsNearYouEmpty;

  /// No description provided for @dealsNearYouDistMiles.
  ///
  /// In en, this message translates to:
  /// **'{miles} mi'**
  String dealsNearYouDistMiles(String miles);

  /// No description provided for @mapSearchDealsHint.
  ///
  /// In en, this message translates to:
  /// **'Search nearby listings…'**
  String get mapSearchDealsHint;

  /// No description provided for @mapDealsCountNearby.
  ///
  /// In en, this message translates to:
  /// **'{count} deals nearby'**
  String mapDealsCountNearby(int count);

  /// No description provided for @mapNoMatchingDeals.
  ///
  /// In en, this message translates to:
  /// **'No listings match your search'**
  String get mapNoMatchingDeals;

  /// No description provided for @mapRecenter.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get mapRecenter;

  /// No description provided for @mapFitAll.
  ///
  /// In en, this message translates to:
  /// **'Fit all pins'**
  String get mapFitAll;

  /// No description provided for @mapSwipeForMore.
  ///
  /// In en, this message translates to:
  /// **'Swipe for more'**
  String get mapSwipeForMore;

  /// No description provided for @createNewListing.
  ///
  /// In en, this message translates to:
  /// **'Create new listing'**
  String get createNewListing;

  /// No description provided for @removeFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get removeFromSaved;

  /// No description provided for @saveToWishlist.
  ///
  /// In en, this message translates to:
  /// **'Save to wishlist'**
  String get saveToWishlist;

  /// No description provided for @fixedPriceType.
  ///
  /// In en, this message translates to:
  /// **' (Fixed)'**
  String get fixedPriceType;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @drawerHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get drawerHome;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @failedToLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Failed to load notifications'**
  String get failedToLoadNotifications;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get allCaughtUp;

  /// No description provided for @noNewNotifications.
  ///
  /// In en, this message translates to:
  /// **'No new notifications for you right now.'**
  String get noNewNotifications;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @older.
  ///
  /// In en, this message translates to:
  /// **'Older'**
  String get older;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @listingApproved.
  ///
  /// In en, this message translates to:
  /// **'Listing Approved'**
  String get listingApproved;

  /// No description provided for @listingRejected.
  ///
  /// In en, this message translates to:
  /// **'Listing Rejected'**
  String get listingRejected;

  /// No description provided for @priceDropAlert.
  ///
  /// In en, this message translates to:
  /// **'Price Drop Alert'**
  String get priceDropAlert;

  /// No description provided for @accountWarning.
  ///
  /// In en, this message translates to:
  /// **'Account Warning'**
  String get accountWarning;

  /// No description provided for @offerRequest.
  ///
  /// In en, this message translates to:
  /// **'Offer Request'**
  String get offerRequest;

  /// No description provided for @offerAccepted.
  ///
  /// In en, this message translates to:
  /// **'Offer accepted!'**
  String get offerAccepted;

  /// No description provided for @offerDeclined.
  ///
  /// In en, this message translates to:
  /// **'Offer declined'**
  String get offerDeclined;

  /// No description provided for @counterOfferSent.
  ///
  /// In en, this message translates to:
  /// **'Counter offer sent!'**
  String get counterOfferSent;

  /// No description provided for @listing.
  ///
  /// In en, this message translates to:
  /// **'Listing'**
  String get listing;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get expires;

  /// No description provided for @askingPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Asking Price'**
  String get askingPriceLabel;

  /// No description provided for @offeredPrice.
  ///
  /// In en, this message translates to:
  /// **'Offered Price'**
  String get offeredPrice;

  /// No description provided for @counterOffer.
  ///
  /// In en, this message translates to:
  /// **'Counter Offer'**
  String get counterOffer;

  /// No description provided for @acceptOffer.
  ///
  /// In en, this message translates to:
  /// **'Accept Offer'**
  String get acceptOffer;

  /// No description provided for @declineOffer.
  ///
  /// In en, this message translates to:
  /// **'Decline Offer'**
  String get declineOffer;

  /// No description provided for @confirmDeclineOffer.
  ///
  /// In en, this message translates to:
  /// **'Decline this offer?'**
  String get confirmDeclineOffer;

  /// No description provided for @leaveAReview.
  ///
  /// In en, this message translates to:
  /// **'Leave a Review'**
  String get leaveAReview;

  /// No description provided for @counterOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Counter Offer'**
  String get counterOfferTitle;

  /// No description provided for @enterCounterPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter your counter price:'**
  String get enterCounterPrice;

  /// No description provided for @sendCounter.
  ///
  /// In en, this message translates to:
  /// **'Send Counter'**
  String get sendCounter;

  /// No description provided for @offerSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Offer sent successfully!'**
  String get offerSentSuccess;

  /// No description provided for @yourOffer.
  ///
  /// In en, this message translates to:
  /// **'Your Offer'**
  String get yourOffer;

  /// No description provided for @sendOffer.
  ///
  /// In en, this message translates to:
  /// **'Send Offer'**
  String get sendOffer;

  /// No description provided for @myListings.
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get myListings;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;

  /// No description provided for @aboutSeller.
  ///
  /// In en, this message translates to:
  /// **'About Seller'**
  String get aboutSeller;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSince;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not Set'**
  String get notSet;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @accountOptions.
  ///
  /// In en, this message translates to:
  /// **'Account Options'**
  String get accountOptions;

  /// No description provided for @blockedUsers.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get blockedUsers;

  /// No description provided for @clickHere.
  ///
  /// In en, this message translates to:
  /// **'Click Here'**
  String get clickHere;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found.'**
  String get noItemsFound;

  /// No description provided for @usernameInvalidChars.
  ///
  /// In en, this message translates to:
  /// **'Only letters, numbers, and underscores allowed'**
  String get usernameInvalidChars;

  /// No description provided for @usernameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameMinLength;

  /// No description provided for @usernameMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Username cannot exceed 20 characters'**
  String get usernameMaxLength;

  /// No description provided for @currentUsernameMessage.
  ///
  /// In en, this message translates to:
  /// **'This is your current username'**
  String get currentUsernameMessage;

  /// No description provided for @usernameAvailable.
  ///
  /// In en, this message translates to:
  /// **'Username is available!'**
  String get usernameAvailable;

  /// No description provided for @usernameTaken.
  ///
  /// In en, this message translates to:
  /// **'Username is already taken'**
  String get usernameTaken;

  /// No description provided for @chooseAvailableUsername.
  ///
  /// In en, this message translates to:
  /// **'Please choose an available username'**
  String get chooseAvailableUsername;

  /// No description provided for @changeProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Picture'**
  String get changeProfilePicture;

  /// No description provided for @takeAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takeAPhoto;

  /// No description provided for @useYourCamera.
  ///
  /// In en, this message translates to:
  /// **'Use your camera'**
  String get useYourCamera;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @selectExistingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Select an existing photo'**
  String get selectExistingPhoto;

  /// No description provided for @profilePictureUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated!'**
  String get profilePictureUpdated;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @tapToChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to change photo'**
  String get tapToChangePhoto;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameHint;

  /// No description provided for @nameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameIsRequired;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @validPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get validPhoneNumber;

  /// No description provided for @campusDormLocation.
  ///
  /// In en, this message translates to:
  /// **'Campus / Dorm Location'**
  String get campusDormLocation;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @bioMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Bio must be 300 characters or less'**
  String get bioMaxLength;

  /// No description provided for @sellerProfile.
  ///
  /// In en, this message translates to:
  /// **'Seller Profile'**
  String get sellerProfile;

  /// No description provided for @unknownSeller.
  ///
  /// In en, this message translates to:
  /// **'Unknown Seller'**
  String get unknownSeller;

  /// No description provided for @activeAdsBy.
  ///
  /// In en, this message translates to:
  /// **'Active Ads by {sellerName}'**
  String activeAdsBy(String sellerName);

  /// No description provided for @invalidUserId.
  ///
  /// In en, this message translates to:
  /// **'Invalid user ID'**
  String get invalidUserId;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @reportListing.
  ///
  /// In en, this message translates to:
  /// **'Report Listing'**
  String get reportListing;

  /// No description provided for @reportUser.
  ///
  /// In en, this message translates to:
  /// **'Report User'**
  String get reportUser;

  /// No description provided for @reportMessage.
  ///
  /// In en, this message translates to:
  /// **'Report Message'**
  String get reportMessage;

  /// No description provided for @helpKeepCommunitySafe.
  ///
  /// In en, this message translates to:
  /// **'Help us keep the community safe'**
  String get helpKeepCommunitySafe;

  /// No description provided for @whyReporting.
  ///
  /// In en, this message translates to:
  /// **'Why are you reporting this?'**
  String get whyReporting;

  /// No description provided for @additionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Additional details'**
  String get additionalDetails;

  /// No description provided for @tellUsMoreHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us more about the issue...'**
  String get tellUsMoreHint;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// No description provided for @reportSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report submitted. We\'ll review it shortly.'**
  String get reportSubmittedSuccess;

  /// No description provided for @pleaseSelectRating.
  ///
  /// In en, this message translates to:
  /// **'Please select a rating'**
  String get pleaseSelectRating;

  /// No description provided for @reviewSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully!'**
  String get reviewSubmittedSuccess;

  /// No description provided for @ratingPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get ratingPoor;

  /// No description provided for @ratingFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get ratingFair;

  /// No description provided for @ratingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ratingGood;

  /// No description provided for @ratingVeryGood.
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get ratingVeryGood;

  /// No description provided for @ratingExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get ratingExcellent;

  /// No description provided for @howWasYourExperience.
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get howWasYourExperience;

  /// No description provided for @tapStarToRate.
  ///
  /// In en, this message translates to:
  /// **'Tap a star to rate the seller'**
  String get tapStarToRate;

  /// No description provided for @writeYourFeedback.
  ///
  /// In en, this message translates to:
  /// **'Write your feedback'**
  String get writeYourFeedback;

  /// No description provided for @optionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optionalLabel;

  /// No description provided for @reviewHintText.
  ///
  /// In en, this message translates to:
  /// **'Share your experience with this seller...\n\nWas the item as described? Was the seller responsive?'**
  String get reviewHintText;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @myWishlist.
  ///
  /// In en, this message translates to:
  /// **'My Wishlist'**
  String get myWishlist;

  /// No description provided for @wishlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your wishlist is empty'**
  String get wishlistEmpty;

  /// No description provided for @wishlistEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save items you want to watch or buy later'**
  String get wishlistEmptySubtitle;

  /// No description provided for @exploreListings.
  ///
  /// In en, this message translates to:
  /// **'Explore Listings'**
  String get exploreListings;

  /// No description provided for @askingPrice.
  ///
  /// In en, this message translates to:
  /// **'Asking: \${price}'**
  String askingPrice(String price);

  /// No description provided for @percentOfAskingPrice.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of asking price'**
  String percentOfAskingPrice(String percent);

  /// No description provided for @roundOfThree.
  ///
  /// In en, this message translates to:
  /// **'Round {round} of 3'**
  String roundOfThree(int round);

  /// No description provided for @acceptOfferConfirm.
  ///
  /// In en, this message translates to:
  /// **'Accept this offer of \${amount}?'**
  String acceptOfferConfirm(String amount);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String daysAgo(int days);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(int hours);

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(int minutes);

  /// No description provided for @daysHoursRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days}d {hours}h remaining'**
  String daysHoursRemaining(int days, int hours);

  /// No description provided for @hoursMinutesRemaining.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m remaining'**
  String hoursMinutesRemaining(int hours, int minutes);

  /// No description provided for @minutesRemaining.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m remaining'**
  String minutesRemaining(int minutes);

  /// No description provided for @itemLabel.
  ///
  /// In en, this message translates to:
  /// **'Item: {title}'**
  String itemLabel(String title);

  /// No description provided for @photosSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} photos selected'**
  String photosSelected(int count);

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @pleaseSelectPhoto.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one photo'**
  String get pleaseSelectPhoto;

  /// No description provided for @nextDetails.
  ///
  /// In en, this message translates to:
  /// **'Next: Details'**
  String get nextDetails;

  /// No description provided for @semester.
  ///
  /// In en, this message translates to:
  /// **'Semester'**
  String get semester;

  /// No description provided for @classLabel.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get classLabel;

  /// No description provided for @stream.
  ///
  /// In en, this message translates to:
  /// **'Stream'**
  String get stream;

  /// No description provided for @subjectOptional.
  ///
  /// In en, this message translates to:
  /// **'Subject (optional)'**
  String get subjectOptional;

  /// No description provided for @subjectHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mathematics, Physics, Bengali...'**
  String get subjectHint;

  /// No description provided for @bookType.
  ///
  /// In en, this message translates to:
  /// **'Book Type'**
  String get bookType;

  /// No description provided for @nextPricePickup.
  ///
  /// In en, this message translates to:
  /// **'Next: Price & Pickup'**
  String get nextPricePickup;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @bengali.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get bengali;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @similarListings.
  ///
  /// In en, this message translates to:
  /// **'Similar Listings'**
  String get similarListings;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

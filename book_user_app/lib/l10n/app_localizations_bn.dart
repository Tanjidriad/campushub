// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'ক্যাম্পাসহাব';

  @override
  String get appName => 'ক্যাম্পাসহাব প্রো';

  @override
  String get login => 'লগইন';

  @override
  String get register => 'নিবন্ধন';

  @override
  String get email => 'ইমেইল';

  @override
  String get password => 'পাসওয়ার্ড';

  @override
  String get forgotPassword => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get changePassword => 'পাসওয়ার্ড পরিবর্তন';

  @override
  String get name => 'নাম';

  @override
  String get search => 'অনুসন্ধান';

  @override
  String get listings => 'তালিকা';

  @override
  String get chat => 'চ্যাট';

  @override
  String get profile => 'প্রোফাইল';

  @override
  String get notifications => 'বিজ্ঞপ্তি';

  @override
  String get settings => 'সেটিংস';

  @override
  String get darkMode => 'ডার্ক মোড';

  @override
  String get lightMode => 'লাইট মোড';

  @override
  String get systemMode => 'সিস্টেম ডিফল্ট';

  @override
  String get logout => 'লগআউট';

  @override
  String get createListing => 'তালিকা তৈরি করুন';

  @override
  String get title => 'শিরোনাম';

  @override
  String get description => 'বিবরণ';

  @override
  String get price => 'মূল্য';

  @override
  String get category => 'বিভাগ';

  @override
  String get condition => 'অবস্থা';

  @override
  String get makeOffer => 'অফার করুন';

  @override
  String get wishlist => 'ইচ্ছা তালিকা';

  @override
  String get noListingsFound => 'কোন তালিকা পাওয়া যায়নি';

  @override
  String get noMessages => 'এখনো কোনো বার্তা নেই';

  @override
  String get send => 'পাঠান';

  @override
  String get typeMessage => 'একটি বার্তা লিখুন...';

  @override
  String get errorOccurred => 'একটি ত্রুটি ঘটেছে';

  @override
  String get retry => 'পুনরায় চেষ্টা';

  @override
  String get cancel => 'বাতিল';

  @override
  String get confirm => 'নিশ্চিত';

  @override
  String get delete => 'মুছুন';

  @override
  String get edit => 'সম্পাদনা';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি আইটেম',
      one: '১টি আইটেম',
      zero: 'কোন আইটেম নেই',
    );
    return '$_temp0';
  }

  @override
  String get logIn => 'লগ ইন';

  @override
  String get signUp => 'সাইন আপ';

  @override
  String get signOut => 'সাইন আউট';

  @override
  String get back => 'পিছনে';

  @override
  String get next => 'পরবর্তী';

  @override
  String get skip => 'এড়িয়ে যান';

  @override
  String get all => 'সব';

  @override
  String get reset => 'রিসেট';

  @override
  String get clear => 'মুছুন';

  @override
  String get loading => 'লোড হচ্ছে...';

  @override
  String get no => 'না';

  @override
  String get home => 'হোম';

  @override
  String get saved => 'সংরক্ষিত';

  @override
  String get add => 'যোগ করুন';

  @override
  String get messages => 'বার্তা';

  @override
  String get report => 'রিপোর্ট';

  @override
  String get location => 'অবস্থান';

  @override
  String get available => 'উপলব্ধ';

  @override
  String get sold => 'বিক্রি হয়েছে';

  @override
  String get free => 'বিনামূল্যে';

  @override
  String get help => 'সাহায্য';

  @override
  String get follow => 'অনুসরণ';

  @override
  String get message => 'বার্তা';

  @override
  String get accept => 'গ্রহণ';

  @override
  String get decline => 'প্রত্যাখ্যান';

  @override
  String get pending => 'অপেক্ষমাণ';

  @override
  String get expired => 'মেয়াদ শেষ';

  @override
  String get accepted => 'গৃহীত';

  @override
  String get declined => 'প্রত্যাখ্যাত';

  @override
  String get countered => 'পাল্টা দেওয়া';

  @override
  String get counter => 'পাল্টা';

  @override
  String get featured => 'বৈশিষ্ট্যযুক্ত';

  @override
  String get promoted => 'প্রচারিত';

  @override
  String get detail => 'বিস্তারিত';

  @override
  String get optional => '(ঐচ্ছিক)';

  @override
  String get unknown => 'অজানা';

  @override
  String get loginSubtitle => 'শিক্ষার্থীদের জন্য এক্সক্লুসিভ মার্কেটপ্লেস।';

  @override
  String get studentLogin => 'শিক্ষার্থী লগইন';

  @override
  String get enterEmailHint => 'আপনার ইমেইল লিখুন';

  @override
  String get enterPasswordHint => 'আপনার পাসওয়ার্ড লিখুন';

  @override
  String get noAccountPrompt => 'অ্যাকাউন্ট নেই? ';

  @override
  String get loginEmailRequired => 'আপনার ইমেইল লিখুন';

  @override
  String get validEmailRequired => 'একটি বৈধ ইমেইল ঠিকানা লিখুন';

  @override
  String get loginPasswordRequired => 'আপনার পাসওয়ার্ড লিখুন';

  @override
  String get passwordMinLength => 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে';

  @override
  String get registerSubtitle => 'শিক্ষার্থীদের মার্কেটপ্লেসে যোগ দিন।';

  @override
  String get studentRegistration => 'শিক্ষার্থী নিবন্ধন';

  @override
  String get fullName => 'পুরো নাম';

  @override
  String get enterFullNameHint => 'আপনার পুরো নাম লিখুন';

  @override
  String get emailAddress => 'ইমেইল ঠিকানা';

  @override
  String get enterStudentEmailHint => 'আপনার শিক্ষার্থী ইমেইল লিখুন';

  @override
  String get createPasswordHint => 'একটি পাসওয়ার্ড তৈরি করুন';

  @override
  String get confirmPassword => 'পাসওয়ার্ড নিশ্চিত করুন';

  @override
  String get confirmPasswordHint => 'আপনার পাসওয়ার্ড নিশ্চিত করুন';

  @override
  String get alreadyHaveAccount => 'ইতিমধ্যে অ্যাকাউন্ট আছে? ';

  @override
  String get fullNameRequired => 'আপনার পুরো নাম লিখুন';

  @override
  String get emailAddressRequired => 'আপনার ইমেইল ঠিকানা লিখুন';

  @override
  String get createPasswordRequired => 'একটি পাসওয়ার্ড তৈরি করুন';

  @override
  String get passwordsDoNotMatch => 'পাসওয়ার্ড মিলছে না';

  @override
  String get accountCreatedVerifyEmail =>
      'অ্যাকাউন্ট তৈরি হয়েছে! আপনার ইমেইল যাচাই করুন।';

  @override
  String get forgotPasswordTitle => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get forgotPasswordDescription =>
      'চিন্তা করবেন না! আপনার অ্যাকাউন্টের সাথে সংযুক্ত ইমেইল ঠিকানা লিখুন।';

  @override
  String get sendResetLink => 'রিসেট লিংক পাঠান';

  @override
  String get resetLinkSent =>
      'পাসওয়ার্ড রিসেট লিংক আপনার ইমেইলে পাঠানো হয়েছে';

  @override
  String get resetPasswordTitle => 'পাসওয়ার্ড রিসেট';

  @override
  String get resetPasswordDescription => 'নিচে আপনার নতুন পাসওয়ার্ড লিখুন।';

  @override
  String get newPasswordLabel => 'নতুন পাসওয়ার্ড';

  @override
  String get enterNewPasswordHint => 'নতুন পাসওয়ার্ড লিখুন';

  @override
  String get confirmNewPasswordHint => 'নতুন পাসওয়ার্ড নিশ্চিত করুন';

  @override
  String get resetPasswordButton => 'পাসওয়ার্ড রিসেট';

  @override
  String get newPasswordRequired => 'একটি নতুন পাসওয়ার্ড লিখুন';

  @override
  String get passwordResetSuccess =>
      'পাসওয়ার্ড সফলভাবে রিসেট হয়েছে! লগইন করুন।';

  @override
  String get verifyYourEmail => 'আপনার ইমেইল যাচাই করুন';

  @override
  String get verifyEmailDescription =>
      'আমরা আপনার ইমেইল ঠিকানায় একটি যাচাই লিংক পাঠিয়েছি। আপনার অ্যাকাউন্ট যাচাই করতে লিংকে ক্লিক করুন।';

  @override
  String get resendEmail => 'ইমেইল পুনরায় পাঠান';

  @override
  String get verifiedMyEmail => 'আমি আমার ইমেইল যাচাই করেছি';

  @override
  String get backToLogin => 'লগইনে ফিরে যান';

  @override
  String get emailVerifiedSuccess => 'ইমেইল সফলভাবে যাচাই হয়েছে!';

  @override
  String get verificationEmailSent => 'যাচাই ইমেইল পাঠানো হয়েছে!';

  @override
  String get onboardingTitle1 => 'আপনার ক্যাম্পাস।\nআপনার মার্কেটপ্লেস।';

  @override
  String get onboardingDescription1 =>
      'আপনার পুরনো পাঠ্যবই নগদে পরিণত করুন এবং ডর্ম প্রয়োজনীয়তায় দুর্দান্ত ডিল খুঁজুন।';

  @override
  String get onboardingTitle2 => 'আপনার ক্যাম্পাসে কেনাকাটা করুন';

  @override
  String get onboardingDescription2 =>
      'আপনার কাছের শিক্ষার্থীদের থেকে নিরাপদ, স্থানীয় ডিল।';

  @override
  String get onboardingStepSearchFilter => 'অনুসন্ধান ও ফিল্টার';

  @override
  String get onboardingStepSearchFilterDesc =>
      'বিভাগ বা ডর্ম অবস্থান অনুযায়ী আপনার প্রয়োজনীয় জিনিস খুঁজুন।';

  @override
  String get onboardingStepChatSecurely => 'নিরাপদে চ্যাট করুন';

  @override
  String get onboardingStepChatSecurelyDesc =>
      'প্রশ্ন জিজ্ঞাসা এবং দরকষাকষির জন্য অ্যাপে সরাসরি বিক্রেতাকে মেসেজ করুন।';

  @override
  String get onboardingStepMeetOnCampus => 'ক্যাম্পাসে দেখা করুন';

  @override
  String get onboardingStepMeetOnCampusDesc =>
      'স্টুডেন্ট ইউনিয়নের মতো নির্ধারিত ক্যাম্পাস স্পটে নিরাপদ বিনিময়।';

  @override
  String get onboardingTitle3 => 'সেকেন্ডে বিক্রি করুন';

  @override
  String get onboardingDescription3 =>
      'আপনার অব্যবহৃত জিনিস নগদে পরিণত করুন। আপনার ক্যাম্পাসের শিক্ষার্থীদের কাছে পোস্ট করুন।';

  @override
  String get onboardingStepSnapPhoto => 'ছবি তুলুন';

  @override
  String get onboardingStepSnapPhotoDesc =>
      'অ্যাপে সরাসরি আপনার আইটেমের একটি পরিষ্কার ছবি তুলুন।';

  @override
  String get onboardingStepSetPrice => 'আপনার মূল্য নির্ধারণ করুন';

  @override
  String get onboardingStepSetPriceDesc =>
      'একটি বিবরণ যোগ করুন এবং শিক্ষার্থীদের জন্য একটি ন্যায্য মূল্য নির্ধারণ করুন।';

  @override
  String get onboardingStepMeetDeal =>
      'নিরাপদে চ্যাট করুন এবং কাছাকাছি একটি নিরাপদ মিটআপ স্পট ঠিক করুন।';

  @override
  String get statusLabel => 'স্ট্যাটাস';

  @override
  String get studentVerified => 'শিক্ষার্থী যাচাইকৃত';

  @override
  String get getStarted => 'শুরু করুন';

  @override
  String get forStudentsOnly => 'শুধুমাত্র শিক্ষার্থীদের জন্য';

  @override
  String get markAsSold => 'বিক্রি হিসেবে চিহ্নিত করুন';

  @override
  String get confirmMarkAsSold =>
      'আপনি কি নিশ্চিত এই তালিকাটি বিক্রি হিসেবে চিহ্নিত করতে চান?';

  @override
  String get markAsSoldWarning =>
      'এটি সমস্ত অপেক্ষমাণ অফার বাতিল করবে এবং ক্রেতাদের জানাবে।';

  @override
  String get listingMarkedAsSold => 'তালিকা বিক্রি হিসেবে চিহ্নিত হয়েছে!';

  @override
  String get failedToLoadMessages => 'বার্তা লোড করতে ব্যর্থ';

  @override
  String get noMessagesYet => 'এখনো কোনো বার্তা নেই';

  @override
  String get startTheConversation => 'কথোপকথন শুরু করুন!';

  @override
  String get locationUnavailable => 'অবস্থান পাওয়া যায়নি';

  @override
  String get sharedLocation => 'শেয়ার করা অবস্থান';

  @override
  String get imageUnavailable => 'ছবি পাওয়া যায়নি';

  @override
  String get online => 'অনলাইন';

  @override
  String get offline => 'অফলাইন';

  @override
  String get isTyping => 'টাইপ করছে...';

  @override
  String get noConversationsYet => 'এখনো কোনো কথোপকথন নেই';

  @override
  String get startChattingWithSellers => 'বিক্রেতাদের সাথে চ্যাট শুরু করুন!';

  @override
  String get failedToLoadConversations => 'কথোপকথন লোড করতে ব্যর্থ';

  @override
  String get yesterday => 'গতকাল';

  @override
  String get newLabel => 'নতুন';

  @override
  String get makeAnOffer => 'একটি অফার করুন';

  @override
  String get messageHint => 'বার্তা...';

  @override
  String get contactForPrice => 'মূল্যের জন্য যোগাযোগ করুন';

  @override
  String get viewListing => 'তালিকা দেখুন';

  @override
  String get markSold => 'বিক্রি চিহ্নিত';

  @override
  String get quickReplyStillAvailable => 'হ্যাঁ, এখনো আছে';

  @override
  String get quickReplyWhereToMeet => 'কোথায় দেখা করব?';

  @override
  String get quickReplyPriceNegotiable => 'দাম নেগোশিয়েবল?';

  @override
  String get quickReplyImHere => 'আমি এখানে';

  @override
  String get safetyTipPublicPlaces =>
      'নিরাপত্তা টিপ: সবসময় লাইব্রেরির মতো পাবলিক জায়গায় দেখা করুন।';

  @override
  String get maxPhotosWarning => 'আপনি সর্বোচ্চ ১০টি ছবি আপলোড করতে পারবেন';

  @override
  String get stepOneOfFour => 'ধাপ ১ / ৪';

  @override
  String get twentyFivePercentCompleted => '২৫% সম্পন্ন';

  @override
  String get addPhotos => 'ছবি যোগ করুন';

  @override
  String get addPhotosSubtitle =>
      'সর্বোচ্চ ১০টি ছবি আপলোড করুন। কভার হিসেবে সেরা ছবিটি বেছে নিন।';

  @override
  String get quickTip => 'দ্রুত টিপ';

  @override
  String get lightingTip =>
      'ভালো আলো আইটেম ৫০% দ্রুত বিক্রি করতে সাহায্য করে! জানালার কাছে প্রাকৃতিক আলো ব্যবহার করুন।';

  @override
  String get coverPhoto => 'কভার ছবি';

  @override
  String get addCoverPhoto => 'কভার ছবি যোগ করুন';

  @override
  String get addMore => 'আরও যোগ করুন';

  @override
  String get addDetails => 'বিস্তারিত যোগ করুন';

  @override
  String get stepTwoOfThree => 'ধাপ ২ / ৩';

  @override
  String get itemInformation => 'আইটেম তথ্য';

  @override
  String get itemInfoSubtitle =>
      'ক্রেতাদের আপনার আইটেম খুঁজে পেতে সাহায্য করতে বিবরণ পূরণ করুন।';

  @override
  String get selectCategory => 'একটি বিভাগ নির্বাচন করুন';

  @override
  String get conditionNew => 'নতুন';

  @override
  String get conditionLikeNew => 'প্রায় নতুন';

  @override
  String get conditionGood => 'ভালো';

  @override
  String get conditionFair => 'মোটামুটি';

  @override
  String get whatAreYouSellingHint => 'আপনি কী বিক্রি করছেন?';

  @override
  String get descriptionHint =>
      'আপনি কী বিক্রি করছেন তা বর্ণনা করুন (যেমন, লেখক, সংস্করণ, নির্দিষ্ট ত্রুটি)...';

  @override
  String get bookDetails => 'বইয়ের বিবরণ';

  @override
  String get bookDetailsSubtitle =>
      'শিক্ষার্থীদের তাদের স্তরের জন্য সঠিক বই খুঁজে পেতে সাহায্য করুন।';

  @override
  String get educationLevel => 'শিক্ষা স্তর';

  @override
  String get priceAndPickup => 'মূল্য ও পিকআপ';

  @override
  String get pricePickupSubtitle =>
      'একটি ন্যায্য মূল্য নির্ধারণ করুন এবং ক্যাম্পাসে একটি নিরাপদ মিটিং স্পট বেছে নিন।';

  @override
  String get priceLabel => 'মূল্য';

  @override
  String get openToOffers => 'অফারের জন্য উন্মুক্ত?';

  @override
  String get allowBuyersSuggestPrice =>
      'ক্রেতাদের একটি মূল্য প্রস্তাব করতে দিন';

  @override
  String get meetingSpot => 'মিটিং স্পট';

  @override
  String get safetyTip => 'নিরাপত্তা টিপ';

  @override
  String get meetingSpotSafetyTip =>
      'স্টুডেন্ট ইউনিয়ন বা লাইব্রেরির মতো পাবলিক এলাকায় দেখা করুন। ডর্ম রুম এড়িয়ে চলুন।';

  @override
  String get enterPickupLocationHint => 'পিকআপ অবস্থান লিখুন';

  @override
  String get campusLibrary => 'ক্যাম্পাস লাইব্রেরি';

  @override
  String get studentCenter => 'স্টুডেন্ট সেন্টার';

  @override
  String get mainGate => 'প্রধান গেট';

  @override
  String get cafeteria => 'ক্যাফেটেরিয়া';

  @override
  String get priceRequired => 'মূল্য লিখুন';

  @override
  String get validPriceRequired => '০ এর বেশি একটি বৈধ মূল্য লিখুন';

  @override
  String get publishListing => 'তালিকা প্রকাশ করুন';

  @override
  String get confirmation => 'নিশ্চিতকরণ';

  @override
  String get listingSubmitted => 'তালিকা জমা দেওয়া হয়েছে!';

  @override
  String get listingSubmittedDescription =>
      'আপনার তালিকা পর্যালোচনার জন্য জমা দেওয়া হয়েছে। আমাদের টিম এটি পর্যালোচনা করবে এবং অনুমোদিত হলে আপনাকে জানানো হবে।';

  @override
  String get pendingApproval => 'অনুমোদন অপেক্ষমাণ';

  @override
  String get listingBeingReviewed => 'আপনার তালিকা পর্যালোচনা করা হচ্ছে';

  @override
  String get usuallyWithin24Hours => 'সাধারণত ২৪ ঘণ্টার মধ্যে';

  @override
  String get wellNotifyYou => 'আমরা আপনাকে জানাব';

  @override
  String get visibleAfterApproval => 'অনুমোদনের পর দৃশ্যমান';

  @override
  String get backToHome => 'হোমে ফিরে যান';

  @override
  String get viewMyListings => 'আমার তালিকা দেখুন';

  @override
  String get latestAds => 'সর্বশেষ বিজ্ঞাপন';

  @override
  String get seeAll => 'সব দেখুন';

  @override
  String get listingDataNotLoaded => 'তালিকার ডেটা এখনো লোড হয়নি';

  @override
  String get sellerInfoNotAvailable => 'বিক্রেতার তথ্য পাওয়া যায়নি';

  @override
  String get listingDeletedSuccess => 'তালিকা সফলভাবে মুছে ফেলা হয়েছে';

  @override
  String get listingMarkedAsSoldMsg => 'তালিকা বিক্রি হিসেবে চিহ্নিত';

  @override
  String get adDetails => 'বিজ্ঞাপন বিবরণ';

  @override
  String get shareCheckItOut => 'ক্যাম্পাসহাব প্রোতে দেখুন!';

  @override
  String get seeMap => 'মানচিত্র দেখুন';

  @override
  String get locationNotSet => 'অবস্থান সেট করা হয়নি';

  @override
  String get noDescriptionAvailable => 'কোনো বিবরণ পাওয়া যায়নি।';

  @override
  String get safetyTipsForDeal => 'ডিলের জন্য নিরাপত্তা টিপস';

  @override
  String get safetyTipMeetSeller =>
      'বিক্রেতার সাথে দেখা করতে একটি নিরাপদ স্থান ব্যবহার করুন';

  @override
  String get safetyTipAvoidCash => 'নগদ লেনদেন এড়িয়ে চলুন';

  @override
  String get safetyTipUnrealisticOffers => 'অবাস্তব অফার থেকে সাবধান';

  @override
  String get viewProfile => 'প্রোফাইল দেখুন';

  @override
  String get ratingAndReview => 'রেটিং ও রিভিউ';

  @override
  String get couldNotLoadReviews => 'রিভিউ লোড করা যায়নি';

  @override
  String get noReviewsYet => 'এখনো কোনো রিভিউ নেই';

  @override
  String get writeAReview => 'একটি রিভিউ লিখুন';

  @override
  String get promoteListing => 'তালিকা প্রচার করুন';

  @override
  String get shareOnWhatsApp => 'হোয়াটসঅ্যাপে শেয়ার করুন';

  @override
  String get foundOnCampusHub => 'ক্যাম্পাসহাব প্রোতে পাওয়া গেছে 📚';

  @override
  String get buyNow => 'এখনই কিনুন';

  @override
  String get sendMessage => 'বার্তা পাঠান';

  @override
  String get deleteListing => 'তালিকা মুছুন';

  @override
  String get confirmDeleteListing =>
      'আপনি কি নিশ্চিত এই তালিকাটি মুছে ফেলতে চান? এই ক্রিয়া পূর্বাবস্থায় ফেরানো যাবে না।';

  @override
  String get editListing => 'তালিকা সম্পাদনা';

  @override
  String get searchDreamBooksHint => 'আপনার স্বপ্নের বই খুঁজুন';

  @override
  String get searchForBooksPrompt => 'বই, বিক্রেতা, বা আইটেম খুঁজুন';

  @override
  String get startTypingDiscover =>
      'দুর্দান্ত ডিল আবিষ্কার করতে টাইপ শুরু করুন';

  @override
  String get recentSearches => 'সাম্প্রতিক অনুসন্ধান';

  @override
  String get searching => 'অনুসন্ধান করা হচ্ছে...';

  @override
  String get somethingWentWrong => 'কিছু ভুল হয়েছে';

  @override
  String get noResultsFound => 'কোনো ফলাফল পাওয়া যায়নি';

  @override
  String get tryDifferentKeywords => 'ভিন্ন কীওয়ার্ড দিয়ে অনুসন্ধান করুন';

  @override
  String get listingUpdatedPending =>
      'তালিকা আপডেট হয়েছে। এটি এখন অ্যাডমিন অনুমোদনের অপেক্ষায়।';

  @override
  String get listingUpdatedSuccess => 'তালিকা সফলভাবে আপডেট হয়েছে';

  @override
  String get basicInfo => 'মৌলিক তথ্য';

  @override
  String get titleRequired => 'একটি শিরোনাম লিখুন';

  @override
  String get categoryRequired => 'একটি বিভাগ নির্বাচন করুন';

  @override
  String get conditionRequired => 'একটি অবস্থা নির্বাচন করুন';

  @override
  String get descriptionRequired => 'একটি বিবরণ লিখুন';

  @override
  String get saveChanges => 'পরিবর্তন সংরক্ষণ';

  @override
  String get listingPromotedSuccess => 'তালিকা সফলভাবে প্রচারিত হয়েছে!';

  @override
  String get previewOnFeed => 'ফিডে প্রিভিউ';

  @override
  String get featuredBadge => 'বৈশিষ্ট্যযুক্ত';

  @override
  String get previewDescription =>
      'এভাবে আপনার তালিকা অন্যান্য শিক্ষার্থীদের কাছে প্রদর্শিত হবে।';

  @override
  String get whyFeature => 'কেন ফিচার?';

  @override
  String get fiveXMoreViews => '৫গুণ বেশি\nভিউ';

  @override
  String get sellTwoXFaster => '২গুণ দ্রুত\nবিক্রি';

  @override
  String get buildTrust => 'বিশ্বাস\nগড়ুন';

  @override
  String get selectDuration => 'সময়কাল নির্বাচন';

  @override
  String get threeDays => '৩ দিন';

  @override
  String get sevenDays => '৭ দিন';

  @override
  String get thirtyDays => '৩০ দিন';

  @override
  String get goodForQuickSales => 'দ্রুত বিক্রির জন্য ভালো';

  @override
  String get recommendedDuration => 'প্রস্তাবিত সময়কাল';

  @override
  String get maximumExposure => 'সর্বোচ্চ এক্সপোজার';

  @override
  String get mostPopular => 'সবচেয়ে জনপ্রিয়';

  @override
  String get bestValue => 'সেরা মূল্য';

  @override
  String get myProfile => 'আমার প্রোফাইল';

  @override
  String get filterAndSort => 'ফিল্টার ও সর্ট';

  @override
  String get searchWithKeywords => 'কীওয়ার্ড দিয়ে অনুসন্ধান...';

  @override
  String get recommended => 'প্রস্তাবিত';

  @override
  String get newestFirst => 'নতুন প্রথমে';

  @override
  String get priceLowToHigh => 'মূল্য: কম থেকে বেশি';

  @override
  String get priceHighToLow => 'মূল্য: বেশি থেকে কম';

  @override
  String get filtered => 'ফিল্টারকৃত';

  @override
  String get filter => 'ফিল্টার';

  @override
  String get featuredSection => 'বৈশিষ্ট্যযুক্ত';

  @override
  String get staffPicks => 'স্টাফ পিকস';

  @override
  String get viewAll => 'সব দেখুন';

  @override
  String get dealsNearYou => 'আপনার কাছের ডিল';

  @override
  String get dealsNearYouMap => 'মানচিত্র';

  @override
  String get dealsNearYouRadiusKm => '১০ কিমি ব্যাসার্ধ';

  @override
  String get dealsNearYouLocationOff => 'লোকেশন বন্ধ';

  @override
  String get dealsNearYouLocationHint =>
      'কাছাকাছি তালিকা দেখতে লোকেশন চালু করুন।';

  @override
  String get dealsNearYouOpenSettings => 'সেটিংস';

  @override
  String get dealsNearYouEmpty =>
      'এই এলাকায় এখন কোনো ডিল নেই। পরে আবার দেখুন।';

  @override
  String dealsNearYouDistMiles(String miles) {
    return '$miles মাইল';
  }

  @override
  String get mapSearchDealsHint => 'কাছাকাছি তালিকা খুঁজুন…';

  @override
  String mapDealsCountNearby(int count) {
    return 'কাছে $countটি ডিল';
  }

  @override
  String get mapNoMatchingDeals => 'আপনার অনুসন্ধানের সাথে মিলছে না';

  @override
  String get mapRecenter => 'আমার অবস্থান';

  @override
  String get mapFitAll => 'সব পিন দেখান';

  @override
  String get mapSwipeForMore => 'আরো দেখতে সোয়াইপ করুন';

  @override
  String get createNewListing => 'নতুন তালিকা তৈরি করুন';

  @override
  String get removeFromSaved => 'সংরক্ষিত থেকে সরান';

  @override
  String get saveToWishlist => 'ইচ্ছা তালিকায় সংরক্ষণ করুন';

  @override
  String get fixedPriceType => ' (নির্ধারিত)';

  @override
  String get notSpecified => 'নির্দিষ্ট নয়';

  @override
  String get drawerHome => 'হোম';

  @override
  String get markAllAsRead => 'সব পঠিত হিসেবে চিহ্নিত করুন';

  @override
  String get failedToLoadNotifications => 'বিজ্ঞপ্তি লোড করতে ব্যর্থ';

  @override
  String get allCaughtUp => 'সব দেখা হয়ে গেছে!';

  @override
  String get noNewNotifications => 'এখন আপনার জন্য কোনো নতুন বিজ্ঞপ্তি নেই।';

  @override
  String get today => 'আজ';

  @override
  String get thisWeek => 'এই সপ্তাহে';

  @override
  String get older => 'পুরনো';

  @override
  String get viewDetails => 'বিস্তারিত দেখুন';

  @override
  String get justNow => 'এইমাত্র';

  @override
  String get listingApproved => 'তালিকা অনুমোদিত';

  @override
  String get listingRejected => 'তালিকা প্রত্যাখ্যাত';

  @override
  String get priceDropAlert => 'মূল্য হ্রাস সতর্কতা';

  @override
  String get accountWarning => 'অ্যাকাউন্ট সতর্কতা';

  @override
  String get offerRequest => 'অফার অনুরোধ';

  @override
  String get offerAccepted => 'অফার গৃহীত!';

  @override
  String get offerDeclined => 'অফার প্রত্যাখ্যাত';

  @override
  String get counterOfferSent => 'পাল্টা অফার পাঠানো হয়েছে!';

  @override
  String get listing => 'তালিকা';

  @override
  String get expires => 'মেয়াদ শেষ';

  @override
  String get askingPriceLabel => 'চাওয়া মূল্য';

  @override
  String get offeredPrice => 'প্রস্তাবিত মূল্য';

  @override
  String get counterOffer => 'পাল্টা অফার';

  @override
  String get acceptOffer => 'অফার গ্রহণ';

  @override
  String get declineOffer => 'অফার প্রত্যাখ্যান';

  @override
  String get confirmDeclineOffer => 'এই অফার প্রত্যাখ্যান করবেন?';

  @override
  String get leaveAReview => 'একটি রিভিউ দিন';

  @override
  String get counterOfferTitle => 'পাল্টা অফার';

  @override
  String get enterCounterPrice => 'আপনার পাল্টা মূল্য লিখুন:';

  @override
  String get sendCounter => 'পাল্টা পাঠান';

  @override
  String get offerSentSuccess => 'অফার সফলভাবে পাঠানো হয়েছে!';

  @override
  String get yourOffer => 'আপনার অফার';

  @override
  String get sendOffer => 'অফার পাঠান';

  @override
  String get myListings => 'আমার তালিকা';

  @override
  String get favorites => 'পছন্দের';

  @override
  String get reviews => 'রিভিউ';

  @override
  String get guestUser => 'অতিথি ব্যবহারকারী';

  @override
  String get aboutSeller => 'বিক্রেতা সম্পর্কে';

  @override
  String get memberSince => 'সদস্য হয়েছেন';

  @override
  String get notSet => 'সেট করা হয়নি';

  @override
  String get account => 'অ্যাকাউন্ট';

  @override
  String get accountOptions => 'অ্যাকাউন্ট বিকল্প';

  @override
  String get blockedUsers => 'ব্লক করা ব্যবহারকারী';

  @override
  String get clickHere => 'এখানে ক্লিক করুন';

  @override
  String get noItemsFound => 'কোনো আইটেম পাওয়া যায়নি।';

  @override
  String get usernameInvalidChars =>
      'শুধুমাত্র অক্ষর, সংখ্যা এবং আন্ডারস্কোর অনুমোদিত';

  @override
  String get usernameMinLength => 'ইউজারনেম কমপক্ষে ৩ অক্ষরের হতে হবে';

  @override
  String get usernameMaxLength => 'ইউজারনেম ২০ অক্ষরের বেশি হতে পারে না';

  @override
  String get currentUsernameMessage => 'এটি আপনার বর্তমান ইউজারনেম';

  @override
  String get usernameAvailable => 'ইউজারনেম পাওয়া যাচ্ছে!';

  @override
  String get usernameTaken => 'ইউজারনেম ইতিমধ্যে নেওয়া হয়েছে';

  @override
  String get chooseAvailableUsername => 'একটি উপলব্ধ ইউজারনেম বেছে নিন';

  @override
  String get changeProfilePicture => 'প্রোফাইল ছবি পরিবর্তন';

  @override
  String get takeAPhoto => 'একটি ছবি তুলুন';

  @override
  String get useYourCamera => 'আপনার ক্যামেরা ব্যবহার করুন';

  @override
  String get chooseFromGallery => 'গ্যালারি থেকে বেছে নিন';

  @override
  String get selectExistingPhoto => 'একটি বিদ্যমান ছবি নির্বাচন করুন';

  @override
  String get profilePictureUpdated => 'প্রোফাইল ছবি আপডেট হয়েছে!';

  @override
  String get editProfile => 'প্রোফাইল সম্পাদনা';

  @override
  String get tapToChangePhoto => 'ছবি পরিবর্তন করতে ট্যাপ করুন';

  @override
  String get fullNameHint => 'পুরো নাম';

  @override
  String get nameIsRequired => 'নাম আবশ্যক';

  @override
  String get username => 'ব্যবহারকারীর নাম';

  @override
  String get phoneNumber => 'ফোন নম্বর';

  @override
  String get validPhoneNumber => 'একটি বৈধ ফোন নম্বর লিখুন';

  @override
  String get campusDormLocation => 'ক্যাম্পাস / ডর্ম অবস্থান';

  @override
  String get bio => 'বায়ো';

  @override
  String get bioMaxLength => 'বায়ো ৩০০ অক্ষর বা তার কম হতে হবে';

  @override
  String get sellerProfile => 'বিক্রেতার প্রোফাইল';

  @override
  String get unknownSeller => 'অজানা বিক্রেতা';

  @override
  String activeAdsBy(String sellerName) {
    return '$sellerName এর সক্রিয় বিজ্ঞাপন';
  }

  @override
  String get invalidUserId => 'অবৈধ ব্যবহারকারী আইডি';

  @override
  String get active => 'সক্রিয়';

  @override
  String get rating => 'রেটিং';

  @override
  String get reportListing => 'তালিকা রিপোর্ট করুন';

  @override
  String get reportUser => 'ব্যবহারকারী রিপোর্ট করুন';

  @override
  String get reportMessage => 'বার্তা রিপোর্ট করুন';

  @override
  String get helpKeepCommunitySafe => 'কমিউনিটি নিরাপদ রাখতে সাহায্য করুন';

  @override
  String get whyReporting => 'আপনি কেন এটি রিপোর্ট করছেন?';

  @override
  String get additionalDetails => 'অতিরিক্ত বিবরণ';

  @override
  String get tellUsMoreHint => 'সমস্যাটি সম্পর্কে আরও বলুন...';

  @override
  String get submitReport => 'রিপোর্ট জমা দিন';

  @override
  String get reportSubmittedSuccess =>
      'রিপোর্ট জমা দেওয়া হয়েছে। আমরা শীঘ্রই এটি পর্যালোচনা করব।';

  @override
  String get pleaseSelectRating => 'একটি রেটিং নির্বাচন করুন';

  @override
  String get reviewSubmittedSuccess => 'রিভিউ সফলভাবে জমা দেওয়া হয়েছে!';

  @override
  String get ratingPoor => 'খারাপ';

  @override
  String get ratingFair => 'মোটামুটি';

  @override
  String get ratingGood => 'ভালো';

  @override
  String get ratingVeryGood => 'অনেক ভালো';

  @override
  String get ratingExcellent => 'চমৎকার';

  @override
  String get howWasYourExperience => 'আপনার অভিজ্ঞতা কেমন ছিল?';

  @override
  String get tapStarToRate => 'বিক্রেতাকে রেট করতে একটি তারায় ট্যাপ করুন';

  @override
  String get writeYourFeedback => 'আপনার মতামত লিখুন';

  @override
  String get optionalLabel => 'ঐচ্ছিক';

  @override
  String get reviewHintText =>
      'এই বিক্রেতার সাথে আপনার অভিজ্ঞতা শেয়ার করুন...\n\nআইটেমটি কি বর্ণনা অনুযায়ী ছিল? বিক্রেতা কি সাড়া দিয়েছিলেন?';

  @override
  String get submitReview => 'রিভিউ জমা দিন';

  @override
  String get myWishlist => 'আমার ইচ্ছা তালিকা';

  @override
  String get wishlistEmpty => 'আপনার ইচ্ছা তালিকা খালি';

  @override
  String get wishlistEmptySubtitle =>
      'আপনি যে আইটেমগুলি দেখতে বা পরে কিনতে চান সেগুলি সংরক্ষণ করুন';

  @override
  String get exploreListings => 'তালিকা অন্বেষণ করুন';

  @override
  String askingPrice(String price) {
    return 'চাহিদা: \$$price';
  }

  @override
  String percentOfAskingPrice(String percent) {
    return '$percent% চাহিদা মূল্যের';
  }

  @override
  String roundOfThree(int round) {
    return 'রাউন্ড $round/৩';
  }

  @override
  String acceptOfferConfirm(String amount) {
    return '\$$amount এই অফারটি গ্রহণ করবেন?';
  }

  @override
  String daysAgo(int days) {
    return '$days দিন আগে';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours ঘন্টা আগে';
  }

  @override
  String minutesAgo(int minutes) {
    return '$minutes মিনিট আগে';
  }

  @override
  String daysHoursRemaining(int days, int hours) {
    return '$days দিন $hours ঘন্টা বাকি';
  }

  @override
  String hoursMinutesRemaining(int hours, int minutes) {
    return '$hours ঘন্টা $minutes মিনিট বাকি';
  }

  @override
  String minutesRemaining(int minutes) {
    return '$minutes মিনিট বাকি';
  }

  @override
  String itemLabel(String title) {
    return 'আইটেম: $title';
  }

  @override
  String photosSelected(int count) {
    return '$countটি ছবি নির্বাচিত';
  }

  @override
  String get clearAll => 'সব মুছুন';

  @override
  String get pleaseSelectPhoto => 'অন্তত একটি ছবি নির্বাচন করুন';

  @override
  String get nextDetails => 'পরবর্তী: বিবরণ';

  @override
  String get semester => 'সেমিস্টার';

  @override
  String get classLabel => 'ক্লাস';

  @override
  String get stream => 'Stream';

  @override
  String get subjectOptional => 'বিষয় (ঐচ্ছিক)';

  @override
  String get subjectHint => 'যেমন গণিত, পদার্থবিদ্যা, বাংলা...';

  @override
  String get bookType => 'বইয়ের ধরন';

  @override
  String get nextPricePickup => 'পরবর্তী: মূল্য ও পিকআপ';

  @override
  String get appearance => 'থিম';

  @override
  String get language => 'ভাষা';

  @override
  String get english => 'English';

  @override
  String get bengali => 'বাংলা';

  @override
  String get chooseTheme => 'থিম বাছাই করুন';

  @override
  String get chooseLanguage => 'ভাষা বাছাই করুন';

  @override
  String get systemDefault => 'সিস্টেম ডিফল্ট';

  @override
  String get general => 'সাধারণ';

  @override
  String get appVersion => 'অ্যাপ সংস্করণ';

  @override
  String get similarListings => 'একই ধরনের বিজ্ঞাপন';
}

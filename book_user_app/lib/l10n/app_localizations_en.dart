// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CampusHub';

  @override
  String get appName => 'CampusHub Pro';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get changePassword => 'Change Password';

  @override
  String get name => 'Name';

  @override
  String get search => 'Search';

  @override
  String get listings => 'Listings';

  @override
  String get chat => 'Chat';

  @override
  String get profile => 'Profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemMode => 'System Default';

  @override
  String get logout => 'Logout';

  @override
  String get createListing => 'Create Listing';

  @override
  String get title => 'Title';

  @override
  String get description => 'Description';

  @override
  String get price => 'Price';

  @override
  String get category => 'Category';

  @override
  String get condition => 'Condition';

  @override
  String get makeOffer => 'Make Offer';

  @override
  String get wishlist => 'Wishlist';

  @override
  String get noListingsFound => 'No listings found';

  @override
  String get noMessages => 'No messages yet';

  @override
  String get send => 'Send';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get logIn => 'Log In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signOut => 'Sign Out';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get all => 'All';

  @override
  String get reset => 'Reset';

  @override
  String get clear => 'Clear';

  @override
  String get loading => 'Loading...';

  @override
  String get no => 'No';

  @override
  String get home => 'Home';

  @override
  String get saved => 'Saved';

  @override
  String get add => 'Add';

  @override
  String get messages => 'Messages';

  @override
  String get report => 'Report';

  @override
  String get location => 'Location';

  @override
  String get available => 'Available';

  @override
  String get sold => 'Sold';

  @override
  String get free => 'FREE';

  @override
  String get help => 'Help';

  @override
  String get follow => 'Follow';

  @override
  String get message => 'Message';

  @override
  String get accept => 'Accept';

  @override
  String get decline => 'Decline';

  @override
  String get pending => 'Pending';

  @override
  String get expired => 'Expired';

  @override
  String get accepted => 'Accepted';

  @override
  String get declined => 'Declined';

  @override
  String get countered => 'Countered';

  @override
  String get counter => 'Counter';

  @override
  String get featured => 'Featured';

  @override
  String get promoted => 'Promoted';

  @override
  String get detail => 'Detail';

  @override
  String get optional => '(optional)';

  @override
  String get unknown => 'Unknown';

  @override
  String get loginSubtitle => 'The exclusive marketplace for students.';

  @override
  String get studentLogin => 'Student Login';

  @override
  String get enterEmailHint => 'Enter your email';

  @override
  String get enterPasswordHint => 'Enter your password';

  @override
  String get noAccountPrompt => 'Don\'t have an account? ';

  @override
  String get loginEmailRequired => 'Please enter your email';

  @override
  String get validEmailRequired => 'Please enter a valid email address';

  @override
  String get loginPasswordRequired => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get registerSubtitle => 'Join the exclusive student marketplace.';

  @override
  String get studentRegistration => 'Student Registration';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterFullNameHint => 'Enter your full name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get enterStudentEmailHint => 'Enter your student email';

  @override
  String get createPasswordHint => 'Create a password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Confirm your password';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get fullNameRequired => 'Please enter your full name';

  @override
  String get emailAddressRequired => 'Please enter your email address';

  @override
  String get createPasswordRequired => 'Please create a password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get accountCreatedVerifyEmail =>
      'Account created! Please verify your email.';

  @override
  String get forgotPasswordTitle => 'Forgot Password?';

  @override
  String get forgotPasswordDescription =>
      'Don\'t worry! It happens. Please enter the email address associated with your account.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get resetLinkSent => 'Password reset link sent to your email';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetPasswordDescription =>
      'Please enter your new password below.';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get enterNewPasswordHint => 'Enter new password';

  @override
  String get confirmNewPasswordHint => 'Confirm new password';

  @override
  String get resetPasswordButton => 'Reset Password';

  @override
  String get newPasswordRequired => 'Please enter a new password';

  @override
  String get passwordResetSuccess =>
      'Password reset successfully! Please login.';

  @override
  String get verifyYourEmail => 'Verify your email';

  @override
  String get verifyEmailDescription =>
      'We\'ve sent a verification link to your email address. Please click the link to verify your account.';

  @override
  String get resendEmail => 'Resend Email';

  @override
  String get verifiedMyEmail => 'I\'ve verified my email';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get emailVerifiedSuccess => 'Email verified successfully!';

  @override
  String get verificationEmailSent => 'Verification email sent!';

  @override
  String get onboardingTitle1 => 'Your Campus.\nYour Marketplace.';

  @override
  String get onboardingDescription1 =>
      'Turn your old textbooks into cash and find great deals on dorm essentials. Safe, local, and student-verified.';

  @override
  String get onboardingTitle2 => 'Shop Your Campus';

  @override
  String get onboardingDescription2 =>
      'Safe, local deals from students near you. Buy textbooks, furniture, and more.';

  @override
  String get onboardingStepSearchFilter => 'Search & Filter';

  @override
  String get onboardingStepSearchFilterDesc =>
      'Find exactly what you need by category or dorm location.';

  @override
  String get onboardingStepChatSecurely => 'Chat Securely';

  @override
  String get onboardingStepChatSecurelyDesc =>
      'Message sellers directly in-app to ask questions and negotiate.';

  @override
  String get onboardingStepMeetOnCampus => 'Meet on Campus';

  @override
  String get onboardingStepMeetOnCampusDesc =>
      'Safe exchange at designated campus spots like the student union.';

  @override
  String get onboardingTitle3 => 'Sell in Seconds';

  @override
  String get onboardingDescription3 =>
      'Turn your clutter into cash. Post textbooks, gadgets, and gear to students on your campus.';

  @override
  String get onboardingStepSnapPhoto => 'Snap a Photo';

  @override
  String get onboardingStepSnapPhotoDesc =>
      'Take a clear picture of your item directly in the app.';

  @override
  String get onboardingStepSetPrice => 'Set Your Price';

  @override
  String get onboardingStepSetPriceDesc =>
      'Add a description and set a fair price for students.';

  @override
  String get onboardingStepMeetDeal =>
      'Chat securely and arrange a safe meetup spot nearby.';

  @override
  String get statusLabel => 'STATUS';

  @override
  String get studentVerified => 'Student Verified';

  @override
  String get getStarted => 'Get Started';

  @override
  String get forStudentsOnly => 'For students only';

  @override
  String get markAsSold => 'Mark as Sold';

  @override
  String get confirmMarkAsSold =>
      'Are you sure you want to mark this listing as sold?';

  @override
  String get markAsSoldWarning =>
      'This will cancel all pending offers and notify buyers.';

  @override
  String get listingMarkedAsSold => 'Listing marked as sold!';

  @override
  String get failedToLoadMessages => 'Failed to load messages';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get startTheConversation => 'Start the conversation!';

  @override
  String get locationUnavailable => 'Location unavailable';

  @override
  String get sharedLocation => 'Shared Location';

  @override
  String get imageUnavailable => 'Image unavailable';

  @override
  String get online => 'online';

  @override
  String get offline => 'offline';

  @override
  String get isTyping => 'is typing...';

  @override
  String get noConversationsYet => 'No conversations yet';

  @override
  String get startChattingWithSellers => 'Start chatting with sellers!';

  @override
  String get failedToLoadConversations => 'Failed to load conversations';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get newLabel => 'New';

  @override
  String get makeAnOffer => 'Make an Offer';

  @override
  String get messageHint => 'Message...';

  @override
  String get contactForPrice => 'Contact for price';

  @override
  String get viewListing => 'View Listing';

  @override
  String get markSold => 'Mark Sold';

  @override
  String get quickReplyStillAvailable => 'Yes, still available';

  @override
  String get quickReplyWhereToMeet => 'Where to meet?';

  @override
  String get quickReplyPriceNegotiable => 'Is price negotiable?';

  @override
  String get quickReplyImHere => 'I\'m here';

  @override
  String get safetyTipPublicPlaces =>
      'Safety Tip: Always meet in public places like the library.';

  @override
  String get maxPhotosWarning => 'You can only upload up to 10 photos';

  @override
  String get stepOneOfFour => 'Step 1 of 4';

  @override
  String get twentyFivePercentCompleted => '25% completed';

  @override
  String get addPhotos => 'Add Photos';

  @override
  String get addPhotosSubtitle =>
      'Upload up to 10 photos. Choose your best shot as the cover.';

  @override
  String get quickTip => 'QUICK TIP';

  @override
  String get lightingTip =>
      'Good lighting helps items sell 50% faster! Try using natural light near a window.';

  @override
  String get coverPhoto => 'Cover Photo';

  @override
  String get addCoverPhoto => 'Add Cover Photo';

  @override
  String get addMore => 'Add More';

  @override
  String get addDetails => 'Add Details';

  @override
  String get stepTwoOfThree => 'Step 2 of 3';

  @override
  String get itemInformation => 'Item Information';

  @override
  String get itemInfoSubtitle =>
      'Fill in the details to help buyers find your item.';

  @override
  String get selectCategory => 'Select a category';

  @override
  String get conditionNew => 'New';

  @override
  String get conditionLikeNew => 'Like New';

  @override
  String get conditionGood => 'Good';

  @override
  String get conditionFair => 'Fair';

  @override
  String get whatAreYouSellingHint => 'What are you selling?';

  @override
  String get descriptionHint =>
      'Describe what you are selling (e.g., Author, Edition, specific flaws)...';

  @override
  String get bookDetails => 'Book Details';

  @override
  String get bookDetailsSubtitle =>
      'Help students find the right book for their level.';

  @override
  String get educationLevel => 'Education Level';

  @override
  String get priceAndPickup => 'Price & Pickup';

  @override
  String get pricePickupSubtitle =>
      'Set a fair price and choose a safe meeting spot on campus.';

  @override
  String get priceLabel => 'PRICE';

  @override
  String get openToOffers => 'Open to offers?';

  @override
  String get allowBuyersSuggestPrice => 'Allow buyers to suggest a price';

  @override
  String get meetingSpot => 'Meeting Spot';

  @override
  String get safetyTip => 'Safety Tip';

  @override
  String get meetingSpotSafetyTip =>
      'Meet in public areas like the Student Union or Library. Avoid dorm rooms.';

  @override
  String get enterPickupLocationHint => 'Enter pickup location';

  @override
  String get campusLibrary => 'Campus Library';

  @override
  String get studentCenter => 'Student Center';

  @override
  String get mainGate => 'Main Gate';

  @override
  String get cafeteria => 'Cafeteria';

  @override
  String get priceRequired => 'Please enter a price';

  @override
  String get validPriceRequired => 'Please enter a valid price greater than 0';

  @override
  String get publishListing => 'Publish Listing';

  @override
  String get confirmation => 'Confirmation';

  @override
  String get listingSubmitted => 'Listing Submitted!';

  @override
  String get listingSubmittedDescription =>
      'Your listing has been submitted for review. Our team will review it and you\'ll be notified once it\'s approved.';

  @override
  String get pendingApproval => 'PENDING APPROVAL';

  @override
  String get listingBeingReviewed => 'Your listing is being reviewed';

  @override
  String get usuallyWithin24Hours => 'Usually within 24 hours';

  @override
  String get wellNotifyYou => 'We\'ll notify you';

  @override
  String get visibleAfterApproval => 'Visible after approval';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get viewMyListings => 'View My Listings';

  @override
  String get latestAds => 'Latest Ads';

  @override
  String get seeAll => 'See all';

  @override
  String get listingDataNotLoaded => 'Listing data not loaded yet';

  @override
  String get sellerInfoNotAvailable => 'Seller information not available';

  @override
  String get listingDeletedSuccess => 'Listing deleted successfully';

  @override
  String get listingMarkedAsSoldMsg => 'Listing marked as sold';

  @override
  String get adDetails => 'Ad Details';

  @override
  String get shareCheckItOut => 'Check it out on CampusHub Pro!';

  @override
  String get seeMap => 'see map';

  @override
  String get locationNotSet => 'Location not set';

  @override
  String get noDescriptionAvailable => 'No description available.';

  @override
  String get safetyTipsForDeal => 'Safety tips for deal';

  @override
  String get safetyTipMeetSeller => 'Use a safe location to meet seller';

  @override
  String get safetyTipAvoidCash => 'Avoid cash transactions';

  @override
  String get safetyTipUnrealisticOffers => 'Beware of unrealistic offers';

  @override
  String get viewProfile => 'View profile';

  @override
  String get ratingAndReview => 'Rating & Review';

  @override
  String get couldNotLoadReviews => 'Could not load reviews';

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String get writeAReview => 'Write a Review';

  @override
  String get promoteListing => 'Promote Listing';

  @override
  String get shareOnWhatsApp => 'Share on WhatsApp';

  @override
  String get foundOnCampusHub => 'Found on CampusHub Pro 📚';

  @override
  String get buyNow => 'Buy Now';

  @override
  String get sendMessage => 'Send Message';

  @override
  String get deleteListing => 'Delete Listing';

  @override
  String get confirmDeleteListing =>
      'Are you sure you want to delete this listing? This action cannot be undone.';

  @override
  String get editListing => 'Edit Listing';

  @override
  String get searchDreamBooksHint => 'Search your dream books';

  @override
  String get searchForBooksPrompt => 'Search for books, sellers, or items';

  @override
  String get startTypingDiscover => 'Start typing to discover great deals';

  @override
  String get recentSearches => 'Recent Searches';

  @override
  String get searching => 'Searching...';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get tryDifferentKeywords => 'Try searching with different keywords';

  @override
  String get listingUpdatedPending =>
      'Listing updated. It is now pending admin approval.';

  @override
  String get listingUpdatedSuccess => 'Listing updated successfully';

  @override
  String get basicInfo => 'Basic Info';

  @override
  String get titleRequired => 'Please enter a title';

  @override
  String get categoryRequired => 'Please select a category';

  @override
  String get conditionRequired => 'Please select a condition';

  @override
  String get descriptionRequired => 'Please enter a description';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get listingPromotedSuccess => 'Listing promoted successfully!';

  @override
  String get previewOnFeed => 'PREVIEW ON FEED';

  @override
  String get featuredBadge => 'FEATURED';

  @override
  String get previewDescription =>
      'This is how your listing will appear to other students.';

  @override
  String get whyFeature => 'Why Feature?';

  @override
  String get fiveXMoreViews => '5x More\nViews';

  @override
  String get sellTwoXFaster => 'Sell 2x\nFaster';

  @override
  String get buildTrust => 'Build\nTrust';

  @override
  String get selectDuration => 'Select Duration';

  @override
  String get threeDays => '3 Days';

  @override
  String get sevenDays => '7 Days';

  @override
  String get thirtyDays => '30 Days';

  @override
  String get goodForQuickSales => 'Good for quick sales';

  @override
  String get recommendedDuration => 'Recommended duration';

  @override
  String get maximumExposure => 'Maximum exposure';

  @override
  String get mostPopular => 'Most Popular';

  @override
  String get bestValue => 'Best Value';

  @override
  String get myProfile => 'My Profile';

  @override
  String get filterAndSort => 'Filter & Sort';

  @override
  String get searchWithKeywords => 'Search with keywords...';

  @override
  String get recommended => 'Recommended';

  @override
  String get newestFirst => 'Newest First';

  @override
  String get priceLowToHigh => 'Price: Low to High';

  @override
  String get priceHighToLow => 'Price: High to Low';

  @override
  String get filtered => 'Filtered';

  @override
  String get filter => 'Filter';

  @override
  String get featuredSection => 'Featured';

  @override
  String get staffPicks => 'Staff Picks';

  @override
  String get viewAll => 'View All';

  @override
  String get dealsNearYou => 'Deals Near You';

  @override
  String get dealsNearYouMap => 'Map';

  @override
  String get dealsNearYouRadiusKm => '10 km radius';

  @override
  String get dealsNearYouLocationOff => 'Location is off';

  @override
  String get dealsNearYouLocationHint =>
      'Turn on location to see listings near you.';

  @override
  String get dealsNearYouOpenSettings => 'Settings';

  @override
  String get dealsNearYouEmpty => 'No deals in this area yet. Check back soon.';

  @override
  String dealsNearYouDistMiles(String miles) {
    return '$miles mi';
  }

  @override
  String get mapSearchDealsHint => 'Search nearby listings…';

  @override
  String mapDealsCountNearby(int count) {
    return '$count deals nearby';
  }

  @override
  String get mapNoMatchingDeals => 'No listings match your search';

  @override
  String get mapRecenter => 'My location';

  @override
  String get mapFitAll => 'Fit all pins';

  @override
  String get mapSwipeForMore => 'Swipe for more';

  @override
  String get createNewListing => 'Create new listing';

  @override
  String get removeFromSaved => 'Remove from saved';

  @override
  String get saveToWishlist => 'Save to wishlist';

  @override
  String get fixedPriceType => ' (Fixed)';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get drawerHome => 'Home';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get failedToLoadNotifications => 'Failed to load notifications';

  @override
  String get allCaughtUp => 'All caught up!';

  @override
  String get noNewNotifications => 'No new notifications for you right now.';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get older => 'Older';

  @override
  String get viewDetails => 'View Details';

  @override
  String get justNow => 'Just now';

  @override
  String get listingApproved => 'Listing Approved';

  @override
  String get listingRejected => 'Listing Rejected';

  @override
  String get priceDropAlert => 'Price Drop Alert';

  @override
  String get accountWarning => 'Account Warning';

  @override
  String get offerRequest => 'Offer Request';

  @override
  String get offerAccepted => 'Offer accepted!';

  @override
  String get offerDeclined => 'Offer declined';

  @override
  String get counterOfferSent => 'Counter offer sent!';

  @override
  String get listing => 'Listing';

  @override
  String get expires => 'Expires';

  @override
  String get askingPriceLabel => 'Asking Price';

  @override
  String get offeredPrice => 'Offered Price';

  @override
  String get counterOffer => 'Counter Offer';

  @override
  String get acceptOffer => 'Accept Offer';

  @override
  String get declineOffer => 'Decline Offer';

  @override
  String get confirmDeclineOffer => 'Decline this offer?';

  @override
  String get leaveAReview => 'Leave a Review';

  @override
  String get counterOfferTitle => 'Counter Offer';

  @override
  String get enterCounterPrice => 'Enter your counter price:';

  @override
  String get sendCounter => 'Send Counter';

  @override
  String get offerSentSuccess => 'Offer sent successfully!';

  @override
  String get yourOffer => 'Your Offer';

  @override
  String get sendOffer => 'Send Offer';

  @override
  String get myListings => 'My Listings';

  @override
  String get favorites => 'Favorites';

  @override
  String get reviews => 'Reviews';

  @override
  String get guestUser => 'Guest User';

  @override
  String get aboutSeller => 'About Seller';

  @override
  String get memberSince => 'Member Since';

  @override
  String get notSet => 'Not Set';

  @override
  String get account => 'Account';

  @override
  String get accountOptions => 'Account Options';

  @override
  String get blockedUsers => 'Blocked Users';

  @override
  String get clickHere => 'Click Here';

  @override
  String get noItemsFound => 'No items found.';

  @override
  String get usernameInvalidChars =>
      'Only letters, numbers, and underscores allowed';

  @override
  String get usernameMinLength => 'Username must be at least 3 characters';

  @override
  String get usernameMaxLength => 'Username cannot exceed 20 characters';

  @override
  String get currentUsernameMessage => 'This is your current username';

  @override
  String get usernameAvailable => 'Username is available!';

  @override
  String get usernameTaken => 'Username is already taken';

  @override
  String get chooseAvailableUsername => 'Please choose an available username';

  @override
  String get changeProfilePicture => 'Change Profile Picture';

  @override
  String get takeAPhoto => 'Take a Photo';

  @override
  String get useYourCamera => 'Use your camera';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get selectExistingPhoto => 'Select an existing photo';

  @override
  String get profilePictureUpdated => 'Profile picture updated!';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get tapToChangePhoto => 'Tap to change photo';

  @override
  String get fullNameHint => 'Full Name';

  @override
  String get nameIsRequired => 'Name is required';

  @override
  String get username => 'Username';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get validPhoneNumber => 'Enter a valid phone number';

  @override
  String get campusDormLocation => 'Campus / Dorm Location';

  @override
  String get bio => 'Bio';

  @override
  String get bioMaxLength => 'Bio must be 300 characters or less';

  @override
  String get sellerProfile => 'Seller Profile';

  @override
  String get unknownSeller => 'Unknown Seller';

  @override
  String activeAdsBy(String sellerName) {
    return 'Active Ads by $sellerName';
  }

  @override
  String get invalidUserId => 'Invalid user ID';

  @override
  String get active => 'Active';

  @override
  String get rating => 'Rating';

  @override
  String get reportListing => 'Report Listing';

  @override
  String get reportUser => 'Report User';

  @override
  String get reportMessage => 'Report Message';

  @override
  String get helpKeepCommunitySafe => 'Help us keep the community safe';

  @override
  String get whyReporting => 'Why are you reporting this?';

  @override
  String get additionalDetails => 'Additional details';

  @override
  String get tellUsMoreHint => 'Tell us more about the issue...';

  @override
  String get submitReport => 'Submit Report';

  @override
  String get reportSubmittedSuccess =>
      'Report submitted. We\'ll review it shortly.';

  @override
  String get pleaseSelectRating => 'Please select a rating';

  @override
  String get reviewSubmittedSuccess => 'Review submitted successfully!';

  @override
  String get ratingPoor => 'Poor';

  @override
  String get ratingFair => 'Fair';

  @override
  String get ratingGood => 'Good';

  @override
  String get ratingVeryGood => 'Very Good';

  @override
  String get ratingExcellent => 'Excellent';

  @override
  String get howWasYourExperience => 'How was your experience?';

  @override
  String get tapStarToRate => 'Tap a star to rate the seller';

  @override
  String get writeYourFeedback => 'Write your feedback';

  @override
  String get optionalLabel => 'Optional';

  @override
  String get reviewHintText =>
      'Share your experience with this seller...\n\nWas the item as described? Was the seller responsive?';

  @override
  String get submitReview => 'Submit Review';

  @override
  String get myWishlist => 'My Wishlist';

  @override
  String get wishlistEmpty => 'Your wishlist is empty';

  @override
  String get wishlistEmptySubtitle =>
      'Save items you want to watch or buy later';

  @override
  String get exploreListings => 'Explore Listings';

  @override
  String askingPrice(String price) {
    return 'Asking: \$$price';
  }

  @override
  String percentOfAskingPrice(String percent) {
    return '$percent% of asking price';
  }

  @override
  String roundOfThree(int round) {
    return 'Round $round of 3';
  }

  @override
  String acceptOfferConfirm(String amount) {
    return 'Accept this offer of \$$amount?';
  }

  @override
  String daysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String minutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String daysHoursRemaining(int days, int hours) {
    return '${days}d ${hours}h remaining';
  }

  @override
  String hoursMinutesRemaining(int hours, int minutes) {
    return '${hours}h ${minutes}m remaining';
  }

  @override
  String minutesRemaining(int minutes) {
    return '${minutes}m remaining';
  }

  @override
  String itemLabel(String title) {
    return 'Item: $title';
  }

  @override
  String photosSelected(int count) {
    return '$count photos selected';
  }

  @override
  String get clearAll => 'Clear All';

  @override
  String get pleaseSelectPhoto => 'Please select at least one photo';

  @override
  String get nextDetails => 'Next: Details';

  @override
  String get semester => 'Semester';

  @override
  String get classLabel => 'Class';

  @override
  String get stream => 'Stream';

  @override
  String get subjectOptional => 'Subject (optional)';

  @override
  String get subjectHint => 'e.g. Mathematics, Physics, Bengali...';

  @override
  String get bookType => 'Book Type';

  @override
  String get nextPricePickup => 'Next: Price & Pickup';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get bengali => 'বাংলা';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get systemDefault => 'System Default';

  @override
  String get general => 'General';

  @override
  String get appVersion => 'App Version';

  @override
  String get similarListings => 'Similar Listings';
}

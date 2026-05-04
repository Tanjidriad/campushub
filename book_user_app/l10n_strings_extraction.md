# Hardcoded User-Facing Strings Extraction

> **Scope:** All `.dart` files under `lib/features/*/presentation/{pages,widgets}/` and `lib/core/widgets/`
> **Exclusions:** URLs, asset paths, font names, route paths, single characters, variable-only interpolations, debug strings

---

## 1. AUTH FEATURE

### `lib/features/auth/presentation/pages/login_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Please enter your email"` | `loginEmailRequired` | ~44 |
| 2 | `"Please enter a valid email address"` | `validEmailRequired` | ~48 |
| 3 | `"Please enter your password"` | `loginPasswordRequired` | ~52 |
| 4 | `"Password must be at least 6 characters"` | `passwordMinLength` | ~57 |
| 5 | `"CampusHub Pro"` | `appName` | ~145 |
| 6 | `"The exclusive marketplace for students."` | `loginSubtitle` | ~165 |
| 7 | `"Student Login"` | `studentLogin` | ~195 |
| 8 | `"Email"` | `emailLabel` | ~204 |
| 9 | `"Enter your email"` | `enterEmailHint` | ~207 |
| 10 | `"Password"` | `passwordLabel` | ~215 |
| 11 | `"Enter your password"` | `enterPasswordHint` | ~218 |
| 12 | `"Forgot Password?"` | `forgotPassword` | ~283 |
| 13 | `"Log In"` | `logIn` | ~324 |
| 14 | `"Don't have an account? "` | `noAccountPrompt` | ~339 |
| 15 | `"Sign Up"` | `signUp` | ~349 |

### `lib/features/auth/presentation/pages/register_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Please enter your full name"` | `fullNameRequired` | ~52 |
| 2 | `"Please enter your email address"` | `emailAddressRequired` | ~56 |
| 3 | `"Please enter a valid email address"` | `validEmailRequired` | ~60 |
| 4 | `"Please create a password"` | `createPasswordRequired` | ~64 |
| 5 | `"Password must be at least 6 characters"` | `passwordMinLength` | ~68 |
| 6 | `"Passwords do not match"` | `passwordsDoNotMatch` | ~73 |
| 7 | `"Account created! Please verify your email."` | `accountCreatedVerifyEmail` | ~82 |
| 8 | `"CampusHub Pro"` | `appName` | ~130 |
| 9 | `"Join the exclusive student marketplace."` | `registerSubtitle` | ~149 |
| 10 | `"Student Registration"` | `studentRegistration` | ~181 |
| 11 | `"Full Name"` | `fullNameLabel` | ~190 |
| 12 | `"Enter your full name"` | `enterFullNameHint` | ~193 |
| 13 | `"Email Address"` | `emailAddressLabel` | ~200 |
| 14 | `"Enter your student email"` | `enterStudentEmailHint` | ~203 |
| 15 | `"Password"` | `passwordLabel` | ~210 |
| 16 | `"Create a password"` | `createPasswordHint` | ~212 |
| 17 | `"Confirm Password"` | `confirmPasswordLabel` | ~221 |
| 18 | `"Confirm your password"` | `confirmPasswordHint` | ~224 |
| 19 | `"Sign Up"` | `signUp` | ~250 |
| 20 | `"Already have an account? "` | `alreadyHaveAccount` | ~268 |
| 21 | `"Log In"` | `logIn` | ~277 |

### `lib/features/auth/presentation/pages/forgot_password_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Please enter your email"` | `loginEmailRequired` | ~40 |
| 2 | `"Please enter a valid email address"` | `validEmailRequired` | ~44 |
| 3 | `"Password reset link sent to your email"` | `resetLinkSent` | ~54 |
| 4 | `"Forgot Password?"` | `forgotPasswordTitle` | ~83 |
| 5 | `"Don't worry! It happens. Please enter the email address associated with your account."` | `forgotPasswordDescription` | ~91 |
| 6 | `"Email Address"` | `emailAddressLabel` | ~100 |
| 7 | `"Enter your email"` | `enterEmailHint` | ~105 |
| 8 | `"Send Reset Link"` | `sendResetLink` | ~126 |

### `lib/features/auth/presentation/pages/reset_password_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Please enter a new password"` | `newPasswordRequired` | ~44 |
| 2 | `"Password must be at least 6 characters"` | `passwordMinLength` | ~48 |
| 3 | `"Passwords do not match"` | `passwordsDoNotMatch` | ~52 |
| 4 | `"Password reset successfully! Please login."` | `passwordResetSuccess` | ~57 |
| 5 | `"Reset Password"` | `resetPasswordTitle` | ~77 |
| 6 | `"Please enter your new password below."` | `resetPasswordDescription` | ~85 |
| 7 | `"New Password"` | `newPasswordLabel` | ~92 |
| 8 | `"Enter new password"` | `enterNewPasswordHint` | ~98 |
| 9 | `"Confirm Password"` | `confirmPasswordLabel` | ~119 |
| 10 | `"Confirm new password"` | `confirmNewPasswordHint` | ~125 |
| 11 | `"Reset Password"` | `resetPasswordButton` | ~157 |

### `lib/features/auth/presentation/pages/verify_email_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Email verified successfully!"` | `emailVerifiedSuccess` | ~107 |
| 2 | `"Verification email sent!"` | `verificationEmailSent` | ~110 |
| 3 | `"Verify your email"` | `verifyYourEmail` | ~124 |
| 4 | `"We've sent a verification link to your email address. Please click the link to verify your account."` | `verifyEmailDescription` | ~132 |
| 5 | `"Resend Email"` | `resendEmail` | ~149 |
| 6 | `"I've verified my email"` | `verifiedMyEmail` | ~163 |
| 7 | `"Back to Login"` | `backToLogin` | ~179 |

### `lib/features/auth/presentation/pages/onboarding_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Your Campus.\nYour Marketplace."` | `onboardingTitle1` | ~65 |
| 2 | `"Turn your old textbooks into cash and find great deals on dorm essentials. Safe, local, and student-verified."` | `onboardingDescription1` | ~66 |
| 3 | `"Shop Your Campus"` | `onboardingTitle2` | ~72 |
| 4 | `"Safe, local deals from students near you. Buy textbooks, furniture, and more."` | `onboardingDescription2` | ~73 |
| 5 | `"Search & Filter"` | `onboardingStepSearchFilter` | ~76 |
| 6 | `"Find exactly what you need by category or dorm location."` | `onboardingStepSearchFilterDesc` | ~77 |
| 7 | `"Chat Securely"` | `onboardingStepChatSecurely` | ~80 |
| 8 | `"Message sellers directly in-app to ask questions and negotiate."` | `onboardingStepChatSecurelyDesc` | ~81 |
| 9 | `"Meet on Campus"` | `onboardingStepMeetOnCampus` | ~84 |
| 10 | `"Safe exchange at designated campus spots like the student union."` | `onboardingStepMeetOnCampusDesc` | ~85 |
| 11 | `"Sell in Seconds"` | `onboardingTitle3` | ~90 |
| 12 | `"Turn your clutter into cash. Post textbooks, gadgets, and gear to students on your campus."` | `onboardingDescription3` | ~91 |
| 13 | `"Snap a Photo"` | `onboardingStepSnapPhoto` | ~94 |
| 14 | `"Take a clear picture of your item directly in the app."` | `onboardingStepSnapPhotoDesc` | ~95 |
| 15 | `"Set Your Price"` | `onboardingStepSetPrice` | ~98 |
| 16 | `"Add a description and set a fair price for students."` | `onboardingStepSetPriceDesc` | ~99 |
| 17 | `"Chat securely and arrange a safe meetup spot nearby."` | `onboardingStepMeetOnCampusDesc2` | ~103 |
| 18 | `"Skip"` | `skip` | ~121 |
| 19 | `"STATUS"` | `statusLabel` | ~189 |
| 20 | `"Student Verified"` | `studentVerified` | ~197 |
| 21 | `"Get Started"` | `getStarted` | ~229 |
| 22 | `"Already have an account? "` | `alreadyHaveAccount` | ~238 |
| 23 | `"Log in"` | `logInLower` | ~246 |
| 24 | `"Next"` | `next` | ~397 |

### `lib/features/auth/presentation/pages/splash_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"CampusHub Pro"` | `appName` | ~74 |
| 2 | `"For students only"` | `forStudentsOnly` | ~82 |

---

## 2. CHAT FEATURE

### `lib/features/chat/presentation/pages/chat_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Mark as Sold"` | `markAsSold` | ~122 |
| 2 | `"Are you sure you want to mark this listing as sold?"` | `confirmMarkAsSold` | ~131 |
| 3 | `"This will cancel all pending offers and notify buyers."` | `markAsSoldWarning` | ~171 |
| 4 | `"Cancel"` | `cancel` | ~176 |
| 5 | `"Mark as Sold"` | `markAsSoldButton` | ~200 |
| 6 | `"Listing marked as sold!"` | `listingMarkedAsSold` | ~193 |
| 7 | `"Failed to load messages"` | `failedToLoadMessages` | ~236 |
| 8 | `"Retry"` | `retry` | ~239 |
| 9 | `"No messages yet"` | `noMessagesYet` | ~253 |
| 10 | `"Start the conversation!"` | `startTheConversation` | ~261 |
| 11 | `"Location unavailable"` | `locationUnavailable` | ~314 |
| 12 | `"Shared Location"` | `sharedLocation` | ~501 |
| 13 | `"Image unavailable"` | `imageUnavailable` | ~541 |
| 14 | `"online"` | `online` | ~654 |
| 15 | `"offline"` | `offline` | ~655 |
| 16 | `"is typing..."` | `isTyping` | ~693 |

### `lib/features/chat/presentation/pages/messages_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Edit"` | `edit` | ~89 |
| 2 | `"Messages"` | `messages` | ~97 |
| 3 | `"New"` | `newLabel` | ~115 |
| 4 | `"Search"` | `search` | ~128 |
| 5 | `"Failed to load conversations"` | `failedToLoadConversations` | ~153 |
| 6 | `"Retry"` | `retry` | ~160 |
| 7 | `"No conversations yet"` | `noConversationsYet` | ~167 |
| 8 | `"Start chatting with sellers!"` | `startChattingWithSellers` | ~174 |
| 9 | `"No messages yet"` | `noMessagesYet` | ~290 |
| 10 | `"Yesterday"` | `yesterday` | ~278 |

### `lib/features/chat/presentation/widgets/chat_input_area.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Make an Offer"` | `makeAnOffer` | ~83 |
| 2 | `"Message..."` | `messageHint` | ~107 |

### `lib/features/chat/presentation/widgets/listing_info_bar.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Contact for price"` | `contactForPrice` | ~91 |
| 2 | `"View Listing"` | `viewListing` | ~100 |
| 3 | `"Mark Sold"` | `markSold` | ~117 |
| 4 | `"Make Offer"` | `makeOfferButton` | ~137 |

### `lib/features/chat/presentation/widgets/quick_replies.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Yes, still available"` | `quickReplyStillAvailable` | ~30 |
| 2 | `"Where to meet?"` | `quickReplyWhereToMeet` | ~31 |
| 3 | `"Is price negotiable?"` | `quickReplyPriceNegotiable` | ~32 |
| 4 | `"I'm here"` | `quickReplyImHere` | ~33 |

### `lib/features/chat/presentation/widgets/safety_tip.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Safety Tip: Always meet in public places like the library."` | `safetyTipPublicPlaces` | ~20 |

---

## 3. CREATE LISTING FEATURE

### `lib/features/create_listing/presentation/pages/create_listing_photos_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"You can only upload up to 10 photos"` | `maxPhotosWarning` | ~39 |
| 2 | `"Create Listing"` | `createListing` | ~74 |
| 3 | `"Help"` | `help` | ~88 |
| 4 | `"Step 1 of 4"` | `stepOneOfFour` | ~101 |
| 5 | `"25% completed"` | `twentyFivePercentCompleted` | ~108 |
| 6 | `"Add Photos"` | `addPhotos` | ~132 |
| 7 | `"Upload up to 10 photos. Choose your best shot as the cover."` | `addPhotosSubtitle` | ~140 |
| 8 | `"QUICK TIP"` | `quickTip` | ~157 |
| 9 | `"Good lighting helps items sell 50% faster! Try using natural light near a window."` | `lightingTip` | ~163 |
| 10 | `"Cover Photo"` | `coverPhoto` | ~195 |
| 11 | `"Add Cover Photo"` | `addCoverPhoto` | ~245 |
| 12 | `"Add More"` | `addMore` | ~293 |

### `lib/features/create_listing/presentation/pages/create_listing_details_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Add Details"` | `addDetails` | ~90 |
| 2 | `"Step 2 of 3"` | `stepTwoOfThree` | ~124 |
| 3 | `"Item Information"` | `itemInformation` | ~137 |
| 4 | `"Fill in the details to help buyers find your item."` | `itemInfoSubtitle` | ~144 |
| 5 | `"Category"` | `category` | ~151 |
| 6 | `"Select a category"` | `selectCategory` | ~176 |
| 7 | `"Condition"` | `condition` | ~198 |
| 8 | `"New"` | `conditionNew` | ~40 |
| 9 | `"Like New"` | `conditionLikeNew` | ~41 |
| 10 | `"Good"` | `conditionGood` | ~42 |
| 11 | `"Fair"` | `conditionFair` | ~43 |
| 12 | `"Title"` | `titleLabel` | ~254 |
| 13 | `"What are you selling?"` | `whatAreYouSellingHint` | ~261 |
| 14 | `"Description"` | `descriptionLabel` | ~279 |
| 15 | `"Describe what you are selling (e.g., Author, Edition, specific flaws)..."` | `descriptionHint` | ~293 |
| 16 | `"Book Details"` | `bookDetails` | ~330 |
| 17 | `"Help students find the right book for their level."` | `bookDetailsSubtitle` | ~340 |
| 18 | `"Education Level"` | `educationLevel` | ~346 |

### `lib/features/create_listing/presentation/pages/create_listing_price_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Create Listing"` | `createListing` | ~60 |
| 2 | `"Price & Pickup"` | `priceAndPickup` | ~94 |
| 3 | `"Set a fair price and choose a safe meeting spot on campus."` | `pricePickupSubtitle` | ~101 |
| 4 | `"PRICE"` | `priceLabel` | ~122 |
| 5 | `"Open to offers?"` | `openToOffers` | ~155 |
| 6 | `"Allow buyers to suggest a price"` | `allowBuyersSuggestPrice` | ~161 |
| 7 | `"Meeting Spot"` | `meetingSpot` | ~176 |
| 8 | `"Safety Tip"` | `safetyTip` | ~195 |
| 9 | `"Meet in public areas like the Student Union or Library. Avoid dorm rooms."` | `meetingSpotSafetyTip` | ~201 |
| 10 | `"Enter pickup location"` | `enterPickupLocationHint` | ~214 |
| 11 | `"Campus Library"` | `campusLibrary` | ~228 |
| 12 | `"Student Center"` | `studentCenter` | ~229 |
| 13 | `"Main Gate"` | `mainGate` | ~230 |
| 14 | `"Cafeteria"` | `cafeteria` | ~231 |
| 15 | `"Back"` | `back` | ~257 |
| 16 | `"Please enter a price"` | `priceRequired` | ~278 |
| 17 | `"Please enter a valid price greater than 0"` | `validPriceRequired` | ~284 |
| 18 | `"Publish Listing"` | `publishListing` | ~308 |

### `lib/features/create_listing/presentation/pages/listing_confirmation_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Confirmation"` | `confirmation` | ~25 |
| 2 | `"Listing Submitted!"` | `listingSubmitted` | ~88 |
| 3 | `"Your listing has been submitted for review. Our team will review it and you'll be notified once it's approved."` | `listingSubmittedDescription` | ~95 |
| 4 | `"PENDING APPROVAL"` | `pendingApproval` | ~133 |
| 5 | `"Your listing is being reviewed"` | `listingBeingReviewed` | ~144 |
| 6 | `"Usually within 24 hours"` | `usuallyWithin24Hours` | ~152 |
| 7 | `"We'll notify you"` | `wellNotifyYou` | ~170 |
| 8 | `"Visible after approval"` | `visibleAfterApproval` | ~183 |
| 9 | `"Back to Home"` | `backToHome` | ~201 |
| 10 | `"View My Listings"` | `viewMyListings` | ~215 |

---

## 4. LISTINGS FEATURE

### `lib/features/listings/presentation/pages/home_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Category"` | `category` | ~109 |
| 2 | `"Latest Ads"` | `latestAds` | ~147 |
| 3 | `"See all"` | `seeAll` | ~155 |

### `lib/features/listings/presentation/pages/listing_detail_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Listing data not loaded yet"` | `listingDataNotLoaded` | ~107 |
| 2 | `"Seller information not available"` | `sellerInfoNotAvailable` | ~112 |
| 3 | `"Listing deleted successfully"` | `listingDeletedSuccess` | ~157 |
| 4 | `"Listing marked as sold"` | `listingMarkedAsSoldMsg` | ~161 |
| 5 | `"Retry"` | `retry` | ~220 |
| 6 | `"Ad Details"` | `adDetails` | ~236 |
| 7 | `"Check it out on CampusHub Pro!"` | `shareCheckItOut` | ~251 |
| 8 | `"see map"` | `seeMap` | ~660 |
| 9 | `"Location not set"` | `locationNotSet` | ~650 |
| 10 | `"Loading..."` | `loading` | ~630 |
| 11 | `"Description"` | `descriptionSection` | ~810 |
| 12 | `"No description available."` | `noDescriptionAvailable` | ~890 |
| 13 | `"Safety tips for deal"` | `safetyTipsForDeal` | ~898 |
| 14 | `"Use a safe location to meet seller"` | `safetyTipMeetSeller` | ~906 |
| 15 | `"Avoid cash transactions"` | `safetyTipAvoidCash` | ~907 |
| 16 | `"Beware of unrealistic offers"` | `safetyTipUnrealisticOffers` | ~908 |
| 17 | `"View profile"` | `viewProfile` | ~730 |
| 18 | `"Rating & Review"` | `ratingAndReview` | ~1140 |
| 19 | `"Could not load reviews"` | `couldNotLoadReviews` | ~1195 |
| 20 | `"No reviews yet"` | `noReviewsYet` | ~1205 |
| 21 | `"Report"` | `report` | ~1040 |
| 22 | `"Write a Review"` | `writeAReview` | ~1055 |
| 23 | `"Featured"` | `featured` | ~1457 |
| 24 | `"Promote Listing"` | `promoteListing` | ~1490 |
| 25 | `"Share on WhatsApp"` | `shareOnWhatsApp` | ~1530 |
| 26 | `"Found on CampusHub Pro 📚"` | `foundOnCampusHub` | ~1520 |
| 27 | `"Buy Now"` | `buyNow` | ~1600 |
| 28 | `"Send Message"` | `sendMessage` | ~1640 |
| 29 | `"Mark as Sold"` | `markAsSold` | ~1670 |
| 30 | `"Are you sure you want to mark this listing as sold?"` | `confirmMarkAsSold` | ~1673 |
| 31 | `"Cancel"` | `cancel` | ~1677 |
| 32 | `"Confirm"` | `confirm` | ~1685 |
| 33 | `"Delete Listing"` | `deleteListing` | ~1693 |
| 34 | `"Are you sure you want to delete this listing? This action cannot be undone."` | `confirmDeleteListing` | ~1696 |
| 35 | `"Delete"` | `delete` | ~1714 |
| 36 | `"Edit Listing"` | `editListing` | ~1740 |
| 37 | `"No"` | `no` | ~870 |

### `lib/features/listings/presentation/pages/search_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Search your dream books"` | `searchDreamBooksHint` | ~98 |
| 2 | `"Search for books, sellers, or items"` | `searchForBooksPrompt` | ~139 |
| 3 | `"Start typing to discover great deals"` | `startTypingDiscover` | ~147 |
| 4 | `"Recent Searches"` | `recentSearches` | ~163 |
| 5 | `"Clear"` | `clear` | ~171 |
| 6 | `"Searching..."` | `searching` | ~207 |
| 7 | `"Something went wrong"` | `somethingWentWrong` | ~222 |
| 8 | `"No results found"` | `noResultsFound` | ~257 |
| 9 | `"Try searching with different keywords"` | `tryDifferentKeywords` | ~264 |

### `lib/features/listings/presentation/pages/edit_listing_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Listing updated. It is now pending admin approval."` | `listingUpdatedPending` | ~142 |
| 2 | `"Listing updated successfully"` | `listingUpdatedSuccess` | ~146 |
| 3 | `"Edit Listing"` | `editListing` | ~157 |
| 4 | `"Basic Info"` | `basicInfo` | ~177 |
| 5 | `"Title"` | `titleLabel` | ~182 |
| 6 | `"Please enter a title"` | `titleRequired` | ~186 |
| 7 | `"Price"` | `priceInputLabel` | ~192 |
| 8 | `"Please enter a price"` | `priceRequired` | ~197 |
| 9 | `"Category"` | `categoryLabel` | ~202 |
| 10 | `"Please select a category"` | `categoryRequired` | ~215 |
| 11 | `"Condition"` | `conditionLabel` | ~222 |
| 12 | `"Please select a condition"` | `conditionRequired` | ~235 |
| 13 | `"Description"` | `descriptionLabel` | ~242 |
| 14 | `"Please enter a description"` | `descriptionRequired` | ~248 |
| 15 | `"Save Changes"` | `saveChanges` | ~258 |

### `lib/features/listings/presentation/pages/promote_listing_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Listing promoted successfully!"` | `listingPromotedSuccess` | ~50 |
| 2 | `"Promote Listing"` | `promoteListing` | ~57 |
| 3 | `"PREVIEW ON FEED"` | `previewOnFeed` | ~90 |
| 4 | `"FEATURED"` | `featuredBadge` | ~148 |
| 5 | `"Promoted"` | `promoted` | ~192 |
| 6 | `"This is how your listing will appear to other students."` | `previewDescription` | ~205 |
| 7 | `"Why Feature?"` | `whyFeature` | ~233 |
| 8 | `"5x More\nViews"` | `fiveXMoreViews` | ~245 |
| 9 | `"Sell 2x\nFaster"` | `sellTwoXFaster` | ~250 |
| 10 | `"Build\nTrust"` | `buildTrust` | ~251 |
| 11 | `"Select Duration"` | `selectDuration` | ~275 |
| 12 | `"3 Days"` | `threeDays` | ~290 |
| 13 | `"7 Days"` | `sevenDays` | ~295 |
| 14 | `"30 Days"` | `thirtyDays` | ~300 |
| 15 | `"Good for quick sales"` | `goodForQuickSales` | ~291 |
| 16 | `"Recommended duration"` | `recommendedDuration` | ~296 |
| 17 | `"Maximum exposure"` | `maximumExposure` | ~301 |
| 18 | `"Most Popular"` | `mostPopular` | ~297 |
| 19 | `"Best Value"` | `bestValue` | ~302 |

### `lib/features/listings/presentation/widgets/drawer_menu_screen.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Home"` | `home` | ~60 |
| 2 | `"My Profile"` | `myProfile` | ~65 |
| 3 | `"Wishlist"` | `wishlist` | ~70 |
| 4 | `"Messages"` | `messages` | ~75 |
| 5 | `"Notifications"` | `notifications` | ~80 |
| 6 | `"Settings"` | `settings` | ~85 |
| 7 | `"Sign Out"` | `signOut` | ~90 |

### `lib/features/listings/presentation/widgets/filter_bottom_sheet.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Filter & Sort"` | `filterAndSort` | ~110 |
| 2 | `"Reset"` | `reset` | ~120 |
| 3 | `"Category"` | `category` | ~140 |
| 4 | `"All"` | `all` | ~145 |
| 5 | `"Condition"` | `condition` | ~182 |

### `lib/features/listings/presentation/widgets/hero_search_section.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Search with keywords..."` | `searchWithKeywords` | ~39 |

### `lib/features/listings/presentation/widgets/sort_filter_bar.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Recommended"` | `recommended` | ~30 |
| 2 | `"Newest First"` | `newestFirst` | ~31 |
| 3 | `"Price: Low to High"` | `priceLowToHigh` | ~32 |
| 4 | `"Price: High to Low"` | `priceHighToLow` | ~33 |
| 5 | `"Filtered"` | `filtered` | ~101 |
| 6 | `"Filter"` | `filter` | ~101 |

### `lib/features/listings/presentation/widgets/featured_listings_section.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Featured"` *(section header)* | `featuredSection` | ~40 |

### `lib/features/listings/presentation/widgets/staff_picks_section.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Staff Picks"` | `staffPicks` | ~30 |
| 2 | `"View All"` | `viewAll` | ~35 |
| 3 | `"Detail"` | `detail` | ~200 |
| 4 | `"FREE"` | `free` | ~170 |

### `lib/features/listings/presentation/widgets/deals_near_you_section.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Deals Near You"` | `dealsNearYou` | ~30 |

### `lib/features/listings/presentation/widgets/custom_bottom_nav.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Home"` | `home` | ~80 |
| 2 | `"Saved"` | `saved` | ~88 |
| 3 | `"Add"` | `add` | ~145 |
| 4 | `"Chat"` | `chat` | ~102 |
| 5 | `"Profile"` | `profile` | ~110 |
| 6 | `"Create new listing"` | `createNewListing` | ~127 |

### `lib/features/listings/presentation/widgets/education_filter_bar.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"All"` | `all` | ~115 |

### `lib/features/listings/presentation/widgets/listing_card.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Remove from saved"` | `removeFromSaved` | ~155 |
| 2 | `"Save to wishlist"` | `saveToWishlist` | ~156 |

### `lib/features/listings/presentation/widgets/staggered_listing_card.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"FREE"` | `free` | ~175 |

### `lib/features/listings/presentation/widgets/modern_featured_card.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `" (Fixed)"` | `fixedPriceType` | ~155 |
| 2 | `"Not specified"` | `notSpecified` | ~175 |

---

## 5. NOTIFICATIONS FEATURE

### `lib/features/notifications/presentation/pages/notifications_screen.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Notifications"` | `notifications` | ~112 |
| 2 | `"Mark all as read"` | `markAllAsRead` | ~121 |
| 3 | `"Failed to load notifications"` | `failedToLoadNotifications` | ~148 |
| 4 | `"Retry"` | `retry` | ~156 |
| 5 | `"All caught up!"` | `allCaughtUp` | ~180 |
| 6 | `"No new notifications for you right now."` | `noNewNotifications` | ~188 |
| 7 | `"Today"` | `today` | ~79 |
| 8 | `"Yesterday"` | `yesterday` | ~81 |
| 9 | `"This Week"` | `thisWeek` | ~83 |
| 10 | `"Older"` | `older` | ~85 |

### `lib/features/notifications/presentation/widgets/notification_tile.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"View Details"` | `viewDetails` | ~160 |
| 2 | `"Yesterday"` | `yesterday` | ~185 |
| 3 | `"Just now"` | `justNow` | ~192 |
| 4 | `"Listing Approved"` | `listingApproved` | ~197 |
| 5 | `"Listing Rejected"` | `listingRejected` | ~199 |
| 6 | `"Price Drop Alert"` | `priceDropAlert` | ~201 |
| 7 | `"Account Warning"` | `accountWarning` | ~203 |

---

## 6. OFFERS FEATURE

### `lib/features/offers/presentation/pages/offer_request_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Offer Request"` | `offerRequest` | ~51 |
| 2 | `"Offer accepted!"` | `offerAccepted` | ~69 |
| 3 | `"Offer declined"` | `offerDeclined` | ~71 |
| 4 | `"Counter offer sent!"` | `counterOfferSent` | ~72 |
| 5 | `"Listing"` | `listing` | ~175 |
| 6 | `"Condition"` | `condition` | ~210 |
| 7 | `"Category"` | `category` | ~215 |
| 8 | `"Location"` | `location` | ~220 |
| 9 | `"Expires"` | `expires` | ~225 |
| 10 | `"Asking Price"` | `askingPrice` | ~255 |
| 11 | `"Offered Price"` | `offeredPrice` | ~270 |
| 12 | `"Counter Offer"` | `counterOffer` | ~295 |
| 13 | `"Accept Offer"` | `acceptOffer` | ~445 |
| 14 | `"Counter"` | `counter` | ~480 |
| 15 | `"Decline"` | `decline` | ~520 |
| 16 | `"Decline Offer"` | `declineOffer` | ~510 |
| 17 | `"Decline this offer?"` | `confirmDeclineOffer` | ~511 |
| 18 | `"Leave a Review"` | `leaveAReview` | ~555 |
| 19 | `"Accept"` | `accept` | ~443 |
| 20 | `"Cancel"` | `cancel` | ~575 |
| 21 | `"Counter Offer"` *(dialog title)* | `counterOfferTitle` | ~600 |
| 22 | `"Enter your counter price:"` | `enterCounterPrice` | ~605 |
| 23 | `"Send Counter"` | `sendCounter` | ~625 |
| 24 | `"Expired"` | `expired` | ~640 |
| 25 | `"Pending"` | `pending` | ~660 |
| 26 | `"Accepted"` | `accepted` | ~665 |
| 27 | `"Declined"` | `declined` | ~670 |
| 28 | `"Countered"` | `countered` | ~675 |

### `lib/features/offers/presentation/widgets/make_offer_sheet.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Offer sent successfully!"` | `offerSentSuccess` | ~100 |
| 2 | `"Make an Offer"` | `makeAnOffer` | ~135 |
| 3 | `"Your Offer"` | `yourOffer` | ~185 |
| 4 | `"Send Offer"` | `sendOffer` | ~240 |

---

## 7. PROFILE FEATURE

### `lib/features/profile/presentation/pages/profile_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Profile"` | `profile` | ~125 |
| 2 | `"Profile"` *(tab)* | `profileTab` | ~170 |
| 3 | `"My Listings"` | `myListings` | ~171 |
| 4 | `"Favorites"` | `favorites` | ~172 |
| 5 | `"Sold"` | `sold` | ~173 |
| 6 | `"Reviews"` | `reviews` | ~174 |
| 7 | `"Guest User"` | `guestUser` | ~220 |
| 8 | `"About Seller"` | `aboutSeller` | ~235 |
| 9 | `"Member Since"` | `memberSince` | ~245 |
| 10 | `"Unknown"` | `unknown` | ~248 |
| 11 | `"Location"` | `location` | ~252 |
| 12 | `"Not Set"` | `notSet` | ~253 |
| 13 | `"Email"` | `email` | ~257 |
| 14 | `"Account Options"` | `accountOptions` | ~265 |
| 15 | `"Blocked Users"` | `blockedUsers` | ~275 |
| 16 | `"Click Here"` | `clickHere` | ~276 |
| 17 | `"No items found."` | `noItemsFound` | ~310 |
| 18 | `"Available"` | `available` | ~345 |

### `lib/features/profile/presentation/pages/edit_profile_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Only letters, numbers, and underscores allowed"` | `usernameInvalidChars` | ~110 |
| 2 | `"Username must be at least 3 characters"` | `usernameMinLength` | ~118 |
| 3 | `"Username cannot exceed 20 characters"` | `usernameMaxLength` | ~126 |
| 4 | `"This is your current username"` | `currentUsernameMessage` | ~100 |
| 5 | `"Username is available!"` | `usernameAvailable` | ~150 |
| 6 | `"Username is already taken"` | `usernameTaken` | ~152 |
| 7 | `"Please choose an available username"` | `chooseAvailableUsername` | ~230 |
| 8 | `"Change Profile Picture"` | `changeProfilePicture` | ~190 |
| 9 | `"Take a Photo"` | `takeAPhoto` | ~200 |
| 10 | `"Use your camera"` | `useYourCamera` | ~201 |
| 11 | `"Choose from Gallery"` | `chooseFromGallery` | ~210 |
| 12 | `"Select an existing photo"` | `selectExistingPhoto` | ~211 |
| 13 | `"Profile picture updated!"` | `profilePictureUpdated` | ~280 |
| 14 | `"Edit Profile"` | `editProfile` | ~300 |
| 15 | `"Tap to change photo"` | `tapToChangePhoto` | ~340 |
| 16 | `"Full Name"` | `fullNameHint` | ~355 |
| 17 | `"Name is required"` | `nameIsRequired` | ~358 |
| 18 | `"Username"` | `usernameHint` | ~250 |
| 19 | `"Phone Number"` | `phoneNumberHint` | ~375 |
| 20 | `"Enter a valid phone number"` | `validPhoneNumber` | ~505 |
| 21 | `"Campus / Dorm Location"` | `campusDormLocationHint` | ~515 |
| 22 | `"Bio"` | `bioHint` | ~525 |
| 23 | `"Bio must be 300 characters or less"` | `bioMaxLength` | ~530 |
| 24 | `"Save Changes"` | `saveChanges` | ~545 |

### `lib/features/profile/presentation/pages/seller_profile_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Seller Profile"` | `sellerProfile` | ~45 |
| 2 | `"Unknown Seller"` | `unknownSeller` | ~72 |
| 3 | `"Message"` | `message` | ~95 |
| 4 | `"Follow"` | `follow` | ~110 |
| 5 | `"About Seller"` | `aboutSeller` | ~135 |
| 6 | `"Member Since"` | `memberSince` | ~145 |
| 7 | `"Location"` | `location` | ~152 |
| 8 | `"Unknown"` | `unknown` | ~153 |

### `lib/features/profile/presentation/pages/user_profile_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Invalid user ID"` | `invalidUserId` | ~40 |
| 2 | `"Chat"` | `chat` | ~170 |
| 3 | `"Active"` | `active` | ~185 |
| 4 | `"Sold"` | `sold` | ~190 |
| 5 | `"Rating"` | `rating` | ~195 |
| 6 | `"Listings"` | `listings` | ~210 |
| 7 | `"Reviews"` | `reviews` | ~215 |
| 8 | `"No listings found."` | `noListingsFound` | ~240 |

### `lib/features/profile/presentation/widgets/profile_info_header.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Reviews"` *(in rating text)* | `reviewsSuffix` | ~80 |

---

## 8. REPORT FEATURE

### `lib/features/report/presentation/widgets/report_dialog.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Report Listing"` | `reportListing` | ~78 |
| 2 | `"Report User"` | `reportUser` | ~80 |
| 3 | `"Report Message"` | `reportMessage` | ~82 |
| 4 | `"Help us keep the community safe"` | `helpKeepCommunitySafe` | ~165 |
| 5 | `"Why are you reporting this?"` | `whyReporting` | ~220 |
| 6 | `"Additional details"` | `additionalDetails` | ~250 |
| 7 | `"(optional)"` | `optional` | ~255 |
| 8 | `"Tell us more about the issue..."` | `tellUsMoreHint` | ~270 |
| 9 | `"Submit Report"` | `submitReport` | ~420 |
| 10 | `"Report submitted. We'll review it shortly."` | `reportSubmittedSuccess` | ~97 |

---

## 9. REVIEWS FEATURE

### `lib/features/reviews/presentation/pages/write_review_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"Please select a rating"` | `pleaseSelectRating` | ~80 |
| 2 | `"Review submitted successfully!"` | `reviewSubmittedSuccess` | ~90 |
| 3 | `"Write a Review"` | `writeAReview` | ~110 |
| 4 | `"Poor"` | `ratingPoor` | ~50 |
| 5 | `"Fair"` | `ratingFair` | ~51 |
| 6 | `"Good"` | `ratingGood` | ~52 |
| 7 | `"Very Good"` | `ratingVeryGood` | ~53 |
| 8 | `"Excellent"` | `ratingExcellent` | ~54 |
| 9 | `"How was your experience?"` | `howWasYourExperience` | ~230 |
| 10 | `"Tap a star to rate the seller"` | `tapStarToRate` | ~236 |
| 11 | `"Write your feedback"` | `writeYourFeedback` | ~340 |
| 12 | `"Optional"` | `optionalLabel` | ~350 |
| 13 | `"Share your experience with this seller...\n\nWas the item as described? Was the seller responsive?"` | `reviewHintText` | ~370 |
| 14 | `"Submit Review"` | `submitReview` | ~500 |

### `lib/features/reviews/presentation/widgets/reviews_list.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"No reviews yet"` | `noReviewsYet` | ~35 |

---

## 10. WISHLIST FEATURE

### `lib/features/wishlist/presentation/pages/wishlist_page.dart`

| # | Exact String | Suggested ARB Key | Line |
|---|---|---|---|
| 1 | `"My Wishlist"` | `myWishlist` | ~35 |
| 2 | `"Your wishlist is empty"` | `wishlistEmpty` | ~95 |
| 3 | `"Save items you want to watch or buy later"` | `wishlistEmptySubtitle` | ~102 |
| 4 | `"Explore Listings"` | `exploreListings` | ~115 |

---

## 11. CORE WIDGETS

### `lib/core/widgets/app_snackbar.dart`

No hardcoded user-facing strings (messages are passed as parameters).

### `lib/core/widgets/section_header.dart`

No hardcoded strings (title/action passed as parameters).

### `lib/core/widgets/app_cached_image.dart`, `app_loader.dart`, `shimmer_loading.dart`, `shimmer_skeletons.dart`

No hardcoded user-facing strings found.

---

## SUMMARY

| Feature | Files Scanned | Strings Found |
|---|---|---|
| Auth | 7 pages + 2 widgets | ~75 |
| Chat | 2 pages + 5 widgets | ~28 |
| Create Listing | 4 pages | ~42 |
| Listings | 5 pages + 10 widgets | ~70 |
| Notifications | 1 page + 1 widget | ~17 |
| Offers | 1 page + 1 widget | ~28 |
| Profile | 4 pages + 3 widgets | ~40 |
| Report | 1 widget | ~10 |
| Reviews | 1 page + 1 widget | ~15 |
| Wishlist | 1 page | ~4 |
| Core Widgets | 6 files | ~0 |
| **TOTAL** | **~55 files** | **~329 strings** |

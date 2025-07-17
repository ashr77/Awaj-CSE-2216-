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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Auth System'**
  String get appTitle;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Awaj'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @toggleLanguage.
  ///
  /// In en, this message translates to:
  /// **'Toggle Language'**
  String get toggleLanguage;

  /// No description provided for @toggleTheme.
  ///
  /// In en, this message translates to:
  /// **'Toggle Theme'**
  String get toggleTheme;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Report & Track Corruption Anonymously'**
  String get tagline;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @signInToContinueMission.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your mission.'**
  String get signInToContinueMission;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterValidPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid password'**
  String get enterValidPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing In...'**
  String get signingIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinMission.
  ///
  /// In en, this message translates to:
  /// **'Join the Mission!'**
  String get joinMission;

  /// No description provided for @createAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your account to report & track corruption.'**
  String get createAccountDescription;

  /// No description provided for @addProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Profile Photo'**
  String get addProfilePhoto;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @nidBirthRegistration.
  ///
  /// In en, this message translates to:
  /// **'NID / Birth Registration'**
  String get nidBirthRegistration;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @min6Characters.
  ///
  /// In en, this message translates to:
  /// **'Min 6 characters'**
  String get min6Characters;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @signingUp.
  ///
  /// In en, this message translates to:
  /// **'Signing Up...'**
  String get signingUp;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @allPosts.
  ///
  /// In en, this message translates to:
  /// **'All Posts'**
  String get allPosts;

  /// No description provided for @allReports.
  ///
  /// In en, this message translates to:
  /// **'All Reports'**
  String get allReports;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @managePosts.
  ///
  /// In en, this message translates to:
  /// **'Manage Posts'**
  String get managePosts;

  /// No description provided for @manageReports.
  ///
  /// In en, this message translates to:
  /// **'Manage Reports'**
  String get manageReports;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @noReportsFound.
  ///
  /// In en, this message translates to:
  /// **'No reports found.'**
  String get noReportsFound;

  /// No description provided for @by.
  ///
  /// In en, this message translates to:
  /// **'By'**
  String get by;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @office.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get office;

  /// No description provided for @videoEvidence.
  ///
  /// In en, this message translates to:
  /// **'Video Evidence'**
  String get videoEvidence;

  /// No description provided for @videoPreviewNotSupportedHere.
  ///
  /// In en, this message translates to:
  /// **'Video preview not supported here.'**
  String get videoPreviewNotSupportedHere;

  /// No description provided for @openThisLinkInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open this link in browser:'**
  String get openThisLinkInBrowser;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @viewVideo.
  ///
  /// In en, this message translates to:
  /// **'View Video'**
  String get viewVideo;

  /// No description provided for @deletePost.
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get deletePost;

  /// No description provided for @areYouSureDeletePost.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this post?'**
  String get areYouSureDeletePost;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @postDeleted.
  ///
  /// In en, this message translates to:
  /// **'Post deleted.'**
  String get postDeleted;

  /// No description provided for @authorHome.
  ///
  /// In en, this message translates to:
  /// **'Author Home'**
  String get authorHome;

  /// No description provided for @viewConversations.
  ///
  /// In en, this message translates to:
  /// **'View Conversations'**
  String get viewConversations;

  /// No description provided for @reportRequests.
  ///
  /// In en, this message translates to:
  /// **'Report Requests'**
  String get reportRequests;

  /// No description provided for @viewChatRequests.
  ///
  /// In en, this message translates to:
  /// **'View Chat Requests'**
  String get viewChatRequests;

  /// No description provided for @welcomeAuthor.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String welcomeAuthor(Object name);

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome;

  /// No description provided for @chooseAction.
  ///
  /// In en, this message translates to:
  /// **'Choose an action below.'**
  String get chooseAction;

  /// No description provided for @reportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report Problem'**
  String get reportProblem;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @aboutMe.
  ///
  /// In en, this message translates to:
  /// **'About Me'**
  String get aboutMe;

  /// No description provided for @others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// No description provided for @reportCorruption.
  ///
  /// In en, this message translates to:
  /// **'Report Corruption'**
  String get reportCorruption;

  /// No description provided for @reportName.
  ///
  /// In en, this message translates to:
  /// **'Report Name'**
  String get reportName;

  /// No description provided for @cityName.
  ///
  /// In en, this message translates to:
  /// **'{city}'**
  String cityName(Object city);

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select a city'**
  String get selectCity;

  /// No description provided for @officeName.
  ///
  /// In en, this message translates to:
  /// **'{office}'**
  String officeName(Object office);

  /// No description provided for @selectOffice.
  ///
  /// In en, this message translates to:
  /// **'Select an office'**
  String get selectOffice;

  /// No description provided for @briefDescription.
  ///
  /// In en, this message translates to:
  /// **'Brief Description'**
  String get briefDescription;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @addVideo.
  ///
  /// In en, this message translates to:
  /// **'Add Video'**
  String get addVideo;

  /// No description provided for @changeVideo.
  ///
  /// In en, this message translates to:
  /// **'Change Video'**
  String get changeVideo;

  /// No description provided for @videoAttached.
  ///
  /// In en, this message translates to:
  /// **'Video Attached'**
  String get videoAttached;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @chatRequests.
  ///
  /// In en, this message translates to:
  /// **'Chat Requests'**
  String get chatRequests;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get noPendingRequests;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @postCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Post created successfully!'**
  String get postCreatedSuccessfully;

  /// No description provided for @errorCreatingPost.
  ///
  /// In en, this message translates to:
  /// **'Error creating post: {error}'**
  String errorCreatingPost(Object error);

  /// No description provided for @createPost.
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get createPost;

  /// No description provided for @whatDoYouWantToShare.
  ///
  /// In en, this message translates to:
  /// **'What do you want to share?'**
  String get whatDoYouWantToShare;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get addImage;

  /// No description provided for @postAnonymously.
  ///
  /// In en, this message translates to:
  /// **'Post Anonymously'**
  String get postAnonymously;

  /// No description provided for @editPost.
  ///
  /// In en, this message translates to:
  /// **'Edit Post'**
  String get editPost;

  /// No description provided for @editYourPost.
  ///
  /// In en, this message translates to:
  /// **'Edit your post'**
  String get editYourPost;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @communityPosts.
  ///
  /// In en, this message translates to:
  /// **'Community Posts'**
  String get communityPosts;

  /// No description provided for @newPost.
  ///
  /// In en, this message translates to:
  /// **'New Post'**
  String get newPost;

  /// No description provided for @reportedThankYou.
  ///
  /// In en, this message translates to:
  /// **'Reported. Thank you!'**
  String get reportedThankYou;

  /// No description provided for @addAComment.
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get addAComment;

  /// No description provided for @noCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noCommentsYet;

  /// No description provided for @signInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please sign in'**
  String get signInPrompt;

  /// No description provided for @userDataNotFound.
  ///
  /// In en, this message translates to:
  /// **'User data not found'**
  String get userDataNotFound;

  /// No description provided for @aboutMeTitle.
  ///
  /// In en, this message translates to:
  /// **'About Me'**
  String get aboutMeTitle;

  /// No description provided for @profileInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get profileInfoTitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @nidLabel.
  ///
  /// In en, this message translates to:
  /// **'NID'**
  String get nidLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @accountDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountDetailsTitle;

  /// No description provided for @accountCreatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Created'**
  String get accountCreatedLabel;

  /// No description provided for @userIdLabel.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userIdLabel;

  /// No description provided for @sectionTitle.
  ///
  /// In en, this message translates to:
  /// **'{title}'**
  String sectionTitle(Object title);

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// No description provided for @userTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'User Type: '**
  String get userTypeLabel;

  /// No description provided for @userTypeBadge.
  ///
  /// In en, this message translates to:
  /// **'USER'**
  String get userTypeBadge;

  /// No description provided for @checkReportStatus.
  ///
  /// In en, this message translates to:
  /// **'Check Your Report Status'**
  String get checkReportStatus;

  /// No description provided for @stayUpdatedOnReports.
  ///
  /// In en, this message translates to:
  /// **'Stay updated on your submitted reports.'**
  String get stayUpdatedOnReports;

  /// No description provided for @reportStatus.
  ///
  /// In en, this message translates to:
  /// **'Report Status'**
  String get reportStatus;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @yourChats.
  ///
  /// In en, this message translates to:
  /// **'Your Chats'**
  String get yourChats;

  /// No description provided for @pleaseSignInToViewConversations.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to view conversations'**
  String get pleaseSignInToViewConversations;

  /// No description provided for @yourConversations.
  ///
  /// In en, this message translates to:
  /// **'Your Conversations'**
  String get yourConversations;

  /// No description provided for @chatWithNewAuthority.
  ///
  /// In en, this message translates to:
  /// **'Chat with new authority'**
  String get chatWithNewAuthority;

  /// No description provided for @noPostsFound.
  ///
  /// In en, this message translates to:
  /// **'No posts found.'**
  String get noPostsFound;

  /// No description provided for @noConversationsYet.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversationsYet;

  /// No description provided for @acceptChatRequestsToStart.
  ///
  /// In en, this message translates to:
  /// **'Accept chat requests to start conversations'**
  String get acceptChatRequestsToStart;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @authorReview.
  ///
  /// In en, this message translates to:
  /// **'Author Review'**
  String get authorReview;

  /// No description provided for @pleaseSignInToAccess.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to access this feature'**
  String get pleaseSignInToAccess;

  /// No description provided for @reportReview.
  ///
  /// In en, this message translates to:
  /// **'Report Review'**
  String get reportReview;

  /// No description provided for @reportMarkedCompleted.
  ///
  /// In en, this message translates to:
  /// **'Report marked as completed'**
  String get reportMarkedCompleted;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(Object message);

  /// No description provided for @errorLoadingReports.
  ///
  /// In en, this message translates to:
  /// **'Error loading reports'**
  String get errorLoadingReports;

  /// No description provided for @noReportsToReview.
  ///
  /// In en, this message translates to:
  /// **'No reports to review'**
  String get noReportsToReview;

  /// No description provided for @allApprovedReportsHandled.
  ///
  /// In en, this message translates to:
  /// **'All approved reports have been handled'**
  String get allApprovedReportsHandled;

  /// No description provided for @completionFeedback.
  ///
  /// In en, this message translates to:
  /// **'Completion Feedback: '**
  String get completionFeedback;

  /// No description provided for @chatWithUser.
  ///
  /// In en, this message translates to:
  /// **'Chat with User'**
  String get chatWithUser;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @completeReport.
  ///
  /// In en, this message translates to:
  /// **'Complete Report'**
  String get completeReport;

  /// No description provided for @completionFeedbackLabel.
  ///
  /// In en, this message translates to:
  /// **'Completion Feedback'**
  String get completionFeedbackLabel;

  /// No description provided for @describeCompletionFeedback.
  ///
  /// In en, this message translates to:
  /// **'Describe the completion/final feedback...'**
  String get describeCompletionFeedback;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogout;

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureLogout;

  /// No description provided for @yesLogout.
  ///
  /// In en, this message translates to:
  /// **'Yes, Logout'**
  String get yesLogout;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn': return AppLocalizationsBn();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

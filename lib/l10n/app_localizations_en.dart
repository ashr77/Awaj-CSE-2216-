// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Auth System';

  @override
  String get appName => 'Awaj';

  @override
  String get home => 'Home';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get toggleLanguage => 'Toggle Language';

  @override
  String get toggleTheme => 'Toggle Theme';

  @override
  String get tagline => 'Report & Track Corruption Anonymously';

  @override
  String get exit => 'Exit';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get signInToContinueMission => 'Sign in to continue your mission.';

  @override
  String get email => 'Email';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get password => 'Password';

  @override
  String get enterValidPassword => 'Enter a valid password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get signingIn => 'Signing In...';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinMission => 'Join the Mission!';

  @override
  String get createAccountDescription => 'Create your account to report & track corruption.';

  @override
  String get addProfilePhoto => 'Add Profile Photo';

  @override
  String get fullName => 'Full Name';

  @override
  String get required => 'Required';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get nidBirthRegistration => 'NID / Birth Registration';

  @override
  String get phone => 'Phone';

  @override
  String get min6Characters => 'Min 6 characters';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match';

  @override
  String get signingUp => 'Signing Up...';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get allPosts => 'All Posts';

  @override
  String get allReports => 'All Reports';

  @override
  String get signOut => 'Sign Out';

  @override
  String get managePosts => 'Manage Posts';

  @override
  String get manageReports => 'Manage Reports';

  @override
  String get approve => 'Approve';

  @override
  String get decline => 'Decline';

  @override
  String get noReportsFound => 'No reports found.';

  @override
  String get by => 'By';

  @override
  String get city => 'City';

  @override
  String get office => 'Office';

  @override
  String get videoEvidence => 'Video Evidence';

  @override
  String get videoPreviewNotSupportedHere => 'Video preview not supported here.';

  @override
  String get openThisLinkInBrowser => 'Open this link in browser:';

  @override
  String get close => 'Close';

  @override
  String get viewVideo => 'View Video';

  @override
  String get deletePost => 'Delete Post';

  @override
  String get areYouSureDeletePost => 'Are you sure you want to delete this post?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get postDeleted => 'Post deleted.';

  @override
  String get authorHome => 'Author Home';

  @override
  String get viewConversations => 'View Conversations';

  @override
  String get reportRequests => 'Report Requests';

  @override
  String get viewChatRequests => 'View Chat Requests';

  @override
  String welcomeAuthor(Object name) {
    return 'Welcome, $name!';
  }

  @override
  String get author => 'Author';

  @override
  String get welcome => 'Welcome!';

  @override
  String get chooseAction => 'Choose an action below.';

  @override
  String get reportProblem => 'Report Problem';

  @override
  String get chat => 'Chat';

  @override
  String get post => 'Post';

  @override
  String get aboutMe => 'About Me';

  @override
  String get others => 'Others';

  @override
  String get submitReport => 'Submit Report';

  @override
  String get reportCorruption => 'Report Corruption';

  @override
  String get reportName => 'Report Name';

  @override
  String cityName(Object city) {
    return '$city';
  }

  @override
  String get selectCity => 'Select a city';

  @override
  String officeName(Object office) {
    return '$office';
  }

  @override
  String get selectOffice => 'Select an office';

  @override
  String get briefDescription => 'Brief Description';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get addVideo => 'Add Video';

  @override
  String get changeVideo => 'Change Video';

  @override
  String get videoAttached => 'Video Attached';

  @override
  String get submitting => 'Submitting...';

  @override
  String get chatRequests => 'Chat Requests';

  @override
  String get noPendingRequests => 'No pending requests';

  @override
  String get userNotFound => 'User not found';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get postCreatedSuccessfully => 'Post created successfully!';

  @override
  String errorCreatingPost(Object error) {
    return 'Error creating post: $error';
  }

  @override
  String get createPost => 'Create Post';

  @override
  String get whatDoYouWantToShare => 'What do you want to share?';

  @override
  String get addImage => 'Add Image';

  @override
  String get postAnonymously => 'Post Anonymously';

  @override
  String get editPost => 'Edit Post';

  @override
  String get editYourPost => 'Edit your post';

  @override
  String get save => 'Save';

  @override
  String get communityPosts => 'Community Posts';

  @override
  String get newPost => 'New Post';

  @override
  String get reportedThankYou => 'Reported. Thank you!';

  @override
  String get addAComment => 'Add a comment...';

  @override
  String get noCommentsYet => 'No comments yet';

  @override
  String get signInPrompt => 'Please sign in';

  @override
  String get userDataNotFound => 'User data not found';

  @override
  String get aboutMeTitle => 'About Me';

  @override
  String get profileInfoTitle => 'Profile Information';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get emailLabel => 'Email';

  @override
  String get nidLabel => 'NID';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get accountDetailsTitle => 'Account Details';

  @override
  String get accountCreatedLabel => 'Account Created';

  @override
  String get userIdLabel => 'User ID';

  @override
  String sectionTitle(Object title) {
    return '$title';
  }

  @override
  String get notProvided => 'Not provided';

  @override
  String get userTypeLabel => 'User Type: ';

  @override
  String get userTypeBadge => 'USER';

  @override
  String get checkReportStatus => 'Check Your Report Status';

  @override
  String get stayUpdatedOnReports => 'Stay updated on your submitted reports.';

  @override
  String get reportStatus => 'Report Status';

  @override
  String get aboutUs => 'About Us';

  @override
  String get yourChats => 'Your Chats';

  @override
  String get pleaseSignInToViewConversations => 'Please sign in to view conversations';

  @override
  String get yourConversations => 'Your Conversations';

  @override
  String get chatWithNewAuthority => 'Chat with new authority';

  @override
  String get noPostsFound => 'No posts found.';

  @override
  String get noConversationsYet => 'No conversations yet';

  @override
  String get acceptChatRequestsToStart => 'Accept chat requests to start conversations';

  @override
  String get loading => 'Loading...';

  @override
  String get authorReview => 'Author Review';

  @override
  String get pleaseSignInToAccess => 'Please sign in to access this feature';

  @override
  String get reportReview => 'Report Review';

  @override
  String get reportMarkedCompleted => 'Report marked as completed';

  @override
  String errorWithMessage(Object message) {
    return 'Error: $message';
  }

  @override
  String get errorLoadingReports => 'Error loading reports';

  @override
  String get noReportsToReview => 'No reports to review';

  @override
  String get allApprovedReportsHandled => 'All approved reports have been handled';

  @override
  String get completionFeedback => 'Completion Feedback: ';

  @override
  String get chatWithUser => 'Chat with User';

  @override
  String get complete => 'Complete';

  @override
  String get completeReport => 'Complete Report';

  @override
  String get completionFeedbackLabel => 'Completion Feedback';

  @override
  String get describeCompletionFeedback => 'Describe the completion/final feedback...';

  @override
  String get confirmLogout => 'Confirm Logout';

  @override
  String get areYouSureLogout => 'Are you sure you want to logout?';

  @override
  String get yesLogout => 'Yes, Logout';
}

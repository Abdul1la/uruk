import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_ckb.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ar'),
    Locale('ckb'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Uruk Motors'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Body & Paint Maintenance Center'**
  String get appTagline;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'v1.0.0 • Uruk Motors'**
  String get appVersion;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get commonSend;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get commonOr;

  /// No description provided for @commonRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get commonRequired;

  /// No description provided for @commonOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get commonOptional;

  /// No description provided for @commonUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get commonUpgrade;

  /// No description provided for @commonViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get commonViewAll;

  /// No description provided for @commonUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get commonUpload;

  /// No description provided for @commonRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get commonRetake;

  /// No description provided for @commonPrint.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get commonPrint;

  /// No description provided for @commonMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get commonMarkAllRead;

  /// No description provided for @commonSendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get commonSendRequest;

  /// No description provided for @commonAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get commonAddPhoto;

  /// No description provided for @commonErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get commonErrorGeneric;

  /// No description provided for @authSuspendedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account is suspended'**
  String get authSuspendedTitle;

  /// No description provided for @authSuspendedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account has been suspended. Please contact support for more information.'**
  String get authSuspendedMessage;

  /// No description provided for @authRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account was rejected'**
  String get authRejectedTitle;

  /// No description provided for @authRejectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account application was rejected. Please contact support for more details.'**
  String get authRejectedMessage;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAccidents.
  ///
  /// In en, this message translates to:
  /// **'Accidents'**
  String get navAccidents;

  /// No description provided for @navAppointments.
  ///
  /// In en, this message translates to:
  /// **'Appts'**
  String get navAppointments;

  /// No description provided for @navPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get navPayment;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get loginSubtitle;

  /// No description provided for @loginPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get loginPhone;

  /// No description provided for @loginPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+964 7xx xxx xxxx'**
  String get loginPhoneHint;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSignInButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @loginRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get loginRegister;

  /// No description provided for @loginContinueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Browse as Guest'**
  String get loginContinueAsGuest;

  /// No description provided for @guestBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'Browsing as guest'**
  String get guestBannerMessage;

  /// No description provided for @guestBannerAction.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get guestBannerAction;

  /// No description provided for @guestLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get guestLoginRequired;

  /// No description provided for @guestLoginRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'You need to log in to access this feature.'**
  String get guestLoginRequiredMessage;

  /// No description provided for @guestLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get guestLoginButton;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in your details to get started.'**
  String get registerSubtitle;

  /// No description provided for @registerFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get registerFullName;

  /// No description provided for @registerFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Ahmed Al-Rashidi'**
  String get registerFullNameHint;

  /// No description provided for @registerPhone.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get registerPhone;

  /// No description provided for @registerPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+964 7xx xxx xxxx'**
  String get registerPhoneHint;

  /// No description provided for @registerEmailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (Optional)'**
  String get registerEmailOptional;

  /// No description provided for @registerEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@email.com'**
  String get registerEmailHint;

  /// No description provided for @registerPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPassword;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerConfirmPassword;

  /// No description provided for @registerNextVerify.
  ///
  /// In en, this message translates to:
  /// **'Next — Verify Mobile'**
  String get registerNextVerify;

  /// No description provided for @registerAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get registerAlreadyHaveAccount;

  /// No description provided for @registerSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get registerSignIn;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Number'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {phone}'**
  String otpSubtitle(String phone);

  /// No description provided for @otpEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit code'**
  String get otpEnterCode;

  /// No description provided for @otpInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP. Please try again.'**
  String get otpInvalidCode;

  /// No description provided for @otpDidntReceive.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive code? '**
  String get otpDidntReceive;

  /// No description provided for @otpResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String otpResendIn(int seconds);

  /// No description provided for @otpResend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get otpResend;

  /// No description provided for @idUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Your ID'**
  String get idUploadTitle;

  /// No description provided for @idUploadBothSidesRequired.
  ///
  /// In en, this message translates to:
  /// **'Please upload both sides of your ID'**
  String get idUploadBothSidesRequired;

  /// No description provided for @idUploadInstructions.
  ///
  /// In en, this message translates to:
  /// **'Please upload clear photos of your Iraqi National ID card. Both sides are required.'**
  String get idUploadInstructions;

  /// No description provided for @idUploadFrontSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the front side'**
  String get idUploadFrontSubtitle;

  /// No description provided for @idUploadBackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the back side'**
  String get idUploadBackSubtitle;

  /// No description provided for @idUploadSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Application'**
  String get idUploadSubmit;

  /// No description provided for @idUploadDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Your ID is securely stored and only visible to our admin team.'**
  String get idUploadDisclaimer;

  /// No description provided for @idUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Photo uploaded successfully'**
  String get idUploadSuccess;

  /// No description provided for @idUploadRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get idUploadRetake;

  /// No description provided for @pendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Application Under Review'**
  String get pendingTitle;

  /// No description provided for @pendingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your application is being reviewed by our team.'**
  String get pendingSubtitle;

  /// No description provided for @pendingStep1.
  ///
  /// In en, this message translates to:
  /// **'Account created'**
  String get pendingStep1;

  /// No description provided for @pendingStep2.
  ///
  /// In en, this message translates to:
  /// **'ID verification submitted'**
  String get pendingStep2;

  /// No description provided for @pendingStep3.
  ///
  /// In en, this message translates to:
  /// **'Admin review (1–2 business days)'**
  String get pendingStep3;

  /// No description provided for @pendingStep4.
  ///
  /// In en, this message translates to:
  /// **'Account activated'**
  String get pendingStep4;

  /// No description provided for @pendingSmsNotification.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send you an SMS notification when your account is approved.'**
  String get pendingSmsNotification;

  /// No description provided for @pendingBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get pendingBackToLogin;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Body & Paint Maintenance Center'**
  String get splashTagline;

  /// No description provided for @onboard1Title.
  ///
  /// In en, this message translates to:
  /// **'Report Accidents Easily'**
  String get onboard1Title;

  /// No description provided for @onboard1Desc.
  ///
  /// In en, this message translates to:
  /// **'Submit accident reports with photos directly from your phone.'**
  String get onboard1Desc;

  /// No description provided for @onboard2Title.
  ///
  /// In en, this message translates to:
  /// **'Track Your Repairs'**
  String get onboard2Title;

  /// No description provided for @onboard2Desc.
  ///
  /// In en, this message translates to:
  /// **'Follow every repair step in real time and view the full maintenance history.'**
  String get onboard2Desc;

  /// No description provided for @onboard3Title.
  ///
  /// In en, this message translates to:
  /// **'Manage Payments'**
  String get onboard3Title;

  /// No description provided for @onboard3Desc.
  ///
  /// In en, this message translates to:
  /// **'Pay your monthly subscription and view complete payment history.'**
  String get onboard3Desc;

  /// No description provided for @onboardSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardSkip;

  /// No description provided for @onboardGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardGetStarted;

  /// No description provided for @onboardAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get onboardAlreadyHaveAccount;

  /// No description provided for @onboardSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get onboardSignIn;

  /// No description provided for @garageTitle.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get garageTitle;

  /// No description provided for @garageMyCarsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'My Cars'**
  String get garageMyCarsSectionTitle;

  /// No description provided for @garageCarsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No cars} =1{1 car} other{{count} cars}}'**
  String garageCarsCount(int count);

  /// No description provided for @garageNoCarYet.
  ///
  /// In en, this message translates to:
  /// **'No cars added yet'**
  String get garageNoCarYet;

  /// No description provided for @garageAddCarButton.
  ///
  /// In en, this message translates to:
  /// **'Add New Car'**
  String get garageAddCarButton;

  /// No description provided for @garageSubActive.
  ///
  /// In en, this message translates to:
  /// **'{planName} Active'**
  String garageSubActive(String planName);

  /// No description provided for @garageNoSubscription.
  ///
  /// In en, this message translates to:
  /// **'No Subscription'**
  String get garageNoSubscription;

  /// No description provided for @garageSelectCar.
  ///
  /// In en, this message translates to:
  /// **'Select a car to view details'**
  String get garageSelectCar;

  /// No description provided for @carAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Your Car'**
  String get carAddTitle;

  /// No description provided for @carEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Car Data Change'**
  String get carEditTitle;

  /// No description provided for @carMakeLabel.
  ///
  /// In en, this message translates to:
  /// **'Make *'**
  String get carMakeLabel;

  /// No description provided for @carMakeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Toyota'**
  String get carMakeHint;

  /// No description provided for @carModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Model *'**
  String get carModelLabel;

  /// No description provided for @carModelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Camry'**
  String get carModelHint;

  /// No description provided for @carYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year *'**
  String get carYearLabel;

  /// No description provided for @carYearHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 2020'**
  String get carYearHint;

  /// No description provided for @carColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color *'**
  String get carColorLabel;

  /// No description provided for @carColorHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. White'**
  String get carColorHint;

  /// No description provided for @carPlateLabel.
  ///
  /// In en, this message translates to:
  /// **'Plate Number *'**
  String get carPlateLabel;

  /// No description provided for @carPlateHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 12345 - Baghdad'**
  String get carPlateHint;

  /// No description provided for @carSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Car data saved successfully'**
  String get carSaveSuccess;

  /// No description provided for @carNoChanges.
  ///
  /// In en, this message translates to:
  /// **'No changes were made'**
  String get carNoChanges;

  /// No description provided for @carChangeRequestSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Sent'**
  String get carChangeRequestSentTitle;

  /// No description provided for @carChangeRequestSentContent.
  ///
  /// In en, this message translates to:
  /// **'Your car data change request has been sent to admin for review. Data will be updated after admin approval.'**
  String get carChangeRequestSentContent;

  /// No description provided for @carChangesLabel.
  ///
  /// In en, this message translates to:
  /// **'Requested changes:'**
  String get carChangesLabel;

  /// No description provided for @carPendingRequestWarning.
  ///
  /// In en, this message translates to:
  /// **'A change request is under review'**
  String get carPendingRequestWarning;

  /// No description provided for @carSubscriptionActivatedBanner.
  ///
  /// In en, this message translates to:
  /// **'Your subscription is activated! Add your car details now to complete your profile.'**
  String get carSubscriptionActivatedBanner;

  /// No description provided for @carEditModeNote.
  ///
  /// In en, this message translates to:
  /// **'Changes are not applied immediately — they will be sent to admin for review.'**
  String get carEditModeNote;

  /// No description provided for @carAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Car'**
  String get carAddButton;

  /// No description provided for @carSendChangeButton.
  ///
  /// In en, this message translates to:
  /// **'Send Change Request'**
  String get carSendChangeButton;

  /// No description provided for @carSkipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get carSkipButton;

  /// No description provided for @carPhotoAddLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Car Photo'**
  String get carPhotoAddLabel;

  /// No description provided for @carPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Helps you tell your cars apart'**
  String get carPhotoHint;

  /// No description provided for @carPhotoChangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get carPhotoChangeLabel;

  /// No description provided for @subscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription Plans'**
  String get subscriptionTitle;

  /// No description provided for @subscriptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the plan that fits you. You can upgrade anytime.'**
  String get subscriptionSubtitle;

  /// No description provided for @subscriptionPerMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get subscriptionPerMonth;

  /// No description provided for @subscriptionCurrentPlan.
  ///
  /// In en, this message translates to:
  /// **'Your Current Plan'**
  String get subscriptionCurrentPlan;

  /// No description provided for @subscriptionMostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get subscriptionMostPopular;

  /// No description provided for @subscriptionCoveredPartsTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s covered'**
  String get subscriptionCoveredPartsTitle;

  /// No description provided for @subscriptionPaymentPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get subscriptionPaymentPeriodTitle;

  /// No description provided for @subscriptionPaymentPeriodHint.
  ///
  /// In en, this message translates to:
  /// **'Prepayment gives you more monthly repairs.'**
  String get subscriptionPaymentPeriodHint;

  /// No description provided for @subscriptionRepairsPerMonth.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{repair} other{repairs}}/month'**
  String subscriptionRepairsPerMonth(int count);

  /// No description provided for @subscriptionDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'All plans cover exterior damage only (doors, bumpers, body). Does not include engine, mechanical parts, glass, or lights.'**
  String get subscriptionDisclaimer;

  /// No description provided for @subscriptionConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Subscription'**
  String get subscriptionConfirmTitle;

  /// No description provided for @subscriptionPlanLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get subscriptionPlanLabel;

  /// No description provided for @subscriptionPaymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get subscriptionPaymentMethodLabel;

  /// No description provided for @subscriptionRepairsLabel.
  ///
  /// In en, this message translates to:
  /// **'Repairs / month'**
  String get subscriptionRepairsLabel;

  /// No description provided for @subscriptionTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get subscriptionTotalLabel;

  /// No description provided for @subscriptionConfirmNote.
  ///
  /// In en, this message translates to:
  /// **'Our team will contact you to process the first payment and activate your subscription.'**
  String get subscriptionConfirmNote;

  /// No description provided for @subscriptionSubscribeButton.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscriptionSubscribeButton;

  /// No description provided for @subscriptionSelectPlan.
  ///
  /// In en, this message translates to:
  /// **'Select a Plan'**
  String get subscriptionSelectPlan;

  /// No description provided for @subscriptionPeriodMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get subscriptionPeriodMonthly;

  /// No description provided for @subscriptionPeriod3Months.
  ///
  /// In en, this message translates to:
  /// **'3 Months Prepaid'**
  String get subscriptionPeriod3Months;

  /// No description provided for @subscriptionPeriod6Months.
  ///
  /// In en, this message translates to:
  /// **'6 Months Prepaid'**
  String get subscriptionPeriod6Months;

  /// No description provided for @subscriptionPeriod12Months.
  ///
  /// In en, this message translates to:
  /// **'1 Year Prepaid'**
  String get subscriptionPeriod12Months;

  /// No description provided for @accidentHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Accident Reports'**
  String get accidentHistoryTitle;

  /// No description provided for @accidentHistoryNewReportTooltip.
  ///
  /// In en, this message translates to:
  /// **'New Report'**
  String get accidentHistoryNewReportTooltip;

  /// No description provided for @accidentHistoryDraftsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get accidentHistoryDraftsSectionTitle;

  /// No description provided for @accidentHistoryTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get accidentHistoryTotal;

  /// No description provided for @accidentHistoryCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get accidentHistoryCompleted;

  /// No description provided for @accidentHistoryUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get accidentHistoryUnderReview;

  /// No description provided for @accidentHistoryNewReportFab.
  ///
  /// In en, this message translates to:
  /// **'New Report'**
  String get accidentHistoryNewReportFab;

  /// No description provided for @accidentHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No Reports'**
  String get accidentHistoryEmpty;

  /// No description provided for @accidentHistoryEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'If your car is involved in an accident, report it here and our team will handle the repairs.'**
  String get accidentHistoryEmptyDesc;

  /// No description provided for @accidentHistorySubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Report an Accident'**
  String get accidentHistorySubmitButton;

  /// No description provided for @accidentHistoryDeleteDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Draft'**
  String get accidentHistoryDeleteDraftTitle;

  /// No description provided for @accidentHistoryDeleteDraftContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this draft?'**
  String get accidentHistoryDeleteDraftContent;

  /// No description provided for @accidentHistoryOtherPartyInvolved.
  ///
  /// In en, this message translates to:
  /// **'Other party involved'**
  String get accidentHistoryOtherPartyInvolved;

  /// No description provided for @accidentHistoryPhotosCount.
  ///
  /// In en, this message translates to:
  /// **'{count} photos'**
  String accidentHistoryPhotosCount(int count);

  /// No description provided for @accidentHistoryLastModified.
  ///
  /// In en, this message translates to:
  /// **'Last modified: {dateTime}'**
  String accidentHistoryLastModified(String dateTime);

  /// No description provided for @accidentHistoryCoordinatesSet.
  ///
  /// In en, this message translates to:
  /// **'Coordinates set'**
  String get accidentHistoryCoordinatesSet;

  /// No description provided for @accidentHistorySwipeToDelete.
  ///
  /// In en, this message translates to:
  /// **'Swipe left to delete'**
  String get accidentHistorySwipeToDelete;

  /// No description provided for @accidentReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Accident'**
  String get accidentReportTitle;

  /// No description provided for @accidentEditDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Draft'**
  String get accidentEditDraftTitle;

  /// No description provided for @accidentDraftButton.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get accidentDraftButton;

  /// No description provided for @accidentDraftEditingNote.
  ///
  /// In en, this message translates to:
  /// **'You are editing a saved draft. You can submit or save again.'**
  String get accidentDraftEditingNote;

  /// No description provided for @accidentInfoBanner.
  ///
  /// In en, this message translates to:
  /// **'Fill in the accident details accurately. Our team will review and schedule a repair appointment.'**
  String get accidentInfoBanner;

  /// No description provided for @accidentPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Accident Photos *'**
  String get accidentPhotosTitle;

  /// No description provided for @accidentPhotosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add clear photos of the damage and accident scene'**
  String get accidentPhotosSubtitle;

  /// No description provided for @accidentPhotosMaxReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum {max} photos'**
  String accidentPhotosMaxReached(int max);

  /// No description provided for @accidentPhotosTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get accidentPhotosTakePhoto;

  /// No description provided for @accidentPhotosFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get accidentPhotosFromGallery;

  /// No description provided for @accidentPhotosCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{used}/{allowed}'**
  String accidentPhotosCountLabel(int used, int allowed);

  /// No description provided for @accidentDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Accident Date *'**
  String get accidentDateTitle;

  /// No description provided for @accidentLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Accident Location *'**
  String get accidentLocationTitle;

  /// No description provided for @accidentLocationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Al-Karada, Baghdad'**
  String get accidentLocationHint;

  /// No description provided for @accidentLocationGpsTooltip.
  ///
  /// In en, this message translates to:
  /// **'My Current Location'**
  String get accidentLocationGpsTooltip;

  /// No description provided for @accidentLocationMapTooltip.
  ///
  /// In en, this message translates to:
  /// **'Choose on Map'**
  String get accidentLocationMapTooltip;

  /// No description provided for @accidentLocationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied. Please enable it from device settings.'**
  String get accidentLocationPermissionDenied;

  /// No description provided for @accidentLocationGpsError.
  ///
  /// In en, this message translates to:
  /// **'Could not get location. Make sure GPS is enabled.'**
  String get accidentLocationGpsError;

  /// No description provided for @accidentDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Describe the Damage *'**
  String get accidentDescriptionLabel;

  /// No description provided for @accidentDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what happened and what was damaged...'**
  String get accidentDescriptionHint;

  /// No description provided for @accidentOtherPartyTitle.
  ///
  /// In en, this message translates to:
  /// **'Was there another party?'**
  String get accidentOtherPartyTitle;

  /// No description provided for @accidentOtherPartySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Was another vehicle involved in this accident?'**
  String get accidentOtherPartySubtitle;

  /// No description provided for @accidentSaveDraftButton.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get accidentSaveDraftButton;

  /// No description provided for @accidentSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get accidentSubmitButton;

  /// No description provided for @accidentDraftSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Draft saved successfully'**
  String get accidentDraftSavedSuccess;

  /// No description provided for @accidentSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report submitted successfully! Our team will review it shortly.'**
  String get accidentSubmittedSuccess;

  /// No description provided for @accidentPhotosRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one photo of the accident'**
  String get accidentPhotosRequiredError;

  /// No description provided for @accidentRepairLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Limit Reached'**
  String get accidentRepairLimitTitle;

  /// No description provided for @accidentRepairLimitContent.
  ///
  /// In en, this message translates to:
  /// **'You have used all your monthly repairs ({used}/{allowed}). Upgrade your plan or wait for the next month.'**
  String accidentRepairLimitContent(int used, int allowed);

  /// No description provided for @accidentRepairLimitUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Plan'**
  String get accidentRepairLimitUpgrade;

  /// No description provided for @accidentDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Details'**
  String get accidentDetailTitle;

  /// No description provided for @accidentDetailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Report not found'**
  String get accidentDetailNotFound;

  /// No description provided for @accidentDetailPrintTooltip.
  ///
  /// In en, this message translates to:
  /// **'Print Report'**
  String get accidentDetailPrintTooltip;

  /// No description provided for @accidentDetailInfoSection.
  ///
  /// In en, this message translates to:
  /// **'Accident Information'**
  String get accidentDetailInfoSection;

  /// No description provided for @accidentDetailDescSection.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get accidentDetailDescSection;

  /// No description provided for @accidentDetailPhotosSection.
  ///
  /// In en, this message translates to:
  /// **'Accident Photos ({count})'**
  String accidentDetailPhotosSection(int count);

  /// No description provided for @accidentDetailMaintenanceSection.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Notes'**
  String get accidentDetailMaintenanceSection;

  /// No description provided for @accidentDetailRepairPhotosSection.
  ///
  /// In en, this message translates to:
  /// **'Repair Photos ({count})'**
  String accidentDetailRepairPhotosSection(int count);

  /// No description provided for @accidentDetailDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get accidentDetailDateLabel;

  /// No description provided for @accidentDetailLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get accidentDetailLocationLabel;

  /// No description provided for @accidentDetailSubmittedLabel.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get accidentDetailSubmittedLabel;

  /// No description provided for @accidentDetailOtherPartyLabel.
  ///
  /// In en, this message translates to:
  /// **'Other Party'**
  String get accidentDetailOtherPartyLabel;

  /// No description provided for @accidentDetailYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get accidentDetailYes;

  /// No description provided for @accidentDetailNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get accidentDetailNo;

  /// No description provided for @accidentDetailCompletedAt.
  ///
  /// In en, this message translates to:
  /// **'Completed on {date}'**
  String accidentDetailCompletedAt(String date);

  /// No description provided for @accidentDetailUploadSection.
  ///
  /// In en, this message translates to:
  /// **'Add Repair Photos'**
  String get accidentDetailUploadSection;

  /// No description provided for @accidentDetailUploadHint.
  ///
  /// In en, this message translates to:
  /// **'Attach clear photos showing the car\'s condition after repair.'**
  String get accidentDetailUploadHint;

  /// No description provided for @accidentDetailUploadPendingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} photo(s)'**
  String accidentDetailUploadPendingCount(int count);

  /// No description provided for @accidentDetailUploadAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get accidentDetailUploadAddButton;

  /// No description provided for @accidentDetailUploadSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Send Repair Photos ({count})'**
  String accidentDetailUploadSubmitButton(int count);

  /// No description provided for @accidentDetailUploadSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get accidentDetailUploadSubmitting;

  /// No description provided for @accidentDetailUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Repair photos sent successfully'**
  String get accidentDetailUploadSuccess;

  /// No description provided for @accidentDetailUploadError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get accidentDetailUploadError;

  /// No description provided for @accidentDetailPrintTitle.
  ///
  /// In en, this message translates to:
  /// **'Print Report'**
  String get accidentDetailPrintTitle;

  /// No description provided for @accidentDetailPrintContent.
  ///
  /// In en, this message translates to:
  /// **'A PDF file will be generated with the accident report details.'**
  String get accidentDetailPrintContent;

  /// No description provided for @accidentDetailPrintButton.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get accidentDetailPrintButton;

  /// No description provided for @accidentDetailPrintPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'PDF generated (requires backend integration)'**
  String get accidentDetailPrintPlaceholder;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get statusUnderReview;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusInRepair.
  ///
  /// In en, this message translates to:
  /// **'In Repair'**
  String get statusInRepair;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get statusScheduled;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusChangeRequested.
  ///
  /// In en, this message translates to:
  /// **'Change Requested'**
  String get statusChangeRequested;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get statusUnpaid;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get statusOverdue;

  /// No description provided for @statusNoPlan.
  ///
  /// In en, this message translates to:
  /// **'No Plan'**
  String get statusNoPlan;

  /// No description provided for @statusStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get statusStandard;

  /// No description provided for @statusShared.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get statusShared;

  /// No description provided for @statusVip.
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get statusVip;

  /// No description provided for @homeRecentReports.
  ///
  /// In en, this message translates to:
  /// **'Recent Reports'**
  String get homeRecentReports;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get homeViewAll;

  /// No description provided for @homeNoReports.
  ///
  /// In en, this message translates to:
  /// **'No reports yet'**
  String get homeNoReports;

  /// No description provided for @homeGarageBack.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get homeGarageBack;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get greetingEvening;

  /// No description provided for @homeMemberFallback.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get homeMemberFallback;

  /// No description provided for @homeMySubscription.
  ///
  /// In en, this message translates to:
  /// **'My Subscription'**
  String get homeMySubscription;

  /// No description provided for @homeRepairsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Repairs this month'**
  String get homeRepairsThisMonth;

  /// No description provided for @homeRepairsExhausted.
  ///
  /// In en, this message translates to:
  /// **'Monthly repair limit reached. Renews next month.'**
  String get homeRepairsExhausted;

  /// No description provided for @homeRepairsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 repair remaining} other{{count} repairs remaining}} this month'**
  String homeRepairsRemaining(int count);

  /// No description provided for @homeSubscriptionStart.
  ///
  /// In en, this message translates to:
  /// **'Started on {date}'**
  String homeSubscriptionStart(String date);

  /// No description provided for @homeSubscriptionExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expires on {date}'**
  String homeSubscriptionExpiry(String date);

  /// No description provided for @homeUpgradeLink.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get homeUpgradeLink;

  /// No description provided for @homeNoSubscription.
  ///
  /// In en, this message translates to:
  /// **'No active subscription.\nSubscribe to get exterior damage coverage.'**
  String get homeNoSubscription;

  /// No description provided for @homeSubscribeButton.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get homeSubscribeButton;

  /// No description provided for @homePaymentDue.
  ///
  /// In en, this message translates to:
  /// **'Payment due! Tap here to pay your subscription.'**
  String get homePaymentDue;

  /// No description provided for @homeQuickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get homeQuickActionsTitle;

  /// No description provided for @homeReportAccident.
  ///
  /// In en, this message translates to:
  /// **'Report\nAccident'**
  String get homeReportAccident;

  /// No description provided for @homeOilChange.
  ///
  /// In en, this message translates to:
  /// **'Oil\nChange'**
  String get homeOilChange;

  /// No description provided for @homeMyAppointments.
  ///
  /// In en, this message translates to:
  /// **'My\nAppts'**
  String get homeMyAppointments;

  /// No description provided for @homeMyPlan.
  ///
  /// In en, this message translates to:
  /// **'My\nPlan'**
  String get homeMyPlan;

  /// No description provided for @homeUpcomingAppointmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Appointment'**
  String get homeUpcomingAppointmentTitle;

  /// No description provided for @homeViewButton.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get homeViewButton;

  /// No description provided for @appointmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Appointments'**
  String get appointmentsTitle;

  /// No description provided for @appointmentsUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Appointment'**
  String get appointmentsUpcoming;

  /// No description provided for @appointmentsPast.
  ///
  /// In en, this message translates to:
  /// **'Past Appointment'**
  String get appointmentsPast;

  /// No description provided for @appointmentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No Appointments'**
  String get appointmentsEmpty;

  /// No description provided for @appointmentsEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Once you submit an accident report, our maintenance team will schedule an appointment for you.'**
  String get appointmentsEmptyDesc;

  /// No description provided for @appointmentsChangeTime.
  ///
  /// In en, this message translates to:
  /// **'Request Time Change'**
  String get appointmentsChangeTime;

  /// No description provided for @appointmentsChangeRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Change request sent — waiting for confirmation'**
  String get appointmentsChangeRequestSent;

  /// No description provided for @appointmentsYourNote.
  ///
  /// In en, this message translates to:
  /// **'Your note: {note}'**
  String appointmentsYourNote(String note);

  /// No description provided for @appointmentsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Appointment Change'**
  String get appointmentsDialogTitle;

  /// No description provided for @appointmentsDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Please provide a reason or preferred alternative time:'**
  String get appointmentsDialogContent;

  /// No description provided for @appointmentsDialogHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. I have work on this day, please reschedule to the afternoon...'**
  String get appointmentsDialogHint;

  /// No description provided for @paymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentTitle;

  /// No description provided for @paymentHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistoryTitle;

  /// No description provided for @paymentConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get paymentConfirmTitle;

  /// No description provided for @paymentMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get paymentMethodTitle;

  /// No description provided for @paymentZainCash.
  ///
  /// In en, this message translates to:
  /// **'ZainCash'**
  String get paymentZainCash;

  /// No description provided for @paymentZainCashDesc.
  ///
  /// In en, this message translates to:
  /// **'Transfer via ZainCash wallet'**
  String get paymentZainCashDesc;

  /// No description provided for @paymentZainCashAccount.
  ///
  /// In en, this message translates to:
  /// **'+964 770 000 0000'**
  String get paymentZainCashAccount;

  /// No description provided for @paymentSuperQi.
  ///
  /// In en, this message translates to:
  /// **'Super QI'**
  String get paymentSuperQi;

  /// No description provided for @paymentSuperQiDesc.
  ///
  /// In en, this message translates to:
  /// **'Send directly — no bank needed'**
  String get paymentSuperQiDesc;

  /// No description provided for @paymentSuperQiAccount.
  ///
  /// In en, this message translates to:
  /// **'07XX-XXX-XXXX'**
  String get paymentSuperQiAccount;

  /// No description provided for @paymentOther.
  ///
  /// In en, this message translates to:
  /// **'Other Method'**
  String get paymentOther;

  /// No description provided for @paymentOtherDesc.
  ///
  /// In en, this message translates to:
  /// **'Another payment method'**
  String get paymentOtherDesc;

  /// No description provided for @paymentAccountNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get paymentAccountNumberLabel;

  /// No description provided for @paymentProofUploadLabel.
  ///
  /// In en, this message translates to:
  /// **'Upload Payment Proof'**
  String get paymentProofUploadLabel;

  /// No description provided for @paymentProofUploadHint.
  ///
  /// In en, this message translates to:
  /// **'Photo or screenshot of your transfer receipt'**
  String get paymentProofUploadHint;

  /// No description provided for @paymentProofChangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get paymentProofChangeLabel;

  /// No description provided for @paymentIvePaid.
  ///
  /// In en, this message translates to:
  /// **'I\'ve Paid {amount}'**
  String paymentIvePaid(String amount);

  /// No description provided for @paymentZainCashInstructionsTitle.
  ///
  /// In en, this message translates to:
  /// **'ZainCash Transfer Instructions'**
  String get paymentZainCashInstructionsTitle;

  /// No description provided for @paymentSuperQiInstructionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Super QI Transfer Instructions'**
  String get paymentSuperQiInstructionsTitle;

  /// No description provided for @paymentOtherInstructionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Other Payment Instructions'**
  String get paymentOtherInstructionsTitle;

  /// No description provided for @paymentVerificationNote.
  ///
  /// In en, this message translates to:
  /// **'Our accounts team will verify your payment within 24 hours.'**
  String get paymentVerificationNote;

  /// No description provided for @paymentAllPaid.
  ///
  /// In en, this message translates to:
  /// **'All Paid!'**
  String get paymentAllPaid;

  /// No description provided for @paymentNoPending.
  ///
  /// In en, this message translates to:
  /// **'No pending payments. Thank you!'**
  String get paymentNoPending;

  /// No description provided for @paymentPaidOn.
  ///
  /// In en, this message translates to:
  /// **'Paid on {date}'**
  String paymentPaidOn(String date);

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmpty;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @profileEditCarTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit Car'**
  String get profileEditCarTooltip;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get profilePersonalInfo;

  /// No description provided for @profileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get profileFullName;

  /// No description provided for @profileMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get profileMobile;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profileMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get profileMemberSince;

  /// No description provided for @profileNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get profileNotProvided;

  /// No description provided for @profileCarSection.
  ///
  /// In en, this message translates to:
  /// **'Car {number}: {make} {model}'**
  String profileCarSection(int number, String make, String model);

  /// No description provided for @profileCarMake.
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get profileCarMake;

  /// No description provided for @profileCarModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get profileCarModel;

  /// No description provided for @profileCarYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get profileCarYear;

  /// No description provided for @profileCarColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get profileCarColor;

  /// No description provided for @profileCarPlate.
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get profileCarPlate;

  /// No description provided for @profileNationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get profileNationalId;

  /// No description provided for @profileIdUploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get profileIdUploaded;

  /// No description provided for @profileIdNotUploaded.
  ///
  /// In en, this message translates to:
  /// **'Not uploaded'**
  String get profileIdNotUploaded;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// No description provided for @profileLogoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogoutConfirmTitle;

  /// No description provided for @profileLogoutConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get profileLogoutConfirmContent;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get profileDeleteAccountConfirmTitle;

  /// No description provided for @profileDeleteAccountConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and all related data — your profile, cars, subscriptions, payments, appointments, and accident reports. This action cannot be undone.'**
  String get profileDeleteAccountConfirmContent;

  /// No description provided for @profileDeleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get profileDeleteAccountButton;

  /// No description provided for @profileDeleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get profileDeleteAccountSuccess;

  /// No description provided for @profileDeleteAccountError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete your account. Please try again.'**
  String get profileDeleteAccountError;

  /// No description provided for @profileMemberFallback.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get profileMemberFallback;

  /// No description provided for @oilChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Oil Change Booking'**
  String get oilChangeTitle;

  /// No description provided for @oilChangeServiceName.
  ///
  /// In en, this message translates to:
  /// **'Car Oil Change'**
  String get oilChangeServiceName;

  /// No description provided for @oilChangeServiceNote.
  ///
  /// In en, this message translates to:
  /// **'Additional service — not included in subscription'**
  String get oilChangeServiceNote;

  /// No description provided for @oilChangePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'IQD'**
  String get oilChangePriceLabel;

  /// No description provided for @oilChangeSelectCarTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Car'**
  String get oilChangeSelectCarTitle;

  /// No description provided for @oilChangeDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get oilChangeDateTitle;

  /// No description provided for @oilChangeTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get oilChangeTimeTitle;

  /// No description provided for @oilChangeNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get oilChangeNotesTitle;

  /// No description provided for @oilChangeNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. I prefer 5W-30 oil...'**
  String get oilChangeNotesHint;

  /// No description provided for @oilChangeBookButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get oilChangeBookButton;

  /// No description provided for @oilChangeValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please select car, date, and time slot'**
  String get oilChangeValidationError;

  /// No description provided for @oilChangeTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get oilChangeTakePhoto;

  /// No description provided for @oilChangeFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get oilChangeFromGallery;

  /// No description provided for @mapPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Location on Map'**
  String get mapPickerTitle;

  /// No description provided for @mapPickerConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get mapPickerConfirmButton;

  /// No description provided for @mapPickerAppBarConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get mapPickerAppBarConfirm;

  /// No description provided for @mapPickerHint.
  ///
  /// In en, this message translates to:
  /// **'Tap on the map to set the accident location'**
  String get mapPickerHint;

  /// No description provided for @mapPickerGpsTooltip.
  ///
  /// In en, this message translates to:
  /// **'My Current Location'**
  String get mapPickerGpsTooltip;

  /// No description provided for @mapPickerGpsError.
  ///
  /// In en, this message translates to:
  /// **'Could not get location. Make sure GPS is enabled.'**
  String get mapPickerGpsError;

  /// No description provided for @mapPickerPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied. Please enable it from device settings.'**
  String get mapPickerPermissionDenied;

  /// No description provided for @mapPickerSelectFirst.
  ///
  /// In en, this message translates to:
  /// **'Tap on the map to set a location first'**
  String get mapPickerSelectFirst;

  /// No description provided for @draftLocationUnknown.
  ///
  /// In en, this message translates to:
  /// **'Location not specified'**
  String get draftLocationUnknown;

  /// No description provided for @draftLastModified.
  ///
  /// In en, this message translates to:
  /// **'Last modified: {dateTime}'**
  String draftLastModified(String dateTime);

  /// No description provided for @draftBadge.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draftBadge;

  /// No description provided for @draftSwipeToDelete.
  ///
  /// In en, this message translates to:
  /// **'Swipe left to delete'**
  String get draftSwipeToDelete;

  /// No description provided for @draftCoordinatesSet.
  ///
  /// In en, this message translates to:
  /// **'Coordinates set'**
  String get draftCoordinatesSet;

  /// No description provided for @draftEditingNote.
  ///
  /// In en, this message translates to:
  /// **'You are editing a saved draft. You can submit or save again.'**
  String get draftEditingNote;

  /// No description provided for @draftSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Draft saved successfully'**
  String get draftSavedSuccess;

  /// No description provided for @validatorPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get validatorPhoneRequired;

  /// No description provided for @validatorPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get validatorPhoneInvalid;

  /// No description provided for @validatorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get validatorPasswordRequired;

  /// No description provided for @validatorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validatorPasswordTooShort;

  /// No description provided for @validatorConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get validatorConfirmPasswordRequired;

  /// No description provided for @validatorPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validatorPasswordsMismatch;

  /// No description provided for @validatorRequired.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} is required'**
  String validatorRequired(String fieldName);

  /// No description provided for @validatorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get validatorNameRequired;

  /// No description provided for @validatorNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get validatorNameTooShort;

  /// No description provided for @validatorEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validatorEmailInvalid;

  /// No description provided for @validatorYearRequired.
  ///
  /// In en, this message translates to:
  /// **'Year is required'**
  String get validatorYearRequired;

  /// No description provided for @validatorYearInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid year (1990–2030)'**
  String get validatorYearInvalid;

  /// No description provided for @idFrontLabel.
  ///
  /// In en, this message translates to:
  /// **'Front Side'**
  String get idFrontLabel;

  /// No description provided for @idBackLabel.
  ///
  /// In en, this message translates to:
  /// **'Back Side'**
  String get idBackLabel;

  /// No description provided for @idUploadTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload'**
  String get idUploadTapHint;

  /// No description provided for @paymentDueLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Due'**
  String get paymentDueLabel;

  /// No description provided for @paymentDueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due: {date}'**
  String paymentDueDateLabel(String date);

  /// No description provided for @paymentConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Confirm that you have transferred {amount} via {method} for {month}?'**
  String paymentConfirmContent(String amount, String method, String month);

  /// No description provided for @paymentMethodZainCash.
  ///
  /// In en, this message translates to:
  /// **'ZainCash'**
  String get paymentMethodZainCash;

  /// No description provided for @paymentMethodSuperQi.
  ///
  /// In en, this message translates to:
  /// **'Super QI'**
  String get paymentMethodSuperQi;

  /// No description provided for @paymentMethodOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get paymentMethodOther;

  /// No description provided for @paymentSnackbarSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment marked. Our accounts team will verify within 24 hours.'**
  String get paymentSnackbarSuccess;

  /// No description provided for @paymentZainCashStep1.
  ///
  /// In en, this message translates to:
  /// **'Open your ZainCash app'**
  String get paymentZainCashStep1;

  /// No description provided for @paymentZainCashStep2.
  ///
  /// In en, this message translates to:
  /// **'Transfer to: +964 770 000 0000'**
  String get paymentZainCashStep2;

  /// No description provided for @paymentZainCashStep3.
  ///
  /// In en, this message translates to:
  /// **'Include your name and car plate in the note'**
  String get paymentZainCashStep3;

  /// No description provided for @paymentZainCashStep4.
  ///
  /// In en, this message translates to:
  /// **'Upload a screenshot below, then tap \"I\'ve Paid\"'**
  String get paymentZainCashStep4;

  /// No description provided for @paymentSuperQiStep1.
  ///
  /// In en, this message translates to:
  /// **'Open your Super QI app or dial *3200#'**
  String get paymentSuperQiStep1;

  /// No description provided for @paymentSuperQiStep2.
  ///
  /// In en, this message translates to:
  /// **'Send to account: 07XX-XXX-XXXX'**
  String get paymentSuperQiStep2;

  /// No description provided for @paymentSuperQiStep3.
  ///
  /// In en, this message translates to:
  /// **'Include your name and car plate in the note'**
  String get paymentSuperQiStep3;

  /// No description provided for @paymentSuperQiStep4.
  ///
  /// In en, this message translates to:
  /// **'Upload a screenshot below, then tap \"I\'ve Paid\"'**
  String get paymentSuperQiStep4;

  /// No description provided for @paymentOtherStep1.
  ///
  /// In en, this message translates to:
  /// **'Transfer to the account number provided by our team'**
  String get paymentOtherStep1;

  /// No description provided for @paymentOtherStep2.
  ///
  /// In en, this message translates to:
  /// **'Include your full name and subscription details'**
  String get paymentOtherStep2;

  /// No description provided for @paymentOtherStep3.
  ///
  /// In en, this message translates to:
  /// **'Keep your receipt as proof'**
  String get paymentOtherStep3;

  /// No description provided for @paymentOtherStep4.
  ///
  /// In en, this message translates to:
  /// **'Upload a screenshot below, then tap \"I\'ve Paid\"'**
  String get paymentOtherStep4;

  /// No description provided for @notificationsTimeAgoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String notificationsTimeAgoMinutes(int count);

  /// No description provided for @notificationsTimeAgoHours.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String notificationsTimeAgoHours(int count);

  /// No description provided for @profileActivePlan.
  ///
  /// In en, this message translates to:
  /// **'Active {plan} plan'**
  String profileActivePlan(String plan);

  /// No description provided for @profileNoActiveSub.
  ///
  /// In en, this message translates to:
  /// **'No active subscription — tap to subscribe'**
  String get profileNoActiveSub;

  /// No description provided for @profileAddCarTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Your Car'**
  String get profileAddCarTitle;

  /// No description provided for @profileAddCarDesc.
  ///
  /// In en, this message translates to:
  /// **'Register your car to start using our services'**
  String get profileAddCarDesc;

  /// No description provided for @appointmentsRequestSentSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Change request sent to the maintenance team.'**
  String get appointmentsRequestSentSnackbar;

  /// No description provided for @oilChangeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed'**
  String get oilChangeConfirmTitle;

  /// No description provided for @oilChangeConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Oil change appointment booked for {make} {model}.'**
  String oilChangeConfirmContent(String make, String model);

  /// No description provided for @oilChangeDayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get oilChangeDayMon;

  /// No description provided for @oilChangeDayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get oilChangeDayTue;

  /// No description provided for @oilChangeDayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get oilChangeDayWed;

  /// No description provided for @oilChangeDayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get oilChangeDayThu;

  /// No description provided for @oilChangeDaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get oilChangeDaySat;

  /// No description provided for @oilChangeDaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get oilChangeDaySun;

  /// No description provided for @oilChangeMonthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get oilChangeMonthJan;

  /// No description provided for @oilChangeMonthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get oilChangeMonthFeb;

  /// No description provided for @oilChangeMonthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get oilChangeMonthMar;

  /// No description provided for @oilChangeMonthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get oilChangeMonthApr;

  /// No description provided for @oilChangeMonthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get oilChangeMonthMay;

  /// No description provided for @oilChangeMonthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get oilChangeMonthJun;

  /// No description provided for @oilChangeMonthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get oilChangeMonthJul;

  /// No description provided for @oilChangeMonthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get oilChangeMonthAug;

  /// No description provided for @oilChangeMonthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get oilChangeMonthSep;

  /// No description provided for @oilChangeMonthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get oilChangeMonthOct;

  /// No description provided for @oilChangeMonthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get oilChangeMonthNov;

  /// No description provided for @oilChangeMonthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get oilChangeMonthDec;

  /// No description provided for @oilChangeTimeSlot1.
  ///
  /// In en, this message translates to:
  /// **'8:00 AM – 9:00 AM'**
  String get oilChangeTimeSlot1;

  /// No description provided for @oilChangeTimeSlot2.
  ///
  /// In en, this message translates to:
  /// **'9:00 AM – 10:00 AM'**
  String get oilChangeTimeSlot2;

  /// No description provided for @oilChangeTimeSlot3.
  ///
  /// In en, this message translates to:
  /// **'10:00 AM – 11:00 AM'**
  String get oilChangeTimeSlot3;

  /// No description provided for @oilChangeTimeSlot4.
  ///
  /// In en, this message translates to:
  /// **'11:00 AM – 12:00 PM'**
  String get oilChangeTimeSlot4;

  /// No description provided for @oilChangeTimeSlot5.
  ///
  /// In en, this message translates to:
  /// **'1:00 PM – 2:00 PM'**
  String get oilChangeTimeSlot5;

  /// No description provided for @oilChangeTimeSlot6.
  ///
  /// In en, this message translates to:
  /// **'2:00 PM – 3:00 PM'**
  String get oilChangeTimeSlot6;

  /// No description provided for @oilChangeTimeSlot7.
  ///
  /// In en, this message translates to:
  /// **'3:00 PM – 4:00 PM'**
  String get oilChangeTimeSlot7;

  /// No description provided for @oilChangeTimeSlot8.
  ///
  /// In en, this message translates to:
  /// **'4:00 PM – 5:00 PM'**
  String get oilChangeTimeSlot8;

  /// No description provided for @subscriptionRepairsByPeriod.
  ///
  /// In en, this message translates to:
  /// **'Repairs by Payment Period'**
  String get subscriptionRepairsByPeriod;

  /// No description provided for @upgradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Subscription'**
  String get upgradeTitle;

  /// No description provided for @upgradeCurrentPlanSection.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get upgradeCurrentPlanSection;

  /// No description provided for @upgradeNewPlanSection.
  ///
  /// In en, this message translates to:
  /// **'New Plan'**
  String get upgradeNewPlanSection;

  /// No description provided for @upgradeRemainingMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month remaining} other{{count} months remaining}}'**
  String upgradeRemainingMonths(int count);

  /// No description provided for @upgradeCreditLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining Credit'**
  String get upgradeCreditLabel;

  /// No description provided for @upgradeNewCostLabel.
  ///
  /// In en, this message translates to:
  /// **'New Plan Cost'**
  String get upgradeNewCostLabel;

  /// No description provided for @upgradeAmountDueLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount Due'**
  String get upgradeAmountDueLabel;

  /// No description provided for @upgradeAmountFree.
  ///
  /// In en, this message translates to:
  /// **'Covered by credit'**
  String get upgradeAmountFree;

  /// No description provided for @upgradeNote.
  ///
  /// In en, this message translates to:
  /// **'Our team will contact you to process the payment difference and activate your new plan immediately.'**
  String get upgradeNote;

  /// No description provided for @upgradeSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Request Upgrade'**
  String get upgradeSubmitButton;

  /// No description provided for @upgradeSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Request Sent'**
  String get upgradeSentTitle;

  /// No description provided for @upgradeSentContent.
  ///
  /// In en, this message translates to:
  /// **'Your upgrade request from {currentPlan} to {newPlan} has been submitted. Our team will contact you shortly to finalize the payment.'**
  String upgradeSentContent(String currentPlan, String newPlan);

  /// No description provided for @upgradePendingBanner.
  ///
  /// In en, this message translates to:
  /// **'You have a pending upgrade request'**
  String get upgradePendingBanner;

  /// No description provided for @upgradeStatusCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Your subscription request'**
  String get upgradeStatusCardTitle;

  /// No description provided for @upgradeStatusStepSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get upgradeStatusStepSubmitted;

  /// No description provided for @upgradeStatusStepReview.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get upgradeStatusStepReview;

  /// No description provided for @upgradeStatusStepDecision.
  ///
  /// In en, this message translates to:
  /// **'Decision'**
  String get upgradeStatusStepDecision;

  /// No description provided for @upgradeStatusPendingDesc.
  ///
  /// In en, this message translates to:
  /// **'Your payment is being verified. We\'ll notify you once it\'s approved.'**
  String get upgradeStatusPendingDesc;

  /// No description provided for @upgradeStatusApprovedLabel.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get upgradeStatusApprovedLabel;

  /// No description provided for @upgradeStatusRejectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get upgradeStatusRejectedLabel;

  /// No description provided for @upgradeStatusRejectedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your previous request was not approved. You can submit a new one.'**
  String get upgradeStatusRejectedDesc;

  /// No description provided for @upgradeStatusAdminNote.
  ///
  /// In en, this message translates to:
  /// **'Note from admin'**
  String get upgradeStatusAdminNote;

  /// No description provided for @upgradeStatusSubmittedAt.
  ///
  /// In en, this message translates to:
  /// **'Submitted on {date}'**
  String upgradeStatusSubmittedAt(String date);

  /// No description provided for @upgradeStatusAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get upgradeStatusAmountLabel;

  /// No description provided for @upgradeStatusRequestedPlanLabel.
  ///
  /// In en, this message translates to:
  /// **'Requested plan'**
  String get upgradeStatusRequestedPlanLabel;

  /// No description provided for @subscriptionPendingShort.
  ///
  /// In en, this message translates to:
  /// **'Subscription request under review'**
  String get subscriptionPendingShort;

  /// No description provided for @subscriptionPendingDesc.
  ///
  /// In en, this message translates to:
  /// **'Your payment is being verified. We\'ll activate your plan after approval.'**
  String get subscriptionPendingDesc;

  /// No description provided for @subscriptionPendingViewStatus.
  ///
  /// In en, this message translates to:
  /// **'View status'**
  String get subscriptionPendingViewStatus;

  /// No description provided for @subscriptionPendingBadge.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get subscriptionPendingBadge;

  /// No description provided for @subscriptionUpgradePendingTo.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to {planName} is under review'**
  String subscriptionUpgradePendingTo(String planName);

  /// No description provided for @subscriptionCurrentPlanBanner.
  ///
  /// In en, this message translates to:
  /// **'Your current plan'**
  String get subscriptionCurrentPlanBanner;

  /// No description provided for @upgradeDowngradeNote.
  ///
  /// In en, this message translates to:
  /// **'Downgrades take effect after your current plan expires. Contact our team for assistance.'**
  String get upgradeDowngradeNote;

  /// No description provided for @upgradeRenewButton.
  ///
  /// In en, this message translates to:
  /// **'Renew Plan'**
  String get upgradeRenewButton;

  /// No description provided for @upgradeRenewNote.
  ///
  /// In en, this message translates to:
  /// **'Your current plan is still active. Renewing now will extend it from the current expiry date.'**
  String get upgradeRenewNote;

  /// No description provided for @upgradeSamePlanBanner.
  ///
  /// In en, this message translates to:
  /// **'You are already on this plan'**
  String get upgradeSamePlanBanner;

  /// No description provided for @navMyCars.
  ///
  /// In en, this message translates to:
  /// **'My Cars'**
  String get navMyCars;

  /// No description provided for @myCarsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Cars'**
  String get myCarsTitle;

  /// No description provided for @myCarsNoCars.
  ///
  /// In en, this message translates to:
  /// **'No cars registered'**
  String get myCarsNoCars;

  /// No description provided for @myCarsNoCarsDesc.
  ///
  /// In en, this message translates to:
  /// **'Add your car to start using our services'**
  String get myCarsNoCarsDesc;

  /// No description provided for @myCarsAddCar.
  ///
  /// In en, this message translates to:
  /// **'Add Car'**
  String get myCarsAddCar;

  /// No description provided for @myCarsSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get myCarsSubscription;

  /// No description provided for @myCarsNoSubscription.
  ///
  /// In en, this message translates to:
  /// **'No subscription'**
  String get myCarsNoSubscription;

  /// No description provided for @myCarsSubscribNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get myCarsSubscribNow;

  /// No description provided for @myCarsPayNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get myCarsPayNow;

  /// No description provided for @myCarsExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires: {date}'**
  String myCarsExpires(String date);

  /// No description provided for @myCarsRepairsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} repairs left this month'**
  String myCarsRepairsLeft(int count);

  /// No description provided for @myCarsPerMonth.
  ///
  /// In en, this message translates to:
  /// **'{price} / month'**
  String myCarsPerMonth(String price);

  /// No description provided for @myCarsPlanDetails.
  ///
  /// In en, this message translates to:
  /// **'Plan Details'**
  String get myCarsPlanDetails;

  /// No description provided for @myCarsManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get myCarsManage;

  /// No description provided for @carDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Car Details'**
  String get carDetailTitle;

  /// No description provided for @carDetailCarInfo.
  ///
  /// In en, this message translates to:
  /// **'Car Information'**
  String get carDetailCarInfo;

  /// No description provided for @carDetailMake.
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get carDetailMake;

  /// No description provided for @carDetailModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get carDetailModel;

  /// No description provided for @carDetailYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get carDetailYear;

  /// No description provided for @carDetailColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get carDetailColor;

  /// No description provided for @carDetailPlate.
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get carDetailPlate;

  /// No description provided for @carDetailSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get carDetailSubscription;

  /// No description provided for @profileEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit Information'**
  String get profileEditButton;

  /// No description provided for @profileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Information Change'**
  String get profileEditTitle;

  /// No description provided for @profileEditDesc.
  ///
  /// In en, this message translates to:
  /// **'Your request will be sent to administration for review and approval.'**
  String get profileEditDesc;

  /// No description provided for @profileEditName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get profileEditName;

  /// No description provided for @profileEditEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEditEmail;

  /// No description provided for @profileEditPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get profileEditPhone;

  /// No description provided for @profileEditSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Change Request'**
  String get profileEditSubmit;

  /// No description provided for @profileEditSuccess.
  ///
  /// In en, this message translates to:
  /// **'Change request submitted successfully. It will be reviewed by administration.'**
  String get profileEditSuccess;

  /// No description provided for @profileEditNoChanges.
  ///
  /// In en, this message translates to:
  /// **'No changes were made'**
  String get profileEditNoChanges;

  /// No description provided for @profileEditPending.
  ///
  /// In en, this message translates to:
  /// **'You have a pending edit request under review'**
  String get profileEditPending;

  /// No description provided for @oilChangeRequestSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get oilChangeRequestSubmit;

  /// No description provided for @oilChangeRequestDesc.
  ///
  /// In en, this message translates to:
  /// **'Our maintenance team will schedule the date, time, and branch for you.'**
  String get oilChangeRequestDesc;

  /// No description provided for @oilChangeValidationNoCar.
  ///
  /// In en, this message translates to:
  /// **'Please select a car'**
  String get oilChangeValidationNoCar;

  /// No description provided for @oilChangeConfirmContentSimple.
  ///
  /// In en, this message translates to:
  /// **'Your oil change request for {make} {model} has been submitted. We will contact you with the appointment details.'**
  String oilChangeConfirmContentSimple(String make, String model);

  /// No description provided for @appointmentsBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get appointmentsBranch;

  /// No description provided for @appointmentsNavigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get appointmentsNavigate;

  /// No description provided for @appointmentsChooseNav.
  ///
  /// In en, this message translates to:
  /// **'Open with'**
  String get appointmentsChooseNav;

  /// No description provided for @appointmentsGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Google Maps'**
  String get appointmentsGoogleMaps;

  /// No description provided for @appointmentsWaze.
  ///
  /// In en, this message translates to:
  /// **'Waze'**
  String get appointmentsWaze;

  /// No description provided for @appointmentsLocationNotSet.
  ///
  /// In en, this message translates to:
  /// **'Location will be set by the maintenance team'**
  String get appointmentsLocationNotSet;

  /// No description provided for @availableCitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Service center currently available in'**
  String get availableCitiesTitle;

  /// No description provided for @accidentDetailRepairEntry.
  ///
  /// In en, this message translates to:
  /// **'Repair Entry'**
  String get accidentDetailRepairEntry;

  /// No description provided for @accidentDetailFinalRepair.
  ///
  /// In en, this message translates to:
  /// **'Final'**
  String get accidentDetailFinalRepair;

  /// No description provided for @accidentDetailRepairDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get accidentDetailRepairDate;

  /// No description provided for @accidentDetailTechnician.
  ///
  /// In en, this message translates to:
  /// **'Technician'**
  String get accidentDetailTechnician;

  /// No description provided for @accidentDetailPartsReplaced.
  ///
  /// In en, this message translates to:
  /// **'Parts Replaced:'**
  String get accidentDetailPartsReplaced;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support & Help'**
  String get supportTitle;

  /// No description provided for @supportCallUs.
  ///
  /// In en, this message translates to:
  /// **'Call Us'**
  String get supportCallUs;

  /// No description provided for @supportEmailUs.
  ///
  /// In en, this message translates to:
  /// **'Email Us'**
  String get supportEmailUs;

  /// No description provided for @supportWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get supportWhatsApp;

  /// No description provided for @supportWorkingHours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get supportWorkingHours;

  /// No description provided for @supportWorkingHoursValue.
  ///
  /// In en, this message translates to:
  /// **'Sat - Thu, 9 AM - 5 PM'**
  String get supportWorkingHoursValue;

  /// No description provided for @supportAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get supportAddress;

  /// No description provided for @supportFollowUs.
  ///
  /// In en, this message translates to:
  /// **'Follow Us'**
  String get supportFollowUs;

  /// No description provided for @supportNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get supportNeedHelp;

  /// No description provided for @supportDesc.
  ///
  /// In en, this message translates to:
  /// **'Our team is ready to help you anytime. Contact us through any of the following methods.'**
  String get supportDesc;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String privacyPolicyLastUpdated(String date);

  /// No description provided for @privacyPolicyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyLink;

  /// No description provided for @privacyPolicyAgreePrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our '**
  String get privacyPolicyAgreePrefix;

  /// No description provided for @privacyPolicyView.
  ///
  /// In en, this message translates to:
  /// **'View Privacy Policy'**
  String get privacyPolicyView;

  /// No description provided for @accidentNoSubscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription Required'**
  String get accidentNoSubscriptionTitle;

  /// No description provided for @accidentNoSubscriptionContent.
  ///
  /// In en, this message translates to:
  /// **'You need an active subscription to report an accident. Subscribe to a plan first.'**
  String get accidentNoSubscriptionContent;

  /// No description provided for @accidentNoSubscriptionAction.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get accidentNoSubscriptionAction;

  /// No description provided for @subscriptionPayTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Payment'**
  String get subscriptionPayTitle;

  /// No description provided for @subscriptionPayDesc.
  ///
  /// In en, this message translates to:
  /// **'Transfer the amount below, then confirm to activate your subscription.'**
  String get subscriptionPayDesc;

  /// No description provided for @subscriptionPayAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Accounts'**
  String get subscriptionPayAccountsTitle;

  /// No description provided for @subscriptionPayNote.
  ///
  /// In en, this message translates to:
  /// **'After payment, our finance team will verify within 24 hours and activate your subscription.'**
  String get subscriptionPayNote;

  /// No description provided for @subscriptionPayConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'I\'ve Paid — Activate'**
  String get subscriptionPayConfirmButton;

  /// No description provided for @subscriptionPaySuccess.
  ///
  /// In en, this message translates to:
  /// **'Subscription request submitted. Our team will verify your payment shortly.'**
  String get subscriptionPaySuccess;
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
      <String>['ar', 'ckb', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'ckb':
      return AppLocalizationsCkb();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

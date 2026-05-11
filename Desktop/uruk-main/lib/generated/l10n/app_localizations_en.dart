// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Uruk Motors';

  @override
  String get appTagline => 'Body & Paint Maintenance Center';

  @override
  String get appVersion => 'v1.0.0 • Uruk Motors';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonClose => 'Close';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Next';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonSend => 'Send';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonOr => 'or';

  @override
  String get commonRequired => 'Required';

  @override
  String get commonOptional => 'Optional';

  @override
  String get commonUpgrade => 'Upgrade';

  @override
  String get commonViewAll => 'View All';

  @override
  String get commonUpload => 'Upload';

  @override
  String get commonRetake => 'Retake';

  @override
  String get commonPrint => 'Print';

  @override
  String get commonMarkAllRead => 'Mark all read';

  @override
  String get commonSendRequest => 'Send Request';

  @override
  String get commonAddPhoto => 'Add Photo';

  @override
  String get commonErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get authSuspendedTitle => 'Your account is suspended';

  @override
  String get authSuspendedMessage =>
      'Your account has been suspended. Please contact support for more information.';

  @override
  String get authRejectedTitle => 'Your account was rejected';

  @override
  String get authRejectedMessage =>
      'Your account application was rejected. Please contact support for more details.';

  @override
  String get navHome => 'Home';

  @override
  String get navAccidents => 'Accidents';

  @override
  String get navAppointments => 'Appts';

  @override
  String get navPayment => 'Payment';

  @override
  String get navProfile => 'Profile';

  @override
  String get loginWelcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to your account';

  @override
  String get loginPhone => 'Phone Number';

  @override
  String get loginPhoneHint => '+964 7xx xxx xxxx';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginSignInButton => 'Sign In';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginRegister => 'Register';

  @override
  String get loginContinueAsGuest => 'Browse as Guest';

  @override
  String get guestBannerMessage => 'Browsing as guest';

  @override
  String get guestBannerAction => 'Login';

  @override
  String get guestLoginRequired => 'Login Required';

  @override
  String get guestLoginRequiredMessage =>
      'You need to log in to access this feature.';

  @override
  String get guestLoginButton => 'Login';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle => 'Fill in your details to get started.';

  @override
  String get registerFullName => 'Full Name';

  @override
  String get registerFullNameHint => 'e.g. Ahmed Al-Rashidi';

  @override
  String get registerPhone => 'Mobile Number';

  @override
  String get registerPhoneHint => '+964 7xx xxx xxxx';

  @override
  String get registerEmailOptional => 'Email (Optional)';

  @override
  String get registerEmailHint => 'you@email.com';

  @override
  String get registerPassword => 'Password';

  @override
  String get registerConfirmPassword => 'Confirm Password';

  @override
  String get registerNextVerify => 'Next — Verify Mobile';

  @override
  String get registerAlreadyHaveAccount => 'Already have an account?';

  @override
  String get registerSignIn => 'Sign In';

  @override
  String get otpTitle => 'Verify Your Number';

  @override
  String otpSubtitle(String phone) {
    return 'Enter the 6-digit code sent to $phone';
  }

  @override
  String get otpEnterCode => 'Please enter the 6-digit code';

  @override
  String get otpInvalidCode => 'Invalid OTP. Please try again.';

  @override
  String get otpDidntReceive => 'Didn\'t receive code? ';

  @override
  String otpResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get otpResend => 'Resend';

  @override
  String get idUploadTitle => 'Upload Your ID';

  @override
  String get idUploadBothSidesRequired => 'Please upload both sides of your ID';

  @override
  String get idUploadInstructions =>
      'Please upload clear photos of your Iraqi National ID card. Both sides are required.';

  @override
  String get idUploadFrontSubtitle => 'Take a photo of the front side';

  @override
  String get idUploadBackSubtitle => 'Take a photo of the back side';

  @override
  String get idUploadSubmit => 'Submit Application';

  @override
  String get idUploadDisclaimer =>
      'Your ID is securely stored and only visible to our admin team.';

  @override
  String get idUploadSuccess => 'Photo uploaded successfully';

  @override
  String get idUploadRetake => 'Retake';

  @override
  String get pendingTitle => 'Application Under Review';

  @override
  String get pendingSubtitle =>
      'Your application is being reviewed by our team.';

  @override
  String get pendingStep1 => 'Account created';

  @override
  String get pendingStep2 => 'ID verification submitted';

  @override
  String get pendingStep3 => 'Admin review (1–2 business days)';

  @override
  String get pendingStep4 => 'Account activated';

  @override
  String get pendingSmsNotification =>
      'We\'ll send you an SMS notification when your account is approved.';

  @override
  String get pendingBackToLogin => 'Back to Login';

  @override
  String get splashTagline => 'Body & Paint Maintenance Center';

  @override
  String get onboard1Title => 'Report Accidents Easily';

  @override
  String get onboard1Desc =>
      'Submit accident reports with photos directly from your phone.';

  @override
  String get onboard2Title => 'Track Your Repairs';

  @override
  String get onboard2Desc =>
      'Follow every repair step in real time and view the full maintenance history.';

  @override
  String get onboard3Title => 'Manage Payments';

  @override
  String get onboard3Desc =>
      'Pay your monthly subscription and view complete payment history.';

  @override
  String get onboardSkip => 'Skip';

  @override
  String get onboardGetStarted => 'Get Started';

  @override
  String get onboardAlreadyHaveAccount => 'Already have an account?';

  @override
  String get onboardSignIn => 'Sign In';

  @override
  String get garageTitle => 'Garage';

  @override
  String get garageMyCarsSectionTitle => 'My Cars';

  @override
  String garageCarsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cars',
      one: '1 car',
      zero: 'No cars',
    );
    return '$_temp0';
  }

  @override
  String get garageNoCarYet => 'No cars added yet';

  @override
  String get garageAddCarButton => 'Add New Car';

  @override
  String garageSubActive(String planName) {
    return '$planName Active';
  }

  @override
  String get garageNoSubscription => 'No Subscription';

  @override
  String get garageSelectCar => 'Select a car to view details';

  @override
  String get carAddTitle => 'Add Your Car';

  @override
  String get carEditTitle => 'Request Car Data Change';

  @override
  String get carMakeLabel => 'Make *';

  @override
  String get carMakeHint => 'e.g. Toyota';

  @override
  String get carModelLabel => 'Model *';

  @override
  String get carModelHint => 'e.g. Camry';

  @override
  String get carYearLabel => 'Year *';

  @override
  String get carYearHint => 'e.g. 2020';

  @override
  String get carColorLabel => 'Color *';

  @override
  String get carColorHint => 'e.g. White';

  @override
  String get carPlateLabel => 'Plate Number *';

  @override
  String get carPlateHint => 'e.g. 12345 - Baghdad';

  @override
  String get carSaveSuccess => 'Car data saved successfully';

  @override
  String get carNoChanges => 'No changes were made';

  @override
  String get carChangeRequestSentTitle => 'Request Sent';

  @override
  String get carChangeRequestSentContent =>
      'Your car data change request has been sent to admin for review. Data will be updated after admin approval.';

  @override
  String get carChangesLabel => 'Requested changes:';

  @override
  String get carPendingRequestWarning => 'A change request is under review';

  @override
  String get carSubscriptionActivatedBanner =>
      'Your subscription is activated! Add your car details now to complete your profile.';

  @override
  String get carEditModeNote =>
      'Changes are not applied immediately — they will be sent to admin for review.';

  @override
  String get carAddButton => 'Add Car';

  @override
  String get carSendChangeButton => 'Send Change Request';

  @override
  String get carSkipButton => 'Skip for Now';

  @override
  String get carPhotoAddLabel => 'Add Car Photo';

  @override
  String get carPhotoHint => 'Helps you tell your cars apart';

  @override
  String get carPhotoChangeLabel => 'Change Photo';

  @override
  String get subscriptionTitle => 'Subscription Plans';

  @override
  String get subscriptionSubtitle =>
      'Choose the plan that fits you. You can upgrade anytime.';

  @override
  String get subscriptionPerMonth => '/ month';

  @override
  String get subscriptionCurrentPlan => 'Your Current Plan';

  @override
  String get subscriptionMostPopular => 'Most Popular';

  @override
  String get subscriptionCoveredPartsTitle => 'What\'s covered';

  @override
  String get subscriptionPaymentPeriodTitle => 'Payment Method';

  @override
  String get subscriptionPaymentPeriodHint =>
      'Prepayment gives you more monthly repairs.';

  @override
  String subscriptionRepairsPerMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'repairs',
      one: 'repair',
    );
    return '$count $_temp0/month';
  }

  @override
  String get subscriptionDisclaimer =>
      'All plans cover exterior damage only (doors, bumpers, body). Does not include engine, mechanical parts, glass, or lights.';

  @override
  String get subscriptionConfirmTitle => 'Confirm Subscription';

  @override
  String get subscriptionPlanLabel => 'Plan';

  @override
  String get subscriptionPaymentMethodLabel => 'Payment Method';

  @override
  String get subscriptionRepairsLabel => 'Repairs / month';

  @override
  String get subscriptionTotalLabel => 'Total Amount';

  @override
  String get subscriptionConfirmNote =>
      'Our team will contact you to process the first payment and activate your subscription.';

  @override
  String get subscriptionSubscribeButton => 'Subscribe Now';

  @override
  String get subscriptionSelectPlan => 'Select a Plan';

  @override
  String get subscriptionPeriodMonthly => 'Monthly';

  @override
  String get subscriptionPeriod3Months => '3 Months Prepaid';

  @override
  String get subscriptionPeriod6Months => '6 Months Prepaid';

  @override
  String get subscriptionPeriod12Months => '1 Year Prepaid';

  @override
  String get accidentHistoryTitle => 'Accident Reports';

  @override
  String get accidentHistoryNewReportTooltip => 'New Report';

  @override
  String get accidentHistoryDraftsSectionTitle => 'Drafts';

  @override
  String get accidentHistoryTotal => 'Total';

  @override
  String get accidentHistoryCompleted => 'Completed';

  @override
  String get accidentHistoryUnderReview => 'Under Review';

  @override
  String get accidentHistoryNewReportFab => 'New Report';

  @override
  String get accidentHistoryEmpty => 'No Reports';

  @override
  String get accidentHistoryEmptyDesc =>
      'If your car is involved in an accident, report it here and our team will handle the repairs.';

  @override
  String get accidentHistorySubmitButton => 'Report an Accident';

  @override
  String get accidentHistoryDeleteDraftTitle => 'Delete Draft';

  @override
  String get accidentHistoryDeleteDraftContent =>
      'Are you sure you want to delete this draft?';

  @override
  String get accidentHistoryOtherPartyInvolved => 'Other party involved';

  @override
  String accidentHistoryPhotosCount(int count) {
    return '$count photos';
  }

  @override
  String accidentHistoryLastModified(String dateTime) {
    return 'Last modified: $dateTime';
  }

  @override
  String get accidentHistoryCoordinatesSet => 'Coordinates set';

  @override
  String get accidentHistorySwipeToDelete => 'Swipe left to delete';

  @override
  String get accidentReportTitle => 'Report Accident';

  @override
  String get accidentEditDraftTitle => 'Edit Draft';

  @override
  String get accidentDraftButton => 'Draft';

  @override
  String get accidentDraftEditingNote =>
      'You are editing a saved draft. You can submit or save again.';

  @override
  String get accidentInfoBanner =>
      'Fill in the accident details accurately. Our team will review and schedule a repair appointment.';

  @override
  String get accidentPhotosTitle => 'Accident Photos *';

  @override
  String get accidentPhotosSubtitle =>
      'Add clear photos of the damage and accident scene';

  @override
  String accidentPhotosMaxReached(int max) {
    return 'Maximum $max photos';
  }

  @override
  String get accidentPhotosTakePhoto => 'Take Photo';

  @override
  String get accidentPhotosFromGallery => 'Choose from Gallery';

  @override
  String accidentPhotosCountLabel(int used, int allowed) {
    return '$used/$allowed';
  }

  @override
  String get accidentDateTitle => 'Accident Date *';

  @override
  String get accidentLocationTitle => 'Accident Location *';

  @override
  String get accidentLocationHint => 'e.g. Al-Karada, Baghdad';

  @override
  String get accidentLocationGpsTooltip => 'My Current Location';

  @override
  String get accidentLocationMapTooltip => 'Choose on Map';

  @override
  String get accidentLocationPermissionDenied =>
      'Location permission denied. Please enable it from device settings.';

  @override
  String get accidentLocationGpsError =>
      'Could not get location. Make sure GPS is enabled.';

  @override
  String get accidentDescriptionLabel => 'Describe the Damage *';

  @override
  String get accidentDescriptionHint =>
      'Describe what happened and what was damaged...';

  @override
  String get accidentOtherPartyTitle => 'Was there another party?';

  @override
  String get accidentOtherPartySubtitle =>
      'Was another vehicle involved in this accident?';

  @override
  String get accidentSaveDraftButton => 'Save Draft';

  @override
  String get accidentSubmitButton => 'Submit Report';

  @override
  String get accidentDraftSavedSuccess => 'Draft saved successfully';

  @override
  String get accidentSubmittedSuccess =>
      'Report submitted successfully! Our team will review it shortly.';

  @override
  String get accidentPhotosRequiredError =>
      'Please add at least one photo of the accident';

  @override
  String get accidentRepairLimitTitle => 'Monthly Limit Reached';

  @override
  String accidentRepairLimitContent(int used, int allowed) {
    return 'You have used all your monthly repairs ($used/$allowed). Upgrade your plan or wait for the next month.';
  }

  @override
  String get accidentRepairLimitUpgrade => 'Upgrade Plan';

  @override
  String get accidentDetailTitle => 'Report Details';

  @override
  String get accidentDetailNotFound => 'Report not found';

  @override
  String get accidentDetailPrintTooltip => 'Print Report';

  @override
  String get accidentDetailInfoSection => 'Accident Information';

  @override
  String get accidentDetailDescSection => 'Description';

  @override
  String accidentDetailPhotosSection(int count) {
    return 'Accident Photos ($count)';
  }

  @override
  String get accidentDetailMaintenanceSection => 'Maintenance Notes';

  @override
  String accidentDetailRepairPhotosSection(int count) {
    return 'Repair Photos ($count)';
  }

  @override
  String get accidentDetailDateLabel => 'Date';

  @override
  String get accidentDetailLocationLabel => 'Location';

  @override
  String get accidentDetailSubmittedLabel => 'Submitted';

  @override
  String get accidentDetailOtherPartyLabel => 'Other Party';

  @override
  String get accidentDetailYes => 'Yes';

  @override
  String get accidentDetailNo => 'No';

  @override
  String accidentDetailCompletedAt(String date) {
    return 'Completed on $date';
  }

  @override
  String get accidentDetailUploadSection => 'Add Repair Photos';

  @override
  String get accidentDetailUploadHint =>
      'Attach clear photos showing the car\'s condition after repair.';

  @override
  String accidentDetailUploadPendingCount(int count) {
    return '$count photo(s)';
  }

  @override
  String get accidentDetailUploadAddButton => 'Add Photo';

  @override
  String accidentDetailUploadSubmitButton(int count) {
    return 'Send Repair Photos ($count)';
  }

  @override
  String get accidentDetailUploadSubmitting => 'Sending...';

  @override
  String get accidentDetailUploadSuccess => 'Repair photos sent successfully';

  @override
  String get accidentDetailUploadError =>
      'An error occurred. Please try again.';

  @override
  String get accidentDetailPrintTitle => 'Print Report';

  @override
  String get accidentDetailPrintContent =>
      'A PDF file will be generated with the accident report details.';

  @override
  String get accidentDetailPrintButton => 'Print';

  @override
  String get accidentDetailPrintPlaceholder =>
      'PDF generated (requires backend integration)';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusUnderReview => 'Under Review';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusInRepair => 'In Repair';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusScheduled => 'Scheduled';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusChangeRequested => 'Change Requested';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusUnpaid => 'Unpaid';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get statusNoPlan => 'No Plan';

  @override
  String get statusStandard => 'Standard';

  @override
  String get statusShared => 'Shared';

  @override
  String get statusVip => 'VIP';

  @override
  String get homeRecentReports => 'Recent Reports';

  @override
  String get homeViewAll => 'View All';

  @override
  String get homeNoReports => 'No reports yet';

  @override
  String get homeGarageBack => 'Garage';

  @override
  String get greetingMorning => 'Good Morning';

  @override
  String get greetingAfternoon => 'Good Afternoon';

  @override
  String get greetingEvening => 'Good Evening';

  @override
  String get homeMemberFallback => 'Member';

  @override
  String get homeMySubscription => 'My Subscription';

  @override
  String get homeRepairsThisMonth => 'Repairs this month';

  @override
  String get homeRepairsExhausted =>
      'Monthly repair limit reached. Renews next month.';

  @override
  String homeRepairsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count repairs remaining',
      one: '1 repair remaining',
    );
    return '$_temp0 this month';
  }

  @override
  String homeSubscriptionStart(String date) {
    return 'Started on $date';
  }

  @override
  String homeSubscriptionExpiry(String date) {
    return 'Expires on $date';
  }

  @override
  String get homeUpgradeLink => 'Upgrade';

  @override
  String get homeNoSubscription =>
      'No active subscription.\nSubscribe to get exterior damage coverage.';

  @override
  String get homeSubscribeButton => 'Subscribe';

  @override
  String get homePaymentDue =>
      'Payment due! Tap here to pay your subscription.';

  @override
  String get homeQuickActionsTitle => 'Quick Actions';

  @override
  String get homeReportAccident => 'Report\nAccident';

  @override
  String get homeOilChange => 'Oil\nChange';

  @override
  String get homeMyAppointments => 'My\nAppts';

  @override
  String get homeMyPlan => 'My\nPlan';

  @override
  String get homeUpcomingAppointmentTitle => 'Upcoming Appointment';

  @override
  String get homeViewButton => 'View';

  @override
  String get appointmentsTitle => 'My Appointments';

  @override
  String get appointmentsUpcoming => 'Upcoming Appointment';

  @override
  String get appointmentsPast => 'Past Appointment';

  @override
  String get appointmentsEmpty => 'No Appointments';

  @override
  String get appointmentsEmptyDesc =>
      'Once you submit an accident report, our maintenance team will schedule an appointment for you.';

  @override
  String get appointmentsChangeTime => 'Request Time Change';

  @override
  String get appointmentsChangeRequestSent =>
      'Change request sent — waiting for confirmation';

  @override
  String appointmentsYourNote(String note) {
    return 'Your note: $note';
  }

  @override
  String get appointmentsDialogTitle => 'Request Appointment Change';

  @override
  String get appointmentsDialogContent =>
      'Please provide a reason or preferred alternative time:';

  @override
  String get appointmentsDialogHint =>
      'e.g. I have work on this day, please reschedule to the afternoon...';

  @override
  String get paymentTitle => 'Payment';

  @override
  String get paymentHistoryTitle => 'Payment History';

  @override
  String get paymentConfirmTitle => 'Confirm Payment';

  @override
  String get paymentMethodTitle => 'Select Payment Method';

  @override
  String get paymentZainCash => 'ZainCash';

  @override
  String get paymentZainCashDesc => 'Transfer via ZainCash wallet';

  @override
  String get paymentZainCashAccount => '+964 770 000 0000';

  @override
  String get paymentSuperQi => 'Super QI';

  @override
  String get paymentSuperQiDesc => 'Send directly — no bank needed';

  @override
  String get paymentSuperQiAccount => '07XX-XXX-XXXX';

  @override
  String get paymentOther => 'Other Method';

  @override
  String get paymentOtherDesc => 'Another payment method';

  @override
  String get paymentAccountNumberLabel => 'Account Number';

  @override
  String get paymentProofUploadLabel => 'Upload Payment Proof';

  @override
  String get paymentProofUploadHint =>
      'Photo or screenshot of your transfer receipt';

  @override
  String get paymentProofChangeLabel => 'Change photo';

  @override
  String paymentIvePaid(String amount) {
    return 'I\'ve Paid $amount';
  }

  @override
  String get paymentZainCashInstructionsTitle =>
      'ZainCash Transfer Instructions';

  @override
  String get paymentSuperQiInstructionsTitle =>
      'Super QI Transfer Instructions';

  @override
  String get paymentOtherInstructionsTitle => 'Other Payment Instructions';

  @override
  String get paymentVerificationNote =>
      'Our accounts team will verify your payment within 24 hours.';

  @override
  String get paymentAllPaid => 'All Paid!';

  @override
  String get paymentNoPending => 'No pending payments. Thank you!';

  @override
  String paymentPaidOn(String date) {
    return 'Paid on $date';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsEmpty => 'No notifications yet';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileEditCarTooltip => 'Edit Car';

  @override
  String get profilePersonalInfo => 'Personal Information';

  @override
  String get profileFullName => 'Full Name';

  @override
  String get profileMobile => 'Mobile';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileMemberSince => 'Member Since';

  @override
  String get profileNotProvided => 'Not provided';

  @override
  String profileCarSection(int number, String make, String model) {
    return 'Car $number: $make $model';
  }

  @override
  String get profileCarMake => 'Make';

  @override
  String get profileCarModel => 'Model';

  @override
  String get profileCarYear => 'Year';

  @override
  String get profileCarColor => 'Color';

  @override
  String get profileCarPlate => 'Plate';

  @override
  String get profileNationalId => 'National ID';

  @override
  String get profileIdUploaded => 'Uploaded';

  @override
  String get profileIdNotUploaded => 'Not uploaded';

  @override
  String get profileLogout => 'Logout';

  @override
  String get profileLogoutConfirmTitle => 'Logout';

  @override
  String get profileLogoutConfirmContent => 'Are you sure you want to log out?';

  @override
  String get profileMemberFallback => 'Member';

  @override
  String get oilChangeTitle => 'Oil Change Booking';

  @override
  String get oilChangeServiceName => 'Car Oil Change';

  @override
  String get oilChangeServiceNote =>
      'Additional service — not included in subscription';

  @override
  String get oilChangePriceLabel => 'IQD';

  @override
  String get oilChangeSelectCarTitle => 'Select Car';

  @override
  String get oilChangeDateTitle => 'Select Date';

  @override
  String get oilChangeTimeTitle => 'Select Time';

  @override
  String get oilChangeNotesTitle => 'Notes (Optional)';

  @override
  String get oilChangeNotesHint => 'e.g. I prefer 5W-30 oil...';

  @override
  String get oilChangeBookButton => 'Confirm Booking';

  @override
  String get oilChangeValidationError =>
      'Please select car, date, and time slot';

  @override
  String get oilChangeTakePhoto => 'Take Photo';

  @override
  String get oilChangeFromGallery => 'Choose from Gallery';

  @override
  String get mapPickerTitle => 'Choose Location on Map';

  @override
  String get mapPickerConfirmButton => 'Confirm Location';

  @override
  String get mapPickerAppBarConfirm => 'Confirm';

  @override
  String get mapPickerHint => 'Tap on the map to set the accident location';

  @override
  String get mapPickerGpsTooltip => 'My Current Location';

  @override
  String get mapPickerGpsError =>
      'Could not get location. Make sure GPS is enabled.';

  @override
  String get mapPickerPermissionDenied =>
      'Location permission denied. Please enable it from device settings.';

  @override
  String get mapPickerSelectFirst => 'Tap on the map to set a location first';

  @override
  String get draftLocationUnknown => 'Location not specified';

  @override
  String draftLastModified(String dateTime) {
    return 'Last modified: $dateTime';
  }

  @override
  String get draftBadge => 'Draft';

  @override
  String get draftSwipeToDelete => 'Swipe left to delete';

  @override
  String get draftCoordinatesSet => 'Coordinates set';

  @override
  String get draftEditingNote =>
      'You are editing a saved draft. You can submit or save again.';

  @override
  String get draftSavedSuccess => 'Draft saved successfully';

  @override
  String get validatorPhoneRequired => 'Phone number is required';

  @override
  String get validatorPhoneInvalid => 'Enter a valid phone number';

  @override
  String get validatorPasswordRequired => 'Password is required';

  @override
  String get validatorPasswordTooShort =>
      'Password must be at least 6 characters';

  @override
  String get validatorConfirmPasswordRequired => 'Please confirm your password';

  @override
  String get validatorPasswordsMismatch => 'Passwords do not match';

  @override
  String validatorRequired(String fieldName) {
    return '$fieldName is required';
  }

  @override
  String get validatorNameRequired => 'Full name is required';

  @override
  String get validatorNameTooShort => 'Name must be at least 3 characters';

  @override
  String get validatorEmailInvalid => 'Enter a valid email address';

  @override
  String get validatorYearRequired => 'Year is required';

  @override
  String get validatorYearInvalid => 'Enter a valid year (1990–2030)';

  @override
  String get idFrontLabel => 'Front Side';

  @override
  String get idBackLabel => 'Back Side';

  @override
  String get idUploadTapHint => 'Tap to upload';

  @override
  String get paymentDueLabel => 'Payment Due';

  @override
  String paymentDueDateLabel(String date) {
    return 'Due: $date';
  }

  @override
  String paymentConfirmContent(String amount, String method, String month) {
    return 'Confirm that you have transferred $amount via $method for $month?';
  }

  @override
  String get paymentMethodZainCash => 'ZainCash';

  @override
  String get paymentMethodSuperQi => 'Super QI';

  @override
  String get paymentMethodOther => 'Other';

  @override
  String get paymentSnackbarSuccess =>
      'Payment marked. Our accounts team will verify within 24 hours.';

  @override
  String get paymentZainCashStep1 => 'Open your ZainCash app';

  @override
  String get paymentZainCashStep2 => 'Transfer to: +964 770 000 0000';

  @override
  String get paymentZainCashStep3 =>
      'Include your name and car plate in the note';

  @override
  String get paymentZainCashStep4 =>
      'Upload a screenshot below, then tap \"I\'ve Paid\"';

  @override
  String get paymentSuperQiStep1 => 'Open your Super QI app or dial *3200#';

  @override
  String get paymentSuperQiStep2 => 'Send to account: 07XX-XXX-XXXX';

  @override
  String get paymentSuperQiStep3 =>
      'Include your name and car plate in the note';

  @override
  String get paymentSuperQiStep4 =>
      'Upload a screenshot below, then tap \"I\'ve Paid\"';

  @override
  String get paymentOtherStep1 =>
      'Transfer to the account number provided by our team';

  @override
  String get paymentOtherStep2 =>
      'Include your full name and subscription details';

  @override
  String get paymentOtherStep3 => 'Keep your receipt as proof';

  @override
  String get paymentOtherStep4 =>
      'Upload a screenshot below, then tap \"I\'ve Paid\"';

  @override
  String notificationsTimeAgoMinutes(int count) {
    return '${count}m ago';
  }

  @override
  String notificationsTimeAgoHours(int count) {
    return '${count}h ago';
  }

  @override
  String profileActivePlan(String plan) {
    return 'Active $plan plan';
  }

  @override
  String get profileNoActiveSub => 'No active subscription — tap to subscribe';

  @override
  String get profileAddCarTitle => 'Add Your Car';

  @override
  String get profileAddCarDesc =>
      'Register your car to start using our services';

  @override
  String get appointmentsRequestSentSnackbar =>
      'Change request sent to the maintenance team.';

  @override
  String get oilChangeConfirmTitle => 'Booking Confirmed';

  @override
  String oilChangeConfirmContent(String make, String model) {
    return 'Oil change appointment booked for $make $model.';
  }

  @override
  String get oilChangeDayMon => 'Mon';

  @override
  String get oilChangeDayTue => 'Tue';

  @override
  String get oilChangeDayWed => 'Wed';

  @override
  String get oilChangeDayThu => 'Thu';

  @override
  String get oilChangeDaySat => 'Sat';

  @override
  String get oilChangeDaySun => 'Sun';

  @override
  String get oilChangeMonthJan => 'Jan';

  @override
  String get oilChangeMonthFeb => 'Feb';

  @override
  String get oilChangeMonthMar => 'Mar';

  @override
  String get oilChangeMonthApr => 'Apr';

  @override
  String get oilChangeMonthMay => 'May';

  @override
  String get oilChangeMonthJun => 'Jun';

  @override
  String get oilChangeMonthJul => 'Jul';

  @override
  String get oilChangeMonthAug => 'Aug';

  @override
  String get oilChangeMonthSep => 'Sep';

  @override
  String get oilChangeMonthOct => 'Oct';

  @override
  String get oilChangeMonthNov => 'Nov';

  @override
  String get oilChangeMonthDec => 'Dec';

  @override
  String get oilChangeTimeSlot1 => '8:00 AM – 9:00 AM';

  @override
  String get oilChangeTimeSlot2 => '9:00 AM – 10:00 AM';

  @override
  String get oilChangeTimeSlot3 => '10:00 AM – 11:00 AM';

  @override
  String get oilChangeTimeSlot4 => '11:00 AM – 12:00 PM';

  @override
  String get oilChangeTimeSlot5 => '1:00 PM – 2:00 PM';

  @override
  String get oilChangeTimeSlot6 => '2:00 PM – 3:00 PM';

  @override
  String get oilChangeTimeSlot7 => '3:00 PM – 4:00 PM';

  @override
  String get oilChangeTimeSlot8 => '4:00 PM – 5:00 PM';

  @override
  String get subscriptionRepairsByPeriod => 'Repairs by Payment Period';

  @override
  String get upgradeTitle => 'Upgrade Subscription';

  @override
  String get upgradeCurrentPlanSection => 'Current Plan';

  @override
  String get upgradeNewPlanSection => 'New Plan';

  @override
  String upgradeRemainingMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months remaining',
      one: '1 month remaining',
    );
    return '$_temp0';
  }

  @override
  String get upgradeCreditLabel => 'Remaining Credit';

  @override
  String get upgradeNewCostLabel => 'New Plan Cost';

  @override
  String get upgradeAmountDueLabel => 'Amount Due';

  @override
  String get upgradeAmountFree => 'Covered by credit';

  @override
  String get upgradeNote =>
      'Our team will contact you to process the payment difference and activate your new plan immediately.';

  @override
  String get upgradeSubmitButton => 'Request Upgrade';

  @override
  String get upgradeSentTitle => 'Upgrade Request Sent';

  @override
  String upgradeSentContent(String currentPlan, String newPlan) {
    return 'Your upgrade request from $currentPlan to $newPlan has been submitted. Our team will contact you shortly to finalize the payment.';
  }

  @override
  String get upgradePendingBanner => 'You have a pending upgrade request';

  @override
  String get upgradeStatusCardTitle => 'Your subscription request';

  @override
  String get upgradeStatusStepSubmitted => 'Submitted';

  @override
  String get upgradeStatusStepReview => 'Under review';

  @override
  String get upgradeStatusStepDecision => 'Decision';

  @override
  String get upgradeStatusPendingDesc =>
      'Your payment is being verified. We\'ll notify you once it\'s approved.';

  @override
  String get upgradeStatusApprovedLabel => 'Approved';

  @override
  String get upgradeStatusRejectedLabel => 'Rejected';

  @override
  String get upgradeStatusRejectedDesc =>
      'Your previous request was not approved. You can submit a new one.';

  @override
  String get upgradeStatusAdminNote => 'Note from admin';

  @override
  String upgradeStatusSubmittedAt(String date) {
    return 'Submitted on $date';
  }

  @override
  String get upgradeStatusAmountLabel => 'Amount';

  @override
  String get upgradeStatusRequestedPlanLabel => 'Requested plan';

  @override
  String get subscriptionPendingShort => 'Subscription request under review';

  @override
  String get subscriptionPendingDesc =>
      'Your payment is being verified. We\'ll activate your plan after approval.';

  @override
  String get subscriptionPendingViewStatus => 'View status';

  @override
  String get subscriptionPendingBadge => 'Pending';

  @override
  String subscriptionUpgradePendingTo(String planName) {
    return 'Upgrade to $planName is under review';
  }

  @override
  String get subscriptionCurrentPlanBanner => 'Your current plan';

  @override
  String get upgradeDowngradeNote =>
      'Downgrades take effect after your current plan expires. Contact our team for assistance.';

  @override
  String get upgradeRenewButton => 'Renew Plan';

  @override
  String get upgradeRenewNote =>
      'Your current plan is still active. Renewing now will extend it from the current expiry date.';

  @override
  String get upgradeSamePlanBanner => 'You are already on this plan';

  @override
  String get navMyCars => 'My Cars';

  @override
  String get myCarsTitle => 'My Cars';

  @override
  String get myCarsNoCars => 'No cars registered';

  @override
  String get myCarsNoCarsDesc => 'Add your car to start using our services';

  @override
  String get myCarsAddCar => 'Add Car';

  @override
  String get myCarsSubscription => 'Subscription';

  @override
  String get myCarsNoSubscription => 'No subscription';

  @override
  String get myCarsSubscribNow => 'Subscribe Now';

  @override
  String get myCarsPayNow => 'Pay Now';

  @override
  String myCarsExpires(String date) {
    return 'Expires: $date';
  }

  @override
  String myCarsRepairsLeft(int count) {
    return '$count repairs left this month';
  }

  @override
  String myCarsPerMonth(String price) {
    return '$price / month';
  }

  @override
  String get myCarsPlanDetails => 'Plan Details';

  @override
  String get myCarsManage => 'Manage';

  @override
  String get carDetailTitle => 'Car Details';

  @override
  String get carDetailCarInfo => 'Car Information';

  @override
  String get carDetailMake => 'Make';

  @override
  String get carDetailModel => 'Model';

  @override
  String get carDetailYear => 'Year';

  @override
  String get carDetailColor => 'Color';

  @override
  String get carDetailPlate => 'Plate';

  @override
  String get carDetailSubscription => 'Subscription';

  @override
  String get profileEditButton => 'Edit Information';

  @override
  String get profileEditTitle => 'Request Information Change';

  @override
  String get profileEditDesc =>
      'Your request will be sent to administration for review and approval.';

  @override
  String get profileEditName => 'Full Name';

  @override
  String get profileEditEmail => 'Email';

  @override
  String get profileEditPhone => 'Phone Number';

  @override
  String get profileEditSubmit => 'Submit Change Request';

  @override
  String get profileEditSuccess =>
      'Change request submitted successfully. It will be reviewed by administration.';

  @override
  String get profileEditNoChanges => 'No changes were made';

  @override
  String get profileEditPending =>
      'You have a pending edit request under review';

  @override
  String get oilChangeRequestSubmit => 'Submit Request';

  @override
  String get oilChangeRequestDesc =>
      'Our maintenance team will schedule the date, time, and branch for you.';

  @override
  String get oilChangeValidationNoCar => 'Please select a car';

  @override
  String oilChangeConfirmContentSimple(String make, String model) {
    return 'Your oil change request for $make $model has been submitted. We will contact you with the appointment details.';
  }

  @override
  String get appointmentsBranch => 'Branch';

  @override
  String get appointmentsNavigate => 'Navigate';

  @override
  String get appointmentsChooseNav => 'Open with';

  @override
  String get appointmentsGoogleMaps => 'Google Maps';

  @override
  String get appointmentsWaze => 'Waze';

  @override
  String get appointmentsLocationNotSet =>
      'Location will be set by the maintenance team';

  @override
  String get availableCitiesTitle => 'Service center currently available in';

  @override
  String get accidentDetailRepairEntry => 'Repair Entry';

  @override
  String get accidentDetailFinalRepair => 'Final';

  @override
  String get accidentDetailRepairDate => 'Date';

  @override
  String get accidentDetailTechnician => 'Technician';

  @override
  String get accidentDetailPartsReplaced => 'Parts Replaced:';

  @override
  String get supportTitle => 'Support & Help';

  @override
  String get supportCallUs => 'Call Us';

  @override
  String get supportEmailUs => 'Email Us';

  @override
  String get supportWhatsApp => 'WhatsApp';

  @override
  String get supportWorkingHours => 'Working Hours';

  @override
  String get supportWorkingHoursValue => 'Sat - Thu, 9 AM - 5 PM';

  @override
  String get supportAddress => 'Address';

  @override
  String get supportFollowUs => 'Follow Us';

  @override
  String get supportNeedHelp => 'Need Help?';

  @override
  String get supportDesc =>
      'Our team is ready to help you anytime. Contact us through any of the following methods.';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String privacyPolicyLastUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get privacyPolicyLink => 'Privacy Policy';

  @override
  String get privacyPolicyAgreePrefix => 'By continuing, you agree to our ';

  @override
  String get privacyPolicyView => 'View Privacy Policy';

  @override
  String get accidentNoSubscriptionTitle => 'Subscription Required';

  @override
  String get accidentNoSubscriptionContent =>
      'You need an active subscription to report an accident. Subscribe to a plan first.';

  @override
  String get accidentNoSubscriptionAction => 'Subscribe Now';

  @override
  String get subscriptionPayTitle => 'Complete Payment';

  @override
  String get subscriptionPayDesc =>
      'Transfer the amount below, then confirm to activate your subscription.';

  @override
  String get subscriptionPayAccountsTitle => 'Payment Accounts';

  @override
  String get subscriptionPayNote =>
      'After payment, our finance team will verify within 24 hours and activate your subscription.';

  @override
  String get subscriptionPayConfirmButton => 'I\'ve Paid — Activate';

  @override
  String get subscriptionPaySuccess =>
      'Subscription request submitted. Our team will verify your payment shortly.';
}

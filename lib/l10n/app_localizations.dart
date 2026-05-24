import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

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
    Locale('en'),
    Locale('id')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Zora'**
  String get appName;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @generateStrategyButton.
  ///
  /// In en, this message translates to:
  /// **'Generate Strategy'**
  String get generateStrategyButton;

  /// No description provided for @goToHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goToHome;

  /// No description provided for @notSetYet.
  ///
  /// In en, this message translates to:
  /// **'Not set yet'**
  String get notSetYet;

  /// No description provided for @creatorFallback.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get creatorFallback;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @starterPlan.
  ///
  /// In en, this message translates to:
  /// **'Starter Plan'**
  String get starterPlan;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @preferencesSection.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesSection;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @supportSection.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportSection;

  /// No description provided for @helpFaq.
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get helpFaq;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @actionsSection.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actionsSection;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of this account?'**
  String get logoutConfirmBody;

  /// No description provided for @logoutConfirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get logoutConfirmCancel;

  /// No description provided for @logoutConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutConfirmAction;

  /// No description provided for @madeWithLove.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ for Skripsi'**
  String get madeWithLove;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @dashboardHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get dashboardHome;

  /// No description provided for @dashboardStrategy.
  ///
  /// In en, this message translates to:
  /// **'Strategy'**
  String get dashboardStrategy;

  /// No description provided for @dashboardContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get dashboardContent;

  /// No description provided for @welcomeSlideOneTitle.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered\nPersonal Branding'**
  String get welcomeSlideOneTitle;

  /// No description provided for @welcomeSlideOneDescription.
  ///
  /// In en, this message translates to:
  /// **'Let AI analyze your Ikigai and design a personal brand strategy that feels specific to you.'**
  String get welcomeSlideOneDescription;

  /// No description provided for @welcomeSlideTwoTitle.
  ///
  /// In en, this message translates to:
  /// **'Endless Content Ideas'**
  String get welcomeSlideTwoTitle;

  /// No description provided for @welcomeSlideTwoDescription.
  ///
  /// In en, this message translates to:
  /// **'Never run out of angles. Get content ideas tailored to your niche and audience.'**
  String get welcomeSlideTwoDescription;

  /// No description provided for @welcomeSlideThreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Scripts Ready to Post'**
  String get welcomeSlideThreeTitle;

  /// No description provided for @welcomeSlideThreeDescription.
  ///
  /// In en, this message translates to:
  /// **'Turn an idea into a TikTok script or Instagram caption in seconds.'**
  String get welcomeSlideThreeDescription;

  /// No description provided for @welcomeStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start Building My Brand'**
  String get welcomeStartButton;

  /// No description provided for @brandNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your brand name?'**
  String get brandNameTitle;

  /// No description provided for @brandNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Zora will use this name to shape a personal branding strategy around your identity.'**
  String get brandNameSubtitle;

  /// No description provided for @brandNameInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand name'**
  String get brandNameInputLabel;

  /// No description provided for @brandNameInputInfo.
  ///
  /// In en, this message translates to:
  /// **'Write the name people should recognize you or your business by.'**
  String get brandNameInputInfo;

  /// No description provided for @brandNameInputPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Example: Jane Doe Studio'**
  String get brandNameInputPlaceholder;

  /// No description provided for @brandNameValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter your brand name.'**
  String get brandNameValidation;

  /// No description provided for @brandNamePrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your data is private and only used for AI analysis.'**
  String get brandNamePrivacyNote;

  /// No description provided for @identityTitle.
  ///
  /// In en, this message translates to:
  /// **'Brand Identity Setup'**
  String get identityTitle;

  /// No description provided for @identitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Answer these Ikigai prompts so Zora can map your positioning.'**
  String get identitySubtitle;

  /// No description provided for @profileNameSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your profile name'**
  String get profileNameSelectionTitle;

  /// No description provided for @profileNameSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a name that best represents your brand. This will be your identity.'**
  String get profileNameSelectionSubtitle;

  /// No description provided for @categorySelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get categorySelectionTitle;

  /// No description provided for @categorySelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This defines the general area of your content.'**
  String get categorySelectionSubtitle;

  /// No description provided for @microNicheSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a micro-niche'**
  String get microNicheSelectionTitle;

  /// No description provided for @microNicheSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get specific. This is where your brand stands out.'**
  String get microNicheSelectionSubtitle;

  /// No description provided for @whatILoveLabel.
  ///
  /// In en, this message translates to:
  /// **'What I Love'**
  String get whatILoveLabel;

  /// No description provided for @whatILoveInfo.
  ///
  /// In en, this message translates to:
  /// **'Write the topics, activities, or problems you genuinely enjoy working on.'**
  String get whatILoveInfo;

  /// No description provided for @whatILovePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Example: helping small business owners improve their content'**
  String get whatILovePlaceholder;

  /// No description provided for @whatILoveValidation.
  ///
  /// In en, this message translates to:
  /// **'Describe what you love working on.'**
  String get whatILoveValidation;

  /// No description provided for @whatImGoodAtLabel.
  ///
  /// In en, this message translates to:
  /// **'What I\'m Good At'**
  String get whatImGoodAtLabel;

  /// No description provided for @whatImGoodAtInfo.
  ///
  /// In en, this message translates to:
  /// **'Write your strongest skills, knowledge, or repeatable advantages.'**
  String get whatImGoodAtInfo;

  /// No description provided for @whatImGoodAtPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Example: simplifying marketing strategy into practical steps'**
  String get whatImGoodAtPlaceholder;

  /// No description provided for @whatImGoodAtValidation.
  ///
  /// In en, this message translates to:
  /// **'Describe what you are good at.'**
  String get whatImGoodAtValidation;

  /// No description provided for @whatTheWorldNeedsLabel.
  ///
  /// In en, this message translates to:
  /// **'What The World Needs'**
  String get whatTheWorldNeedsLabel;

  /// No description provided for @whatTheWorldNeedsInfo.
  ///
  /// In en, this message translates to:
  /// **'Write the audience problem or market need you want to help solve.'**
  String get whatTheWorldNeedsInfo;

  /// No description provided for @whatTheWorldNeedsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Example: clearer content guidance for early-stage founders'**
  String get whatTheWorldNeedsPlaceholder;

  /// No description provided for @whatTheWorldNeedsValidation.
  ///
  /// In en, this message translates to:
  /// **'Describe the need you want to solve.'**
  String get whatTheWorldNeedsValidation;

  /// No description provided for @whatICanBePaidForLabel.
  ///
  /// In en, this message translates to:
  /// **'What I Can Be Paid For'**
  String get whatICanBePaidForLabel;

  /// No description provided for @whatICanBePaidForInfo.
  ///
  /// In en, this message translates to:
  /// **'Optional. Leave blank if you want Zora to help discover possible monetization options.'**
  String get whatICanBePaidForInfo;

  /// No description provided for @whatICanBePaidForPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Example: workshops, content audits, social media strategy'**
  String get whatICanBePaidForPlaceholder;

  /// No description provided for @whatICanBePaidForValidation.
  ///
  /// In en, this message translates to:
  /// **'Describe what you can monetize.'**
  String get whatICanBePaidForValidation;

  /// No description provided for @detectorTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Detector Intelligence'**
  String get detectorTitle;

  /// No description provided for @detectorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Analyze your strengths, weaknesses, and threats so Zora can find stronger opportunities.'**
  String get detectorSubtitle;

  /// No description provided for @strengthsLabel.
  ///
  /// In en, this message translates to:
  /// **'Strengths'**
  String get strengthsLabel;

  /// No description provided for @strengthsInfo.
  ///
  /// In en, this message translates to:
  /// **'Write advantages, skills, resources, or traits that can help your brand grow.'**
  String get strengthsInfo;

  /// No description provided for @strengthsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Example: clear teaching style, strong design sense'**
  String get strengthsPlaceholder;

  /// No description provided for @strengthsValidation.
  ///
  /// In en, this message translates to:
  /// **'Describe your strengths.'**
  String get strengthsValidation;

  /// No description provided for @weaknessesLabel.
  ///
  /// In en, this message translates to:
  /// **'Weaknesses'**
  String get weaknessesLabel;

  /// No description provided for @weaknessesInfo.
  ///
  /// In en, this message translates to:
  /// **'Write internal limits or habits that currently slow you down.'**
  String get weaknessesInfo;

  /// No description provided for @weaknessesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Example: inconsistent posting, not confident on camera'**
  String get weaknessesPlaceholder;

  /// No description provided for @weaknessesValidation.
  ///
  /// In en, this message translates to:
  /// **'Describe your weaknesses.'**
  String get weaknessesValidation;

  /// No description provided for @opportunitiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Opportunities'**
  String get opportunitiesLabel;

  /// No description provided for @opportunitiesInfo.
  ///
  /// In en, this message translates to:
  /// **'Write market gaps, audience demand, channels, or trends you could use.'**
  String get opportunitiesInfo;

  /// No description provided for @opportunitiesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Example: local founders need simple AI content workflows'**
  String get opportunitiesPlaceholder;

  /// No description provided for @opportunitiesValidation.
  ///
  /// In en, this message translates to:
  /// **'Describe your opportunities.'**
  String get opportunitiesValidation;

  /// No description provided for @threatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Threats'**
  String get threatsLabel;

  /// No description provided for @threatsInfo.
  ///
  /// In en, this message translates to:
  /// **'Write external challenges, competition, risks, or blockers you need to watch.'**
  String get threatsInfo;

  /// No description provided for @threatsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Example: crowded niche, changing platform algorithms'**
  String get threatsPlaceholder;

  /// No description provided for @threatsValidation.
  ///
  /// In en, this message translates to:
  /// **'Describe your threats.'**
  String get threatsValidation;

  /// No description provided for @premiseResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Here are some options for your premise'**
  String get premiseResultTitle;

  /// No description provided for @premiseResultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose one that best tells your story.'**
  String get premiseResultSubtitle;

  /// No description provided for @toneTitle.
  ///
  /// In en, this message translates to:
  /// **'Last step, define your voice'**
  String get toneTitle;

  /// No description provided for @toneSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Tone of Voice'**
  String get toneSectionLabel;

  /// No description provided for @toneEducational.
  ///
  /// In en, this message translates to:
  /// **'Educational & Informative'**
  String get toneEducational;

  /// No description provided for @toneCasual.
  ///
  /// In en, this message translates to:
  /// **'Casual & Friendly'**
  String get toneCasual;

  /// No description provided for @toneInspirational.
  ///
  /// In en, this message translates to:
  /// **'Inspirational & Motivational'**
  String get toneInspirational;

  /// No description provided for @toneFun.
  ///
  /// In en, this message translates to:
  /// **'Fun & Energetic'**
  String get toneFun;

  /// No description provided for @toneLuxury.
  ///
  /// In en, this message translates to:
  /// **'Luxury & Exclusive'**
  String get toneLuxury;

  /// No description provided for @toneBold.
  ///
  /// In en, this message translates to:
  /// **'Bold & Controversial'**
  String get toneBold;

  /// No description provided for @toneVisionary.
  ///
  /// In en, this message translates to:
  /// **'Visionary & Encouraging'**
  String get toneVisionary;

  /// No description provided for @targetAudienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Audience'**
  String get targetAudienceLabel;

  /// No description provided for @targetAudienceInfo.
  ///
  /// In en, this message translates to:
  /// **'Write who your content and offers are primarily for.'**
  String get targetAudienceInfo;

  /// No description provided for @targetAudiencePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Example: early-stage founders and solo creators'**
  String get targetAudiencePlaceholder;

  /// No description provided for @targetAudienceValidation.
  ///
  /// In en, this message translates to:
  /// **'Describe your target audience.'**
  String get targetAudienceValidation;

  /// No description provided for @toneRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose a tone of voice first.'**
  String get toneRequiredMessage;

  /// No description provided for @strategyGenerationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate the strategy.'**
  String get strategyGenerationFailed;

  /// No description provided for @pillarResultAppBar.
  ///
  /// In en, this message translates to:
  /// **'Content Pillars'**
  String get pillarResultAppBar;

  /// No description provided for @pillarResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Content Strategy'**
  String get pillarResultTitle;

  /// No description provided for @pillarResultEmpty.
  ///
  /// In en, this message translates to:
  /// **'No result yet.'**
  String get pillarResultEmpty;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeReadySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to build your brand today?'**
  String get homeReadySubtitle;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @generateNewIdea.
  ///
  /// In en, this message translates to:
  /// **'Generate\nNew Idea'**
  String get generateNewIdea;

  /// No description provided for @viralHooksVault.
  ///
  /// In en, this message translates to:
  /// **'Viral Hooks\nVault'**
  String get viralHooksVault;

  /// No description provided for @viralHooksTitle.
  ///
  /// In en, this message translates to:
  /// **'Viral Hooks Vault'**
  String get viralHooksTitle;

  /// No description provided for @viralHooksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Copy a headline template for your next post:'**
  String get viralHooksSubtitle;

  /// No description provided for @hookCopied.
  ///
  /// In en, this message translates to:
  /// **'Hook copied to clipboard!'**
  String get hookCopied;

  /// No description provided for @recentScripts.
  ///
  /// In en, this message translates to:
  /// **'Recent Scripts'**
  String get recentScripts;

  /// No description provided for @incompleteSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Your brand strategy is not complete yet.'**
  String get incompleteSetupTitle;

  /// No description provided for @incompleteSetupBody.
  ///
  /// In en, this message translates to:
  /// **'Complete your setup so Zora can personalize your content ideas and scripts.'**
  String get incompleteSetupBody;

  /// No description provided for @continueSetup.
  ///
  /// In en, this message translates to:
  /// **'Continue Setup'**
  String get continueSetup;

  /// No description provided for @updateBrandStrategy.
  ///
  /// In en, this message translates to:
  /// **'Update Brand Strategy'**
  String get updateBrandStrategy;

  /// No description provided for @dailySpark.
  ///
  /// In en, this message translates to:
  /// **'Daily Spark'**
  String get dailySpark;

  /// No description provided for @dailySparkPillar.
  ///
  /// In en, this message translates to:
  /// **'• {pillar}'**
  String dailySparkPillar(String pillar);

  /// No description provided for @dailySparkHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your audience needs {pillar} content today.'**
  String dailySparkHeadline(String pillar);

  /// No description provided for @dailySparkBody.
  ///
  /// In en, this message translates to:
  /// **'Create something relevant to improve engagement with your niche.'**
  String get dailySparkBody;

  /// No description provided for @noHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryTitle;

  /// No description provided for @noHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'Generate your first idea now.'**
  String get noHistoryBody;

  /// No description provided for @defaultPillar.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get defaultPillar;

  /// No description provided for @hookTemplateOne.
  ///
  /// In en, this message translates to:
  /// **'Stop making this mistake if you want to grow in...'**
  String get hookTemplateOne;

  /// No description provided for @hookTemplateTwo.
  ///
  /// In en, this message translates to:
  /// **'The secret most mentors never tell you about...'**
  String get hookTemplateTwo;

  /// No description provided for @hookTemplateThree.
  ///
  /// In en, this message translates to:
  /// **'3 fast ways to improve...'**
  String get hookTemplateThree;

  /// No description provided for @hookTemplateFour.
  ///
  /// In en, this message translates to:
  /// **'How I turned X into Y in 30 days...'**
  String get hookTemplateFour;

  /// No description provided for @hookTemplateFive.
  ///
  /// In en, this message translates to:
  /// **'Why your old strategy keeps failing...'**
  String get hookTemplateFive;

  /// No description provided for @hookTemplateSix.
  ///
  /// In en, this message translates to:
  /// **'The tool I use to make this easier...'**
  String get hookTemplateSix;

  /// No description provided for @contentGenerateNew.
  ///
  /// In en, this message translates to:
  /// **'Generate New'**
  String get contentGenerateNew;

  /// No description provided for @contentScriptHistory.
  ///
  /// In en, this message translates to:
  /// **'Script History'**
  String get contentScriptHistory;

  /// No description provided for @contentHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review generated scripts and open the ones you want to reuse.'**
  String get contentHistorySubtitle;

  /// No description provided for @contentEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Scripts Generated Yet'**
  String get contentEmptyTitle;

  /// No description provided for @contentEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Generate ideas first, then create scripts.'**
  String get contentEmptyBody;

  /// No description provided for @createIdeaSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you want to create?'**
  String get createIdeaSheetTitle;

  /// No description provided for @createIdeaPillarLabel.
  ///
  /// In en, this message translates to:
  /// **'Content Pillar'**
  String get createIdeaPillarLabel;

  /// No description provided for @createIdeaCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Idea Count'**
  String get createIdeaCountLabel;

  /// No description provided for @createIdeaCountValue.
  ///
  /// In en, this message translates to:
  /// **'{count} ideas'**
  String createIdeaCountValue(int count);

  /// No description provided for @createIdeaMissingPillar.
  ///
  /// In en, this message translates to:
  /// **'Please choose a content pillar.'**
  String get createIdeaMissingPillar;

  /// No description provided for @createIdeaLoadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Crafting Ideas...'**
  String get createIdeaLoadingLabel;

  /// No description provided for @createIdeaGenerateButton.
  ///
  /// In en, this message translates to:
  /// **'Generate Ideas'**
  String get createIdeaGenerateButton;

  /// No description provided for @strategyTitle.
  ///
  /// In en, this message translates to:
  /// **'Brand Strategy'**
  String get strategyTitle;

  /// No description provided for @strategySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review your positioning, Ikigai, SWOT, and content pillars in one place.'**
  String get strategySubtitle;

  /// No description provided for @strategyIncompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Your brand strategy is not complete yet.'**
  String get strategyIncompleteTitle;

  /// No description provided for @strategyIncompleteBody.
  ///
  /// In en, this message translates to:
  /// **'Complete your setup to unlock your audience, monetization, SWOT, and content pillar strategy.'**
  String get strategyIncompleteBody;

  /// No description provided for @profileSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Summary'**
  String get profileSummaryTitle;

  /// No description provided for @profileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile Name'**
  String get profileNameLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @microNicheLabel.
  ///
  /// In en, this message translates to:
  /// **'Micro-Niche'**
  String get microNicheLabel;

  /// No description provided for @premiseLabel.
  ///
  /// In en, this message translates to:
  /// **'Premise'**
  String get premiseLabel;

  /// No description provided for @toneOfVoiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Tone of Voice'**
  String get toneOfVoiceLabel;

  /// No description provided for @monetizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Monetization'**
  String get monetizationTitle;

  /// No description provided for @ikigaiAnswersTitle.
  ///
  /// In en, this message translates to:
  /// **'Ikigai Answers'**
  String get ikigaiAnswersTitle;

  /// No description provided for @swotAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'SWOT Analysis'**
  String get swotAnalysisTitle;

  /// No description provided for @contentPillarsTitle.
  ///
  /// In en, this message translates to:
  /// **'Content Pillars'**
  String get contentPillarsTitle;

  /// No description provided for @contentPillarsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No content pillars yet.'**
  String get contentPillarsEmpty;
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
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

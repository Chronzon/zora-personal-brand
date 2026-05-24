# PRD: Fix Onboarding Persistence and Resume Bug

## Purpose

Fix the app flow bug where users can reach the dashboard with incomplete or missing onboarding data, especially after refresh, login from another browser, or switching from guest-like onboarding behavior to a real account.

This PRD only covers the onboarding/session/dashboard bug. It does not cover AI provider changes.

## Problem Summary

The app currently allows users to start onboarding before the app has clearly confirmed a real logged-in account.

Some onboarding data can exist only in Flutter provider memory or can be saved under a different backend user than the final logged-in account. After refresh or opening the app in another browser, the app reloads only persisted backend data. This causes the dashboard to show incomplete data.

There is also no clear way to resume onboarding or restart/update the personal branding setup from the dashboard.

## Current Symptoms

- User completes part of onboarding, refreshes the page, and gets sent back to the start.
- User logs into an existing account and gets sent directly to the dashboard.
- Dashboard may show generated scripts but miss brand strategy data such as:
  - monetization/opportunities
  - strengths
  - weaknesses
  - threats
  - selected premise
  - content pillars
- User who is sent to the dashboard has no obvious button to continue onboarding.
- User who completed onboarding has no obvious button to update or rebuild their branding.

## Root Cause

The app currently treats partial profile data as enough to go to dashboard.

Current simplified readiness logic:

```text
has full name and what_i_love -> dashboard
```

This is too weak. It only means onboarding has started, not that onboarding is complete.

The app needs to distinguish:

```text
not_started
in_progress
completed
```

## Desired Product Behavior

Keep the existing high-level flow:

```text
SplashScreen
-> LanguageScreen
-> WelcomeScreen
-> Login/Signup or Start
-> Dashboard
```

But the dashboard should become the central place that tells the user whether their branding setup is complete.

Expected dashboard behavior:

```text
If onboarding is incomplete:
  Show notification/card:
  "Your brand strategy is not complete yet."
  Button: "Continue Setup"

If onboarding is complete:
  Show normal dashboard strategy data.
  Button: "Update Brand Strategy" or "Rebuild Branding"
```

## Important UX Decision

Do not trap users away from the dashboard forever.

It is acceptable for login success to navigate to dashboard, but the dashboard must clearly show incomplete onboarding status and provide a resume action.

This keeps the activity diagram mostly stable while fixing the broken user experience.

## Definitions

### Not Started

No meaningful onboarding data exists.

Possible derived condition:

```text
userProfile.fullName is empty
```

or:

```text
userProfile.fullName is empty
and userProfile.whatILove is empty
and brandProfile.selectedProfileName is empty
```

### In Progress

Some onboarding data exists, but the strategy is not complete.

Possible derived condition:

```text
user has some profile or brand profile data
and brandProfile.contentPillars is empty
```

### Completed

The user has completed the core onboarding strategy.

Minimal derived condition:

```text
brandProfile.contentPillars is not empty
```

Recommended stronger condition:

```text
userProfile.fullName is not empty
userProfile.whatILove is not empty
userProfile.whatImGoodAt is not empty
userProfile.whatTheWorldNeeds is not empty
brandProfile.selectedProfileName is not empty
brandProfile.selectedCategory is not empty
brandProfile.selectedMicroNiche is not empty
brandProfile.selectedPremise is not empty
brandProfile.toneOfVoice is not empty
brandProfile.targetAudience is not empty
brandProfile.contentPillars is not empty
```

For a minimal bug fix, `contentPillars.isNotEmpty` can be used as the completion signal.

## Recommended Implementation

### 1. Add Onboarding Status Logic

Add derived status logic in Flutter, preferably in:

```text
lib/features/onboarding/presentation/providers/onboarding_provider.dart
```

Recommended enum:

```dart
enum OnboardingStatus {
  notStarted,
  inProgress,
  completed,
}
```

Recommended provider getters:

```dart
OnboardingStatus get onboardingStatus;
bool get isOnboardingComplete;
bool get hasStartedOnboarding;
```

### 2. Replace Weak Dashboard Readiness Logic

Current logic returns true too early:

```dart
return _userProfile.fullName.isNotEmpty && _userProfile.whatILove.isNotEmpty;
```

Do not use this as a dashboard-complete signal.

Instead:

```text
loadUserData() should load data only.
Dashboard should inspect onboardingStatus.
```

If keeping a boolean return is necessary for minimal changes, make it mean completed:

```dart
return isOnboardingComplete;
```

### 3. Add Dashboard Incomplete Setup Card

In the dashboard, show a prominent card/banner when onboarding is not completed.

Suggested copy:

```text
Your brand strategy is not complete yet.
Complete your setup so Zora can personalize your content ideas and scripts.
```

Button:

```text
Continue Setup
```

Action:

```text
Navigate to the appropriate onboarding screen.
```

### 4. Add Update/Rebuild Branding Button

When onboarding is completed, dashboard should still offer a way to revise branding.

Suggested button labels:

```text
Update Brand Strategy
Rebuild Branding
Edit Brand Setup
```

Preferred label:

```text
Update Brand Strategy
```

This should route the user back into onboarding while preserving existing data where possible.

### 5. Resume Destination Logic

Create one helper method to decide which onboarding screen to open.

Recommended helper location:

```text
lib/features/onboarding/presentation/providers/onboarding_provider.dart
```

or as a UI helper:

```text
lib/features/onboarding/presentation/onboarding_resume_route.dart
```

Minimal version:

```text
Always route Continue Setup to NameScreen.
```

Better version:

```text
No full name -> NameScreen
Missing Ikigai fields -> IdentityFinderScreen
Missing selected identity/category/niche -> AI identity result or IdentityFinderScreen
Missing SWOT -> SwotScreen
Missing premise -> Premise generation/SWOT flow
Missing tone/target audience -> ToneOfVoiceScreen
Missing content pillars -> ToneOfVoiceScreen
Complete -> Dashboard
```

For this bug fix, it is acceptable to start with the minimal version if screen restoration is risky.

### 6. Gate Start Button Before Onboarding

The `WelcomeScreen` start button should not send unauthenticated users directly into onboarding.

Current behavior:

```text
WelcomeScreen Start -> NameScreen
```

Desired behavior:

```text
WelcomeScreen Start
  if authenticated -> Continue/Start Onboarding
  if not authenticated -> LoginScreen
```

After successful login/signup:

```text
if onboarding completed -> Dashboard
if onboarding incomplete -> Continue/Start Onboarding
```

This prevents new onboarding data from being saved under an unintended guest account.

### 7. Avoid Silent Guest Ownership for Onboarding

Do not silently create a guest backend user for core onboarding data if the expected product behavior is account-owned onboarding.

Review usage of:

```text
ApiClient.ensureGuestSession()
```

For this bug fix, avoid using guest session creation before saving core onboarding data unless explicit guest mode is intentionally supported.

## Files Likely Involved

Frontend flow:

```text
lib/features/onboarding/presentation/pages/welcome_screen.dart
lib/features/auth/presentation/pages/login_screen.dart
lib/features/onboarding/presentation/pages/splash_screen.dart
lib/features/onboarding/presentation/providers/onboarding_provider.dart
lib/features/dashboard/presentation/pages/dashboard_screen.dart
lib/features/dashboard/presentation/widgets/home_tab.dart
lib/features/dashboard/presentation/widgets/strategy_tab.dart
```

Frontend data:

```text
lib/features/onboarding/data/repositories/onboarding_repository.dart
lib/core/network/api_client.dart
```

Backend data already supports required fields:

```text
laravel-backend/app/Http/Controllers/Api/ProfileController.php
laravel-backend/database/migrations/2026_05_03_000001_create_personal_branding_tables.php
```

## Backend Notes

No major backend schema change is required for the minimal bug fix.

Existing database tables already store:

```text
user_profiles
brand_profiles
content_ideas
generated_scripts
```

Future improvement:

```text
Add onboarding_status
Add onboarding_step
Add onboarding_completed_at
```

But for now, derive completion from existing profile/brand profile fields.

## Acceptance Criteria

- Start button no longer begins onboarding under an unintended unauthenticated/guest state.
- Login/signup can lead users to onboarding when their setup is incomplete.
- Refreshing the app with incomplete onboarding no longer traps the user in an empty dashboard without guidance.
- Dashboard shows a clear incomplete setup notification when onboarding is not complete.
- Dashboard includes a `Continue Setup` button for incomplete users.
- Dashboard includes an `Update Brand Strategy` button for completed users.
- Opening the app in another browser with the same account shows the same persisted onboarding status.
- Generated scripts can still be displayed without requiring onboarding to be complete.
- Existing generated scripts and content ideas are not deleted when the user resumes or updates onboarding.

## Manual Test Cases

### New User

1. Open app with no session.
2. Choose language.
3. Click Start.
4. App should require login/signup.
5. After signup, app should start onboarding.
6. Complete onboarding.
7. Dashboard should show completed strategy.

### Partial Onboarding

1. Login/signup.
2. Start onboarding.
3. Stop halfway.
4. Refresh page.
5. App may go to dashboard, but dashboard must show incomplete setup card.
6. Click Continue Setup.
7. User can continue onboarding.

### Completed User

1. Login with account that completed onboarding.
2. App should show dashboard with strategy data.
3. Dashboard should show `Update Brand Strategy`.
4. Clicking it should allow user to edit/rebuild onboarding.

### Cross-Browser

1. Complete onboarding in one browser.
2. Login with same account in another browser.
3. Dashboard should show completed strategy data.
4. If onboarding was incomplete, dashboard should show Continue Setup.

### Existing Broken Case

1. Generate script after partial/inconsistent onboarding.
2. Refresh or login again.
3. Generated scripts may still appear.
4. Dashboard should not silently look complete if brand profile is incomplete.
5. Dashboard should show Continue Setup.


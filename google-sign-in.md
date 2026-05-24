# Google Sign-In Implementation Context

This document explains the intended Google OAuth behavior for this app. It is meant to help another chat, agent, or developer implement the real Google Sign-In flow without treating it as a mock login.

## Goal

Google Sign-In should be an additional login method for the same user account, not a separate user identity.

The app should support these three cases:

1. A user signs up or signs in using Google for the first time.
2. A user already has an email/password account and later signs in with Google using the same email.
3. A user already has an account with a different/random email and later wants to connect Google.

Existing user data must remain attached to the same user account whenever Google is linked.

## Recommended Data Model

Keep the main app identity in the `users` table.

Example user fields:

```text
users
- id
- email
- password nullable
- profile_name / display_name
- email_verified_at
- created_at
- updated_at
```

Add a separate table for OAuth login methods.

```text
social_accounts
- id
- user_id
- provider
- provider_user_id
- provider_email
- created_at
- updated_at
```

For Google:

```text
provider = google
provider_user_id = Google account subject/id
provider_email = Google email
```

The app should use `users.id` as the owner for all important app data, not the email address or OAuth provider.

## Profile Name Rule

The app profile name must stay the same as the name set on the app's name screen.

Google's profile name should not overwrite the app's profile name after the user already set one.

Use this rule:

```text
If user.profile_name is empty:
    Google name may be used as a temporary fallback.
Else:
    Keep the existing app profile_name.
```

This means:

```text
Google Sign-In changes how the user logs in.
It should not change the user's app profile identity.
```

## Case 1: New User Uses Google First

Flow:

```text
User clicks Continue with Google
Backend verifies Google OAuth token/code
No social_accounts row exists for this Google account
No users row exists with this verified Google email
Create new users row
Create social_accounts row linked to that user
Log in the user
Send user to onboarding/name screen if profile_name is empty
```

Important behavior:

```text
email = Google email
email_verified_at = now, if Google email is verified
profile_name = null or temporary Google name fallback
```

The preferred UX for this app is to send the user to the name screen so the app profile name is chosen inside the app.

## Case 2: Existing Email/Password User Uses Google With Same Email

Example:

```text
Existing user:
email = user@gmail.com
profile_name = "Andi Personal Brand"

Google account:
email = user@gmail.com
email_verified = true
```

Flow:

```text
User clicks Continue with Google
Backend verifies Google OAuth token/code
No social_accounts row exists yet
Find users row by Google email
If Google email is verified, link Google account to that existing user
Log in the existing user
Keep all existing app data
Keep existing profile_name
```

Do not create a duplicate user.

The result should be:

```text
Same users.id
Same profile_name
Same posts/settings/analysis/history
New Google login method linked
```

## Case 3: Existing User With Different/Random Email Connects Google

Example:

```text
Existing user:
email = random@example.com
profile_name = "Andi Brand"

Google account:
email = andi@gmail.com
```

This must be handled as an explicit account-linking flow.

Flow:

```text
User must already be logged in
User opens account/security settings
User clicks Connect Google
Backend verifies Google OAuth token/code
Check that this Google account is not already linked to another user
Create social_accounts row linked to the currently logged-in user
Keep existing user data
Keep existing profile_name
```

Important rule:

```text
Different email should not be auto-merged during normal login.
Different email should only be linked while the user is already authenticated.
```

This protects users from accidental or unsafe account merging.

## Login Resolution Order

When handling a Google login callback:

```text
1. Verify the Google token/code with Google.
2. Read Google's stable user id, email, email_verified, and name.
3. Look for social_accounts where:
   provider = google
   provider_user_id = Google subject/id
4. If found, log in that linked user.
5. If not found, and Google email is verified, look for users.email = Google email.
6. If matching user exists, link Google to that user and log in.
7. If no matching user exists, create a new user, link Google, and continue onboarding.
```

Do not trust email alone unless Google says the email is verified.

## Account Linking Safety Rules

Before linking a Google account:

```text
Check provider = google and provider_user_id.
If already linked to the same user, do nothing and continue.
If already linked to a different user, reject the link.
```

This prevents one Google account from being attached to multiple app users.

Recommended database constraints:

```text
Unique(provider, provider_user_id)
Unique(user_id, provider)
```

The second constraint is optional if the app may allow multiple Google accounts per user. For this app, one Google account per user is simpler.

## What Should Not Happen

Do not create a new user when a verified Google email already matches an existing user.

Do not overwrite `profile_name` with the Google account name if the app profile name already exists.

Do not merge accounts with different emails during normal Google login.

Do not store Google access tokens unless the app needs to call Google APIs later. For simple sign-in, storing the provider user id and email is enough.

Do not attach important app data to email addresses. Attach it to `users.id`.

## Expected User Experience

On sign in/sign up page:

```text
Continue with Google
Email/password sign in
Email/password sign up
```

On account/settings page:

```text
Connected accounts
- Google: connected/disconnected
- Connect Google button if not connected
```

If Google login creates a new account and the user has no app profile name yet:

```text
Redirect to name screen
```

If Google login links to an existing user:

```text
Log in directly
Keep existing profile name and data
```

## Short Summary

Google is a login method, not the source of the user's app identity.

The app identity should remain:

```text
users.id + profile_name from the app's name screen
```

The Google identity should be stored as:

```text
social_accounts(provider = google, provider_user_id, provider_email)
```

This keeps user data stable across email/password login, Google login, and account linking.

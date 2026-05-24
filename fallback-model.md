# AI Fallback Model and Onboarding Persistence

This document explains how the app should handle AI provider limits, failures, and fallback models during onboarding.

## Goal

The user should not lose onboarding progress if an AI model hits a limit, times out, or fails halfway through the onboarding process.

AI generation should be treated as replaceable. User-selected onboarding answers should be treated as persistent progress.

## Core Rule

Save user decisions step by step.

Do not wait until the entire onboarding flow is finished before saving user progress.

Use this mental model:

```text
AI suggestion generated = temporary
User selects/accepts suggestion = saved to database
```

If the AI fails, only the current generation step should be affected. Previously accepted answers should remain safe.

## Example Scenario

```text
Step 1: AI suggests profile direction
User selects an option
App saves selected answer

Step 2: AI suggests target audience
User selects an option
App saves selected answer

Step 3: AI provider hits quota/rate limit
Generation fails
```

Expected result:

```text
Step 1 data remains saved
Step 2 data remains saved
Step 3 can be retried, generated with fallback model, or filled manually
User should not restart onboarding
```

## Recommended Flow

When the app needs an AI response:

```text
User reaches an AI-assisted onboarding step
        |
        v
Call primary AI provider/model
        |
        | success
        v
Show AI suggestions to user
        |
        v
User selects/accepts an answer
        |
        v
Save selected answer to database
```

If the primary model fails:

```text
Primary AI provider/model fails
        |
        v
Check error type
        |
        v
If retryable, quota, or rate limit error:
    try fallback model/provider
        |
        v
If fallback succeeds:
    show fallback suggestions to user
        |
        v
    save only after user selects/accepts
```

If all AI options fail:

```text
Show manual input option
Show retry option
Optionally show default non-AI suggestions
Keep previous onboarding progress
```

## Suggested Provider Priority

Use the configured primary provider first.

Example:

```text
1. Primary provider from AI_PROVIDER
2. Fallback external provider
3. Local/simple deterministic fallback
4. Manual input
```

The exact provider names can be configured through environment variables.

Example environment variables:

```text
AI_PROVIDER=gemini
AI_MODEL=...
AI_FALLBACK_PROVIDER=openrouter
AI_FALLBACK_MODEL=...
```

The app should not hard-code secrets or model keys into the repository. Production keys should stay in Coolify environment variables.

## What Should Be Saved

Save accepted user decisions:

```text
user_id
onboarding_step
selected_answer
source: manual / primary_ai / fallback_ai / default
model_provider nullable
model_name nullable
completed_at
```

Saving the source is useful for debugging and product analysis.

Example:

```text
source = fallback_ai
model_provider = openrouter
model_name = selected fallback model
```

## What Should Not Be Saved as Final Data

Do not save AI suggestions as final onboarding data immediately after generation.

Bad:

```text
AI generates answer
App saves it as final profile data automatically
```

Good:

```text
AI generates answer
User reviews/selects/accepts answer
App saves selected answer
```

Temporary AI suggestions may be cached if needed, but they should not replace user profile data until the user confirms them.

## Error Handling

Classify AI errors into practical categories:

```text
rate_limit
quota_exceeded
timeout
provider_unavailable
invalid_request
auth_error
unknown
```

Recommended behavior:

```text
rate_limit / quota_exceeded:
    try fallback provider/model

timeout / provider_unavailable:
    retry briefly, then fallback

invalid_request:
    do not fallback blindly; fix prompt/input issue

auth_error:
    do not fallback silently if configuration is broken; log clearly

unknown:
    fallback once, then show manual/retry option
```

## User Experience

The user should see a simple recovery path, not a technical error.

Possible messages:

```text
AI suggestions are temporarily unavailable.
You can retry, continue manually, or use a default suggestion.
```

Avoid exposing provider names, API quota details, stack traces, or internal errors to normal users.

## Resume Behavior

The onboarding screen should load existing progress from the database.

When a user returns:

```text
Load completed onboarding steps
Load current incomplete step
Allow user to continue from the last unfinished step
```

This is important if:

```text
AI fails halfway
User refreshes the page
User closes the browser
Deployment restarts
Network connection drops
```

## Backend Responsibility

The backend should own:

```text
AI provider selection
Fallback logic
Error classification
Saving selected onboarding answers
Returning resume state
```

The frontend should own:

```text
Showing loading state
Showing generated suggestions
Letting user select/accept/edit answers
Showing retry/manual/default options
```

Do not put provider keys or fallback decision logic directly in the Flutter client.

## Important Safety Rule

A failed AI call must not delete, reset, or overwrite previously saved onboarding progress.

The only step affected by an AI limit should be the current step that requested generation.

## Short Summary

The correct behavior is:

```text
Persist user choices immediately.
Use fallback AI only when the primary AI fails.
Offer manual input if all AI options fail.
Resume onboarding from saved database state.
Never overwrite confirmed user profile data with unconfirmed AI output.
```


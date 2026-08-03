# Anonity — Flutter App (Supabase-backed)

A Flutter implementation of the "Anonity" mockup: an anonymous social
app with a dark, purple-accented theme, now wired to a real Supabase
backend for auth, posts, likes, groups, and profiles.

## Screens included

1. Splash Screen
2. Login Screen (real Supabase Auth)
3. Create Account Screen (real Supabase Auth signup)
4. Home Feed — For You / Following / Spicy / Relationship / Work tabs, live posts
5. Explore — search, popular sections (real post counts), trending posts
6. Create Post — section picker, anonymous toggle, inserts into Supabase
7. Groups — My Groups / Discover, join a group
8. Group Details — Feed (live group messages) / Members / About
9. Profile — real stats, your posts, log out

## ⚠️ Setup required before this runs

The app will build, but every screen will error until you:

### 1. Create a Supabase project
Go to [supabase.com](https://supabase.com) → New Project. Wait for it to finish provisioning.

### 2. Run the schema
Dashboard → **SQL Editor** → New query → paste the entire contents of
[`supabase/schema.sql`](supabase/schema.sql) → **Run**.

This creates: `profiles`, `posts`, `likes`, `groups`, `group_members`,
`group_messages` — with Row Level Security policies already applied,
a trigger that auto-creates a profile on signup, and a trigger that
keeps `posts.likes_count` in sync. It also seeds 4 starter groups
matching the mockup.

### 3. Add your credentials
Dashboard → **Project Settings → API**. Copy the **Project URL** and
**anon public** key into `lib/config/supabase_config.dart`:

```dart
static const String url = 'https://YOUR_PROJECT_REF.supabase.co';
static const String anonKey = 'YOUR_ANON_PUBLIC_KEY';
```

The anon key is safe to ship client-side — RLS is what protects the
data, not secrecy of that key. Never put your `service_role` key here.

### 4. (Recommended for testing) Turn off email confirmation
By default Supabase requires email confirmation before a session is
created, so `Create Account` won't log the user straight in — they'd
need to click a confirmation email first (the app handles this: it'll
show a message and send them to Login instead). To skip that while
developing: Dashboard → **Authentication → Providers → Email** →
turn off "Confirm email".

### 5. Install and run
```bash
flutter pub get
flutter run
```

## Structure

```
supabase/schema.sql            # Full DB schema + RLS policies (run this in Supabase)
lib/
  main.dart                    # Initializes Supabase, routes on auth state (AuthGate)
  config/supabase_config.dart  # <-- put your Project URL + anon key here
  theme/app_theme.dart         # Colors, typography, ThemeData
  models/models.dart           # AppProfile, AppPost, AppGroup, GroupMessage (fromMap)
  services/
    auth_service.dart          # signUp / signIn / signOut / auth state stream
    post_service.dart          # feed, trending, search, create, like/unlike
    group_service.dart         # my groups, discover, join, messages
    profile_service.dart       # current user's profile
  widgets/
    anonity_logo.dart          # SectionTag chip + shared logo asset path
    anonity_bottom_nav.dart    # Shared bottom nav w/ center create button
    post_card.dart             # Post card wired to real like/unlike
  screens/
    splash_screen.dart
    login_screen.dart
    create_account_screen.dart
    root_shell.dart            # Hosts the 4 tab destinations + FAB
    home_feed_screen.dart
    explore_screen.dart
    create_post_screen.dart
    groups_screen.dart
    group_details_screen.dart
    profile_screen.dart
```

## How auth routing works

`main.dart` wraps everything in `AuthGate`, which listens to
`AuthService.onAuthStateChange` and shows `RootShell` (the tabbed app)
if there's a session, or `SplashScreen` if not. Login/Create Account
call `Navigator.popUntil((route) => route.isFirst)` on success — that
pops back to `AuthGate`, which re-renders automatically once Supabase
reports the new session. Logging out (from Profile) does the same in
reverse.

## What's real vs. still a placeholder

**Real (backed by Supabase):**
- Email/password signup & login, session persistence
- Creating posts, section filtering, liking/unliking (optimistic UI)
- Trending posts (by like count), basic content search
- Joining groups, posting/reading group messages
- Profile stats (post count, group count, total likes on your posts)

**Still placeholders:**
- Social login buttons (Google/Apple/Discord) — show "coming soon"
- Sign-in by username (only email works — see `AuthService.signIn`
  for why: resolving username → email safely needs a server-side
  Edge Function, since the client can't look up another user's email)
- Comments, reposts, polls, image attachments, bookmarks, replies
- Push notifications, invites, group creation from the app

## A note on the test suite

`test/widget_test.dart` now initializes Supabase with dummy
credentials in `setUpAll` before pumping the widget tree (since
`AnonityApp` talks to `Supabase.instance` on build). This wasn't run
against a live Flutter SDK in this environment — if `flutter test`
complains about missing platform channels for local session storage,
that's a known friction point with testing `supabase_flutter` apps;
you may need to mock its storage layer (see the package's own testing
docs) or move session-dependent widgets behind a seam that's easier
to fake in tests.

# Anonity — Flutter App

A Flutter implementation of the 9-screen "Anonity" mockup: an anonymous
social app with a dark, purple-accented theme.

## Screens included

1. Splash Screen
2. Login Screen
3. Create Account Screen
4. Home Feed (For You / Following / Spicy / Relationship / Work tabs)
5. Explore (search, popular sections, trending posts)
6. Create Post (section picker, anonymous toggle, poll/emoji options)
7. Groups (My Groups / Discover)
8. Group Details (Feed / Members / About)
9. Profile (stats, Posts / Replies / Bookmarks)

## Structure

```
lib/
  main.dart                    # App entry point, theme, initial route
  theme/app_theme.dart         # Colors, typography, ThemeData
  models/models.dart           # AppPost, AppGroup, GroupMessage + mock data
  widgets/
    anonity_logo.dart          # Brand mask icon + SectionTag chip
    anonity_bottom_nav.dart    # Shared bottom nav w/ center create button
    post_card.dart             # Reusable post card (like/comment/repost)
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

## Running it

This is real, runnable Flutter code — it wasn't executed/compiled in this
environment (no Flutter SDK here), so double-check with `flutter analyze`
once you pull it into a Flutter setup.

```bash
flutter pub get
flutter run
```

Requires Flutter 3.19+ (uses Material 3, `google_fonts` for the Inter
typeface). All data is local mock data in `lib/models/models.dart` —
there's no backend wired up yet.

## Notes on fidelity to the mockup

- The cat-mask logo is drawn with `CustomPainter` (no image assets needed).
- Section tags (Spicy 🌶️ / Relationship 💗 / Work 💼) use consistent
  colors defined once in `app_theme.dart` via `sectionColor()`.
- Navigation: Splash → Login/Create Account → `RootShell` (tabbed shell
  with Home, Groups, Explore, Profile + a center "+" that opens
  Create Post as a full-screen modal), matching the bottom nav bar
  shown across the mockup.
- Social login buttons and "Post" actions are stubbed (no real auth or
  persistence) — they navigate/show a snackbar so the flow feels complete.

## Next steps you'll likely want

- Wire up real auth (Firebase Auth, Supabase, or your own API)
- Replace mock data with API calls / state management (Riverpod, Bloc, etc.)
- Add form validation on Login/Create Account
- Persist likes/posts locally or remotely

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

/// Turns a caught exception into a short, human-readable sentence.
/// Never surfaces raw exception dumps (stack traces, request URIs,
/// SQL internals) to the user — those go in the console via
/// debugPrint for whoever's developing the app, not the UI.
String friendlyError(Object error) {
  if (error is AuthException) return error.message;

  if (error is PostgrestException) {
    final m = error.message;
    // Most Postgrest messages (RLS violations, "no rows found", our
    // own thrown messages) are short and fine to show directly.
    // Anything that looks like it leaked raw schema/SQL internals
    // falls back to a generic line instead.
    final looksInternal = m.contains('relation') ||
        m.contains('constraint') ||
        m.contains('column') ||
        m.length > 140;
    return looksInternal ? 'Something went wrong talking to the server. Please try again.' : m;
  }

  final text = error.toString();
  if (text.contains('ClientException') ||
      text.contains('SocketException') ||
      text.contains('Failed host lookup') ||
      text.contains('Connection')) {
    return "Can't reach the server. Check your connection and try again.";
  }
  return 'Something went wrong. Please try again.';
}

/// Toast — for minor, non-blocking feedback (a join succeeded, a
/// like failed to register). Never use this for an error that
/// blocks the user's primary action; use [InlineError] instead.
void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// Modal — reserved for errors serious enough that the user must
/// consciously acknowledge them before continuing. Use sparingly;
/// most errors should be [InlineError] instead.
Future<void> showErrorModal(BuildContext context, {required String title, required String message}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
      ],
    ),
  );
}

/// Inline error — sits directly beneath the field, button, or
/// composer it explains. This is the default placement for anything
/// that matters (a failed login, a failed post, a failed message
/// send) — not a toast, which is easy to miss or dismiss.
class InlineError extends StatelessWidget {
  final String message;
  const InlineError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.spicy),
          const SizedBox(width: 6),
          Expanded(
            child: Text(message, style: const TextStyle(color: AppColors.spicy, fontSize: 12.5, height: 1.3)),
          ),
        ],
      ),
    );
  }
}

/// Full-page load failure — friendly message plus a Retry button,
/// standing in for a raw exception dump when an entire page's data
/// fails to load. Placed inline in the page itself.
class InlineErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const InlineErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 32, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(minimumSize: const Size(120, 40)),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

/// Empty state — used when an async load succeeds but the result list
/// is empty. Always offers a hint of what to do next, never just
/// "Nothing here" silence.
class EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  const EmptyView({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              )),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                )),
          ],
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}

/// Full-screen error — the entire body of a screen failed to load
/// (not just a section). Centered, large, with a clear retry path.
/// Use this when there's no shell UI worth showing around the error.
class FullPageError extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const FullPageError({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            const Text(
              "Can't load this screen",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              friendlyError(error),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 12),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ],
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tiny helper: shows a SnackBar that auto-dismisses faster for
/// success (1.5s) than for errors (4s) — so a "Like failed" message
/// doesn't vanish as quickly as a "Posted!" one.
void showStatusToast(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: isError ? 4 : 2),
      backgroundColor: isError ? AppColors.spicy : null,
    ),
  );
}

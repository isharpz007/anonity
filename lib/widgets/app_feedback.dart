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

// lib/utils/dialog_components.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// ConfirmationDialog widget
/// ConfirmationDialog widget
/// Returns true when user confirms, false when cancels.
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final IconData icon;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm; // <-- added
  final VoidCallback? onCancel;  // <-- added

  const ConfirmationDialog({
    Key? key,
    required this.title,
    this.icon = Icons.help_outline,
    this.confirmText = 'Yes',
    this.cancelText = 'No',
    this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(icon, size: 28, color: kAccentColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      content: const SizedBox.shrink(),
      actions: [
        TextButton(
          onPressed: () {
            if (onCancel != null) {
              onCancel!();
            } else {
              Navigator.of(context).pop(false);
            }
          },
          child:
              Text(cancelText, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kAccentColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            if (onConfirm != null) {
              onConfirm!();
            } else {
              Navigator.of(context).pop(true);
            }
          },
          child: Text(confirmText, style: GoogleFonts.inter(color: Colors.white)),
        ),
      ],
    );
  }
}


/// SuccessDialog widget
class SuccessDialog extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onOk;

  const SuccessDialog({
    Key? key,
    required this.title,
    this.message,
    this.onOk,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 28, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child:
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      content: message != null
          ? Text(message!, style: GoogleFonts.inter())
          : const SizedBox.shrink(),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onOk != null) onOk!();
          },
          child: Text('OK', style: GoogleFonts.inter()),
        ),
      ],
    );
  }
}

/// LoadingDialog (you provided this originally)
class LoadingDialog extends StatelessWidget {
  final String message;
  
  const LoadingDialog({super.key, this.message = 'Loading...'});
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: kAccentColor),
            const SizedBox(height: 20),
            Text(
              message,
              style: GoogleFonts.inter(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/// FirebaseErrorDialog (you provided this originally)
class FirebaseErrorDialog extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;
  
  const FirebaseErrorDialog({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Error',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
      content: Text(
        errorMessage,
        style: GoogleFonts.inter(fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry!();
            },
            child: const Text('Retry'),
          ),
      ],
    );
  }
}

/// Helper to show confirmation dialog easily (returns Future<bool?>)
Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  IconData icon = Icons.help_outline,
  String confirmText = 'Yes',
  String cancelText = 'No',
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => ConfirmationDialog(
      title: title,
      icon: icon,
      confirmText: confirmText,
      cancelText: cancelText,
    ),
  );
}

/// Helper to show success dialog
Future<void> showSuccessDialog({
  required BuildContext context,
  required String title,
  String? message,
  VoidCallback? onOk,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => SuccessDialog(title: title, message: message, onOk: onOk),
  );
}

/// Helper to show loading dialog
Future<void> showLoadingDialog({
  required BuildContext context,
  String message = 'Loading...',
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => LoadingDialog(message: message),
  );
}

/// Helper to show firebase error dialog
Future<void> showFirebaseErrorDialog({
  required BuildContext context,
  required String errorMessage,
  VoidCallback? onRetry,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => FirebaseErrorDialog(errorMessage: errorMessage, onRetry: onRetry),
  );
}

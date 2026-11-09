import 'package:flutter/material.dart';

void showMessage(BuildContext context, String message, {bool isError = false}) {
  final colors = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message,
          style: isError ? TextStyle(color: colors.onError) : null),
      backgroundColor: isError ? colors.error : null,
    ));
}

Future<bool> confirmDelete(BuildContext context) async {
  final confirmed = await showAdaptiveDialog<bool>(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: const Text('Delete record?'),
      content: const Text('This health record will be permanently removed.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

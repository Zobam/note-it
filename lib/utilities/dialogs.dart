import 'package:flutter/material.dart';

Future<bool?> showDeleteDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete this note?'),
          content: const Text('Are you sure you want to delete this note'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete note'),
            ),
          ],
        );
      });
}

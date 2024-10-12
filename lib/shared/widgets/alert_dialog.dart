import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppAlertDialog extends StatelessWidget {
  const AppAlertDialog({
    required this.title,
    required this.onYes,
    super.key,
  });

  final String title;
  final void Function() onYes;

  Future<void> show(BuildContext context) => showDialog(
        context: context,
        builder: (_) => this,
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      backgroundColor: Colors.white,
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Confirm'),
        ],
      ),
      content: Text(
        title,
      ),
      actions: [
        TextButton(
          onPressed: context.pop,
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () {
            onYes();
            context.pop();
          },
          child: const Text('Yes'),
        ),
      ],
    );
  }
}

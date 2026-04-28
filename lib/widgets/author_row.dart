import 'package:flutter/material.dart';

class AuthorRow extends StatelessWidget {
  final String authorName;
  final String date;
  const AuthorRow({super.key, required this.authorName, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            authorName[0],
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(authorName,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            Text(date,
                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ],
    );
  }
}

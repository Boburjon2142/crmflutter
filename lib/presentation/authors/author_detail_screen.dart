import 'package:flutter/material.dart';

import '../../domain/authors/entities/author.dart';

class AuthorDetailScreen extends StatelessWidget {
  const AuthorDetailScreen({super.key, required this.author});

  final Author author;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(author.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage:
                author.photoUrl != null ? NetworkImage(author.photoUrl!) : null,
            child: author.photoUrl == null
                ? Text(author.name.characters.take(2).toString())
                : null,
          ),
          const SizedBox(height: 12),
          Text(author.name, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                author.isFeatured ? Icons.star : Icons.star_border,
                color: author.isFeatured ? Colors.amber : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(author.isFeatured ? 'Tanlangan' : 'Oddiy'),
            ],
          ),
          const SizedBox(height: 16),
          Text('Biografiya', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            author.bio.isEmpty ? 'Biografiya mavjud emas' : author.bio,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/blog.dart';
import '../widgets/author_row.dart';
import '../widgets/category_chip.dart';

class BlogDetailScreen extends StatelessWidget {
  final Blog blog;
  const BlogDetailScreen({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                blog.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 64, color: Colors.grey),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFFF8F9FA),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryChip(label: blog.category),
                  const SizedBox(height: 12),
                  Text(
                    blog.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AuthorRow(authorName: blog.authorName, date: blog.date),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  Text(
                    '${blog.description}\n\n'
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                    'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                    'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.\n\n'
                    'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum '
                    'dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non '
                    'proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\n'
                    'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium '
                    'doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore '
                    'veritatis et quasi architecto beatae vitae dicta sunt explicabo.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800],
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

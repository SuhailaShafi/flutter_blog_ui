import 'package:flutter/material.dart';
import '../models/blog.dart';
import '../widgets/blog_card.dart';
import 'blog_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Blog',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: sampleBlogs.length,
        itemBuilder: (context, index) => BlogCard(
          blog: sampleBlogs[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlogDetailScreen(blog: sampleBlogs[index]),
            ),
          ),
        ),
      ),
    );
  }
}

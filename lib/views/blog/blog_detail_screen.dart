import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/blog_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/blog_viewmodel.dart';
import 'add_edit_blog_screen.dart';

class BlogDetailScreen extends StatelessWidget {
  final BlogModel blog;

  const BlogDetailScreen({super.key, required this.blog});

  Future<void> _delete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Blog'),
        content: const Text('Are you sure you want to delete this blog?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade400),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    final ok = await context.read<BlogViewModel>().deleteBlog(blog.id);
    if (!context.mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      final err = context.read<BlogViewModel>().error;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err ?? 'Delete failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final isOwner = authVm.user?.id == blog.authorId;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: blog.imageUrl != null && blog.imageUrl!.isNotEmpty
                ? 280
                : 140,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: blog.imageUrl != null && blog.imageUrl!.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: blog.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  colors: AppTheme.headerGradient),
                            ),
                          ),
                          errorWidget: (context, url, err) => Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  colors: AppTheme.headerGradient),
                            ),
                          ),
                        ),
                        // Gradient overlay for readability
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.5),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppTheme.headerGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: isOwner
                ? [
                    Container(
                      margin: const EdgeInsets.only(right: 4, top: 8, bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => AddEditBlogScreen(blog: blog)),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.white, size: 20),
                        onPressed: () => _delete(context),
                      ),
                    ),
                  ]
                : null,
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (blog.categoryName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: AppTheme.primaryGradient),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          blog.categoryName!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      blog.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: AppTheme.primaryGradient),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (blog.authorName ?? '?')
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                blog.authorName ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              Text(
                                DateFormat('MMMM d, y').format(blog.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      blog.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2D2D44),
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

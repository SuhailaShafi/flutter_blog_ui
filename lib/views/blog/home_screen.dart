import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/blog_viewmodel.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../widgets/blog_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/loading_widget.dart';
import 'add_edit_blog_screen.dart';
import 'blog_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlogViewModel>().fetchBlogs();
      context.read<CategoryViewModel>().fetchCategories();
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<BlogViewModel>().fetchBlogs(),
      context.read<CategoryViewModel>().fetchCategories(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BlogViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final categoryVm = context.watch<CategoryViewModel>();
    final categories = categoryVm.categories;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppTheme.headerGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Blog Pro',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Text(
                                  'Discover Stories',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh_rounded,
                                  color: Colors.white),
                              onPressed: _refresh,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: categories.isNotEmpty
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(52),
                    child: Container(
                      color: Colors.white,
                      child: SizedBox(
                        height: 52,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          children: [
                            CategoryChip(
                              category: null,
                              isSelected: vm.selectedCategoryId == null,
                              onSelected: (_) => vm.filterByCategory(null),
                            ),
                            ...categories.map(
                              (c) => CategoryChip(
                                category: c,
                                isSelected: vm.selectedCategoryId == c.id,
                                onSelected: vm.filterByCategory,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : null,
          ),
        ],
        body: vm.isLoading && vm.blogs.isEmpty
            ? const LoadingWidget()
            : vm.blogs.isEmpty
                ? _EmptyState(onAdd: authVm.isAuthenticated
                    ? () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddEditBlogScreen()),
                        );
                        if (mounted) _refresh();
                      }
                    : null)
                : RefreshIndicator(
                    onRefresh: _refresh,
                    color: AppTheme.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 80),
                      itemCount: vm.blogs.length,
                      itemBuilder: (_, i) {
                        final blog = vm.blogs[i];
                        return _AnimatedBlogCard(
                          index: i,
                          child: BlogCard(
                            blog: blog,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlogDetailScreen(blog: blog),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
      floatingActionButton: authVm.isAuthenticated
          ? Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: AppTheme.primaryGradient),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddEditBlogScreen()),
                  );
                  if (mounted) _refresh();
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
            )
          : null,
    );
  }
}

class _AnimatedBlogCard extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedBlogCard({required this.index, required this.child});

  @override
  State<_AnimatedBlogCard> createState() => _AnimatedBlogCardState();
}

class _AnimatedBlogCardState extends State<_AnimatedBlogCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback? onAdd;

  const _EmptyState({this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppTheme.primaryGradient
                      .map((c) => c.withValues(alpha: 0.15))
                      .toList(),
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.article_outlined,
                size: 48,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No blogs yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share your story\nwith the community!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            if (onAdd != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Write a Blog'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

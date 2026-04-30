import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/blog_viewmodel.dart';
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
      final vm = context.read<BlogViewModel>();
      vm.fetchBlogs();
      vm.fetchCategories();
    });
  }

  Future<void> _refresh() async {
    await context.read<BlogViewModel>().fetchBlogs();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BlogViewModel>();
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter row
          if (vm.categories.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  CategoryChip(
                    category: null,
                    isSelected: vm.selectedCategoryId == null,
                    onSelected: (_) => vm.filterByCategory(null),
                  ),
                  ...vm.categories.map(
                    (c) => CategoryChip(
                      category: c,
                      isSelected: vm.selectedCategoryId == c.id,
                      onSelected: vm.filterByCategory,
                    ),
                  ),
                ],
              ),
            ),
          // Blog list
          Expanded(
            child: vm.isLoading && vm.blogs.isEmpty
                ? const LoadingWidget()
                : vm.blogs.isEmpty
                    ? const Center(child: Text('No blogs yet.'))
                    : RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView.builder(
                          itemCount: vm.blogs.length,
                          itemBuilder: (_, i) {
                            final blog = vm.blogs[i];
                            return BlogCard(
                              blog: blog,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      BlogDetailScreen(blog: blog),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: authVm.isAuthenticated
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddEditBlogScreen()),
                );
                if (mounted) _refresh();
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/blog_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/blog_viewmodel.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/gradient_button.dart';

class AddEditBlogScreen extends StatefulWidget {
  final BlogModel? blog;

  const AddEditBlogScreen({super.key, this.blog});

  @override
  State<AddEditBlogScreen> createState() => _AddEditBlogScreenState();
}

class _AddEditBlogScreenState extends State<AddEditBlogScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _imageCtrl;
  String? _selectedCategoryId;

  bool get _isEditing => widget.blog != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.blog?.title ?? '');
    _descCtrl = TextEditingController(text: widget.blog?.description ?? '');
    _imageCtrl = TextEditingController(text: widget.blog?.imageUrl ?? '');
    _selectedCategoryId = widget.blog?.categoryId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryViewModel>().fetchCategories();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final blogVm = context.read<BlogViewModel>();
    final authVm = context.read<AuthViewModel>();
    final userId = authVm.user?.id ?? '';

    final blogData = BlogModel(
      id: widget.blog?.id ?? '',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      imageUrl: _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
      categoryId: _selectedCategoryId,
      authorId: userId,
      createdAt: widget.blog?.createdAt ?? DateTime.now(),
    );

    final ok = _isEditing
        ? await blogVm.updateBlog(widget.blog!.id, blogData)
        : await blogVm.addBlog(blogData);

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else if (blogVm.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(blogVm.error!)));
      blogVm.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final blogVm = context.watch<BlogViewModel>();
    final categoryVm = context.watch<CategoryViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
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
              ),
              title: Text(
                _isEditing ? 'Edit Blog' : 'New Blog',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SectionLabel(label: 'Blog Title'),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _titleCtrl,
                      label: 'Title',
                      prefixIcon: Icons.title_rounded,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    _SectionLabel(label: 'Description'),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _descCtrl,
                      label: 'Write your story...',
                      prefixIcon: Icons.edit_note_rounded,
                      maxLines: 6,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    _SectionLabel(label: 'Cover Image (optional)'),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _imageCtrl,
                      label: 'Image URL',
                      prefixIcon: Icons.image_outlined,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 20),
                    _SectionLabel(label: 'Category'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DropdownButtonFormField<String?>(
                        value: _selectedCategoryId,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.category_outlined,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          suffixIcon: categoryVm.isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                )
                              : null,
                        ),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('No category')),
                          ...categoryVm.categories.map(
                            (c) => DropdownMenuItem(
                                value: c.id, child: Text(c.name)),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedCategoryId = v),
                      ),
                    ),
                    const SizedBox(height: 32),
                    GradientButton(
                      onPressed: blogVm.isLoading ? null : _submit,
                      height: 54,
                      child: blogVm.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isEditing
                                      ? Icons.save_rounded
                                      : Icons.send_rounded,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isEditing ? 'Update Blog' : 'Publish Blog',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 32),
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

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4A4A6A),
        letterSpacing: 0.3,
      ),
    );
  }
}

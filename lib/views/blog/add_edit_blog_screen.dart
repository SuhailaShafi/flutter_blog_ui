import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/blog_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/blog_viewmodel.dart';
import '../../widgets/custom_textfield.dart';

class AddEditBlogScreen extends StatefulWidget {
  final BlogModel? blog; // null = add mode

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
      context.read<BlogViewModel>().fetchCategories();
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
    final vm = context.watch<BlogViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Blog' : 'New Blog'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _titleCtrl,
                label: 'Title',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descCtrl,
                label: 'Description',
                maxLines: 5,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _imageCtrl,
                label: 'Image URL (optional)',
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              if (vm.categories.isNotEmpty)
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('No category')),
                    ...vm.categories.map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: vm.isLoading ? null : _submit,
                child: vm.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Update' : 'Publish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

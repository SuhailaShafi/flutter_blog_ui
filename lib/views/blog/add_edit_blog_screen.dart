import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  String? _selectedCategoryId;
  File? _pickedImage;
  String? _existingImageUrl;
  bool _uploadingImage = false;

  bool get _isEditing => widget.blog != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.blog?.title ?? '');
    _descCtrl = TextEditingController(text: widget.blog?.description ?? '');
    _existingImageUrl = widget.blog?.imageUrl;
    _selectedCategoryId = widget.blog?.categoryId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryViewModel>().fetchCategories();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_pickedImage != null || _existingImageUrl != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remove Image',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _pickedImage = null;
                    _existingImageUrl = null;
                  });
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<String?> _uploadImage() async {
    if (_pickedImage == null) return _existingImageUrl;
    setState(() => _uploadingImage = true);
    try {
      final bytes = await _pickedImage!.readAsBytes();
      // Safely extract extension, default to jpg
      final rawExt = _pickedImage!.path.split('.').last.split('?').first.toLowerCase();
      final ext = ['jpg', 'jpeg', 'png', 'webp', 'heic'].contains(rawExt) ? rawExt : 'jpg';
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final mimeType = ext == 'png' ? 'image/png' : ext == 'webp' ? 'image/webp' : 'image/jpeg';
      await Supabase.instance.client.storage
          .from('blog_images')
          .uploadBinary(fileName, bytes,
              fileOptions: FileOptions(contentType: mimeType));
      return Supabase.instance.client.storage
          .from('blog_images')
          .getPublicUrl(fileName);
    } on StorageException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: ${e.message}')));
      }
      return null;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')));
      }
      return null;
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final blogVm = context.read<BlogViewModel>();
    final authVm = context.read<AuthViewModel>();
    final userId = authVm.user?.id ?? '';

    final imageUrl = await _uploadImage();

    final blogData = BlogModel(
      id: widget.blog?.id ?? '',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      imageUrl: imageUrl,
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
    final hasImage = _pickedImage != null || _existingImageUrl != null;

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
                    // Image picker UI
                    GestureDetector(
                      onTap: _showImageSourceSheet,
                      child: Container(
                        height: hasImage ? 200 : 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: hasImage
                                ? AppTheme.primary.withValues(alpha: 0.4)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: _uploadingImage
                            ? const Center(child: CircularProgressIndicator())
                            : hasImage
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(13),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        _pickedImage != null
                                            ? Image.file(_pickedImage!,
                                                fit: BoxFit.cover)
                                            : Image.network(_existingImageUrl!,
                                                fit: BoxFit.cover),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: _showImageSourceSheet,
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withValues(alpha: 0.5),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.edit,
                                                  color: Colors.white,
                                                  size: 16),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined,
                                          size: 40,
                                          color: Colors.grey.shade400),
                                      const SizedBox(height: 8),
                                      Text('Tap to add image',
                                          style: TextStyle(
                                              color: Colors.grey.shade500)),
                                    ],
                                  ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionLabel(label: 'Category'),
                    const SizedBox(height: 8),
                    if (categoryVm.categories.isEmpty && !categoryVm.isLoading)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.orange.shade700, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'No categories available. Please add a category first.',
                              style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonFormField<String>(
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
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : null,
                          ),
                          hint: const Text('Select a category'),
                          items: categoryVm.categories
                              .map((c) => DropdownMenuItem(
                                  value: c.id, child: Text(c.name)))
                              .toList(),
                          validator: (v) =>
                              v == null ? 'Please select a category.' : null,
                          onChanged: (v) =>
                              setState(() => _selectedCategoryId = v),
                        ),
                      ),
                    const SizedBox(height: 32),
                    GradientButton(
                      onPressed: (blogVm.isLoading || _uploadingImage)
                          ? null
                          : _submit,
                      height: 54,
                      child: (blogVm.isLoading || _uploadingImage)
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

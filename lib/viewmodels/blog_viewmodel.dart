import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/services/supabase_service.dart';
import '../models/blog_model.dart';
import '../models/category_model.dart';

class BlogViewModel extends ChangeNotifier {
  final _supabase = SupabaseService.instance;

  List<BlogModel> _blogs = [];
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  bool _isLoading = false;
  String? _error;

  List<BlogModel> get blogs => _selectedCategoryId == null
      ? _blogs
      : _blogs.where((b) => b.categoryId == _selectedCategoryId).toList();
  List<CategoryModel> get categories => _categories;
  String? get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchBlogs() async {
    _setLoading(true);
    try {
      debugPrint('[BlogVM] fetchBlogs: start');
      final data = await _supabase.client
          .from(AppConstants.blogsTable)
          .select('*, profiles!author_id(username)')
          .order('created_at', ascending: false);
      _blogs = (data as List).map((e) => BlogModel.fromJson(e)).toList();
      _error = null;
      debugPrint('[BlogVM] fetchBlogs: got ${_blogs.length} blogs');
      notifyListeners();
    } catch (e, st) {
      _error = e.toString();
      debugPrint('[BlogVM] fetchBlogs error: $e\n$st');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchCategories() async {
    try {
      final data = await _supabase.client
          .from(AppConstants.categoriesTable)
          .select()
          .order('name');
      _categories =
          (data as List).map((e) => CategoryModel.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void filterByCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  Future<bool> addBlog(BlogModel blog) async {
    _setLoading(true);
    try {
      debugPrint('[BlogVM] addBlog: inserting ${blog.title}');
      await _supabase.client
          .from(AppConstants.blogsTable)
          .insert(blog.toJson());
      debugPrint('[BlogVM] addBlog: insert success, refreshing');
      await fetchBlogs();
      return true;
    } catch (e, st) {
      _error = e.toString();
      debugPrint('[BlogVM] addBlog error: $e\n$st');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateBlog(String id, BlogModel blog) async {
    _setLoading(true);
    try {
      await _supabase.client
          .from(AppConstants.blogsTable)
          .update(blog.toJson())
          .eq('id', id);
      await fetchBlogs();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteBlog(String id) async {
    _setLoading(true);
    try {
      await _supabase.client
          .from(AppConstants.blogsTable)
          .delete()
          .eq('id', id);
      _blogs.removeWhere((b) => b.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}

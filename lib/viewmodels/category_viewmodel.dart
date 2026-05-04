import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/services/supabase_service.dart';
import '../models/category_model.dart';

class CategoryViewModel extends ChangeNotifier {
  final _supabase = SupabaseService.instance;

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCategories() async {
    _setLoading(true);
    try {
      final data = await _supabase.client
          .from(AppConstants.categoriesTable)
          .select()
          .order('name');
      _categories =
          (data as List).map((e) => CategoryModel.fromJson(e)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Returns null on success, or an error message string.
  Future<String?> addCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Name is required.';

    final duplicate = _categories
        .any((c) => c.name.toLowerCase() == trimmed.toLowerCase());
    if (duplicate) return '"$trimmed" already exists.';

    _setLoading(true);
    try {
      final data = await _supabase.client
          .from(AppConstants.categoriesTable)
          .insert({'name': trimmed})
          .select()
          .single();
      _categories.add(CategoryModel.fromJson(data));
      _categories.sort((a, b) => a.name.compareTo(b.name));
      _error = null;
      notifyListeners();
      return null;
    } catch (e) {
      final msg = e.toString();
      // Supabase unique-constraint violation
      if (msg.contains('duplicate') || msg.contains('unique')) {
        return '"$trimmed" already exists.';
      }
      _error = msg;
      notifyListeners();
      return msg;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> deleteCategory(String id) async {
    _setLoading(true);
    try {
      await _supabase.client
          .from(AppConstants.categoriesTable)
          .delete()
          .eq('id', id);
      _categories.removeWhere((c) => c.id == id);
      _error = null;
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return _error;
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

import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/services/supabase_service.dart';
import '../models/blog_model.dart';
import '../models/user_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final _supabase = SupabaseService.instance;

  UserModel? _profile;
  List<BlogModel> _userBlogs = [];
  bool _isLoading = false;
  String? _error;

  UserModel? get profile => _profile;
  List<BlogModel> get userBlogs => _userBlogs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile(String userId) async {
    _setLoading(true);
    try {
      final data = await _supabase.client
          .from(AppConstants.profilesTable)
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data != null) {
        final email =
            _supabase.currentUser?.email ?? data['email'] as String? ?? '';
        _profile = UserModel.fromJson({...data, 'email': email});
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchUserBlogs(String userId) async {
    _setLoading(true);
    try {
      final data = await _supabase.client
          .from(AppConstants.blogsTable)
          .select('*, categories(name), profiles(username)')
          .eq('author_id', userId)
          .order('created_at', ascending: false);
      _userBlogs = (data as List).map((e) => BlogModel.fromJson(e)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
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

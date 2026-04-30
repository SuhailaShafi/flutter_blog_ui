import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final _supabase = SupabaseService.instance;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _supabase.currentUser != null;

  AuthViewModel() {
    _loadCurrentUser();
    // Keep user in sync with auth state changes
    _supabase.authStateChanges.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        _loadCurrentUser();
      } else if (data.event == AuthChangeEvent.signedOut) {
        _user = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadCurrentUser() async {
    final supaUser = _supabase.currentUser;
    if (supaUser == null) return;
    try {
      final data = await _supabase.client
          .from('profiles')
          .select()
          .eq('id', supaUser.id)
          .maybeSingle();
      if (data != null) {
        _user = UserModel.fromJson({...data, 'email': supaUser.email ?? ''});
      } else {
        _user = UserModel(id: supaUser.id, email: supaUser.email ?? '');
      }
      notifyListeners();
    } catch (_) {
      _user = UserModel(id: supaUser.id, email: supaUser.email ?? '');
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      await _supabase.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      await _loadCurrentUser();
      _error = null;
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signup(String email, String password, String username) async {
    _setLoading(true);
    try {
      final res = await _supabase.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'username': username.trim()},
      );
      if (res.user != null) {
        // Upsert profile row
        await _supabase.client.from('profiles').upsert({
          'id': res.user!.id,
          'email': email.trim(),
          'username': username.trim(),
        });
        await _loadCurrentUser();
      }
      _error = null;
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _supabase.client.auth.signOut();
    _user = null;
    notifyListeners();
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

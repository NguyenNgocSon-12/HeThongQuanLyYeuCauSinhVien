import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? _currentUser;
  UserModel? _userData;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  UserModel? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize authentication state
  Future<void> _initializeAuth() async {
    _currentUser = _firebaseAuth.currentUser;
    if (_currentUser != null) {
      await _loadUserData();
    }
    notifyListeners();
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    try {
      if (_currentUser != null) {
        _userData = UserModel(
          email: _currentUser!.email ?? '',
          mssv: '',
          name: '',
          role: 'student',
          password: '',
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to load user data: $e';
    }
  }

  // Register with MSSV
  Future<bool> registerWithMSSV({
    required String mssv,
    required String password,
    required String fullName,
    required String className,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.registerWithMSSV(
        mssv: mssv,
        password: password,
        fullName: fullName,
        className: className,
      );

      if (user != null) {
        _currentUser = user;
        await _loadUserData();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login with MSSV
  Future<bool> loginWithMSSV(String mssv, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.loginWithMSSV(mssv, password);

      if (user != null) {
        _currentUser = user;
        await _loadUserData();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();
      _currentUser = null;
      _userData = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to logout: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get current user role
  String? getUserRole() {
    return _userData?.role;
  }

  // Check if user is admin
  bool isAdmin() {
    return _userData?.role == 'admin';
  }

  // Check if user is student
  bool isStudent() {
    return _userData?.role == 'student';
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

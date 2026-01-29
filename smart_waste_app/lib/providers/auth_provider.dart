import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../config/constants.dart';

/// Authentication state provider
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.role == AppConstants.roleAdmin;
  bool get isResident => _user?.role == AppConstants.roleResident;
  String? get zoneId => _user?.zoneId;

  AuthProvider() {
    _init();
  }

  /// Initialize auth state
  Future<void> _init() async {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser.uid);
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  /// Load user data from Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      _user = await _authService.getUserData(uid);
      if (_user != null) {
        // Subscribe to zone notifications
        await _notificationService.subscribeToZone(_user!.zoneId);
        
        // Update FCM token
        final token = await _notificationService.getToken();
        if (token != null) {
          await _authService.updateFcmToken(uid, token);
        }
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (_user != null) {
        await _notificationService.subscribeToZone(_user!.zoneId);
      }
      
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String zoneId,
    String role = AppConstants.roleResident,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        zoneId: zoneId,
        role: role,
      );
      
      if (_user != null) {
        await _notificationService.subscribeToZone(_user!.zoneId);
      }
      
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (_user != null) {
      await _notificationService.unsubscribeFromZone(_user!.zoneId);
    }
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

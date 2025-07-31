import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  AuthViewModel() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) async {
    _user = user;
    if (user != null) {
      await _loadUserData(user.uid);
    } else {
      _userModel = null;
    }
    notifyListeners();
  }

  Future<void> _loadUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        _userModel = UserModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          uid,
        );
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Login
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Error inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Registro
  Future<bool> signUp(String email, String password, String displayName) async {
    try {
      _setLoading(true);
      _setError(null);

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Crear documento del usuario en Firestore
      if (result.user != null) {
        await _createUserDocument(result.user!, displayName);
        await result.user!.updateDisplayName(displayName);
      }

      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Error inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Crear documento del usuario
  Future<void> _createUserDocument(User user, String displayName) async {
    UserModel userModel = UserModel(
      uid: user.uid,
      email: user.email!,
      displayName: displayName,
      role: 'user', // Por defecto es usuario normal
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toFirestore());
  }

  // Recuperar contraseña
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Error inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Mensajes de error en español
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo electrónico.';
      case 'weak-password':
        return 'La contraseña es muy débil.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde.';
      default:
        return 'Error de autenticación: $errorCode';
    }
  }
}

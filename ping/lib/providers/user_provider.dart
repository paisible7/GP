import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  String? _userRole;
  String? _userEmail;
  String? _userName;
  String? _userId;

  String? get userRole => _userRole;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get userId => _userId;

  bool get isLoggedIn => _userId != null;
  bool get isProfessor => _userRole == 'professeur';
  bool get isStudent => _userRole == 'etudiant';
  bool get isAdmin => _userRole == 'admin';

  Future<void> login(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user != null) {
      await initializeUser();
    } else {
      throw AuthException('Échec de la connexion');
    }
  }

  Future<void> initializeUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      _userId = user.id;
      _userEmail = user.email;

      // Récupérer les informations du profil
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      if (profile != null) {
        _userRole = profile['role'];
        _userName = profile['nom_complet'];
      }
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _userRole = null;
    _userEmail = null;
    _userName = null;
    _userId = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? email,
    String? name,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Mettre à jour le profil dans la table profiles
    final updates = <String, dynamic>{};
    if (name != null) updates['nom_complet'] = name;
    
    if (updates.isNotEmpty) {
      await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', user.id);
    }

    // Mettre à jour l'email si nécessaire
    if (email != null && email != user.email) {
      await _supabase.auth.updateUser(
        UserAttributes(email: email),
      );
    }

    // Recharger les informations
    await initializeUser();
  }

  // Méthode pour vérifier si l'utilisateur a un rôle spécifique
  bool hasRole(String role) {
    return _userRole == role;
  }
} 
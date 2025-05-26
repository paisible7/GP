import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider extends ChangeNotifier {
  String? _userId;
  String? _userRole;

  String? get userId => _userId;
  String? get userRole => _userRole;

  bool get isLoggedIn => _userId != null;
  bool get isProfessor => _userRole == 'professeur';
  bool get isStudent => _userRole == 'etudiant';

  // Initialiser l'état de l'utilisateur au démarrage de l'application
  Future<void> initialize() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        _userId = session.user.id;
        // Récupérer le rôle depuis la table 'profiles'
        final data = await Supabase.instance.client
            .from('profiles')
            .select('role')
            .eq('id', _userId.toString())
            .single();
        if (data != null) {
          _userRole = data['role'] as String?;
        }
        notifyListeners();
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation: $e');
      // En cas d'erreur, on déconnecte l'utilisateur
      await logout();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      // Authentification avec Supabase
      final AuthResponse res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user == null) {
        throw Exception('Échec de l\'authentification');
      }
      _userId = res.user!.id;

      // Récupération du rôle depuis la table 'profiles'
      final data = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', _userId.toString())
          .single();
      if (data == null) {
         // Gérer le cas où le profil n'est pas trouvé
         await logout();
         throw Exception('Profil utilisateur non trouvé.');
      }
      _userRole = data['role'] as String?;
      if (_userRole == null) {
         // Gérer le cas où le rôle est null dans le profil
         await logout();
         throw Exception('Rôle utilisateur non défini dans le profil.');
      }
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      _userId = null;
      _userRole = null;
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  // Méthode pour vérifier si l'utilisateur a un rôle spécifique.
  bool hasRole(String role) {
    return _userRole == role;
  }
} 
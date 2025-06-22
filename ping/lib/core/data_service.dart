import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

class DataService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Méthodes pour les statistiques du tableau de bord
  static Future<Map<String, int>> getDashboardStats() async {
    try {
      // Compter les étudiants
      final studentsData = await _supabase
          .from('etudiants')
          .select('id');
      final studentsCount = studentsData.length;

      // Compter les professeurs
      final professorsData = await _supabase
          .from('professeurs')
          .select('id');
      final professorsCount = professorsData.length;

      // Compter les cours
      final coursesData = await _supabase
          .from('cours')
          .select('id');
      final coursesCount = coursesData.length;

      // Compter les salles
      final roomsData = await _supabase
          .from('salles_de_cours')
          .select('id');
      final roomsCount = roomsData.length;

      // Compter les sessions actives aujourd'hui
      final today = DateTime.now();
      final sessionsData = await _supabase
          .from('sessions_presence')
          .select('id')
          .eq('est_active', true)
          .gte('date', today.toIso8601String().split('T')[0]);
      final sessionsCount = sessionsData.length;

      // Calculer le taux de présence global
      final presencesData = await _supabase
          .from('presences')
          .select('id')
          .eq('statut', 'present');
      final presencesCount = presencesData.length;

      final totalPresencesData = await _supabase
          .from('presences')
          .select('id');
      final totalPresences = totalPresencesData.length;

      double presenceRate = 0;
      if (totalPresences > 0) {
        presenceRate = presencesCount / totalPresences * 100;
      }

      // Compter les étudiants par promotion
      final l1Data = await _supabase
          .from('etudiants')
          .select('id')
          .eq('promotion', 'L1');
      final l1Count = l1Data.length;

      final l2Data = await _supabase
          .from('etudiants')
          .select('id')
          .eq('promotion', 'L2');
      final l2Count = l2Data.length;

      final l3Data = await _supabase
          .from('etudiants')
          .select('id')
          .eq('promotion', 'L3');
      final l3Count = l3Data.length;

      final l4Data = await _supabase
          .from('etudiants')
          .select('id')
          .eq('promotion', 'L4');
      final l4Count = l4Data.length;

      return {
        'totalStudents': studentsCount,
        'totalProfessors': professorsCount,
        'totalCourses': coursesCount,
        'totalRooms': roomsCount,
        'todaySessions': sessionsCount,
        'presenceRate': presenceRate.round(),
        'l1Students': l1Count,
        'l2Students': l2Count,
        'l3Students': l3Count,
        'l4Students': l4Count,
      };
    } catch (e) {
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }

  // Méthodes pour les professeurs
  static Future<List<Map<String, dynamic>>> getProfessors() async {
    try {
      final data = await _supabase
          .from('profiles')
          .select('*')
          .eq('role', 'professeur')
          .order('nom_complet');
      
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Erreur lors du chargement des professeurs: $e');
    }
  }

  static Future<void> addProfessor({
    required String email,
    required String name,
    required String password,
  }) async {
    try {
      // Créer l'utilisateur dans Supabase Auth
      final authResponse = await _supabase.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          emailConfirm: true,
        ),
      );

      if (authResponse.user == null) {
        throw Exception('Erreur lors de la création du compte');
      }

      // Ajouter le profil dans la table profiles
      await _supabase.from('profiles').insert({
        'id': authResponse.user!.id,
        'nom_complet': name,
        'role': 'professeur',
      });

      // Ajouter dans la table professeurs
      await _supabase.from('professeurs').insert({
        'id': authResponse.user!.id,
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du professeur: $e');
    }
  }

  static Future<void> deleteProfessor(String professorId) async {
    try {
      // Supprimer de la table professeurs
      await _supabase
          .from('professeurs')
          .delete()
          .eq('id', professorId);

      // Supprimer le profil
      await _supabase
          .from('profiles')
          .delete()
          .eq('id', professorId);

      // Supprimer l'utilisateur de l'auth
      await _supabase.auth.admin.deleteUser(professorId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du professeur: $e');
    }
  }

  // Méthodes pour les étudiants
  static Future<List<Map<String, dynamic>>> getStudents() async {
    try {
      final data = await _supabase
          .from('profiles')
          .select('*, etudiants!inner(*)')
          .eq('role', 'etudiant')
          .order('nom_complet');
      
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Erreur lors du chargement des étudiants: $e');
    }
  }

  static Future<void> addStudent({
    required String email,
    required String name,
    required String password,
    required String promotion,
    required String filiere,
  }) async {
    try {
      // Créer l'utilisateur dans Supabase Auth
      final authResponse = await _supabase.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          emailConfirm: true,
        ),
      );

      if (authResponse.user == null) {
        throw Exception('Erreur lors de la création du compte');
      }

      // Ajouter le profil dans la table profiles
      await _supabase.from('profiles').insert({
        'id': authResponse.user!.id,
        'nom_complet': name,
        'role': 'etudiant',
      });

      // Ajouter l'étudiant dans la table etudiants
      await _supabase.from('etudiants').insert({
        'id': authResponse.user!.id,
        'promotion': promotion,
        'filiere': filiere,
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de l\'étudiant: $e');
    }
  }

  static Future<void> deleteStudent(String studentId) async {
    try {
      // Supprimer l'étudiant de la table etudiants
      await _supabase
          .from('etudiants')
          .delete()
          .eq('id', studentId);

      // Supprimer le profil
      await _supabase
          .from('profiles')
          .delete()
          .eq('id', studentId);

      // Supprimer l'utilisateur de l'auth
      await _supabase.auth.admin.deleteUser(studentId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'étudiant: $e');
    }
  }

  // Méthodes pour les salles
  static Future<List<Map<String, dynamic>>> getRooms() async {
    try {
      final data = await _supabase
          .from('salles_de_cours')
          .select('*')
          .order('nom');
      
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Erreur lors du chargement des salles: $e');
    }
  }

  static Future<void> addRoom({
    required String name,
    required String? description,
    required double latitudeMin,
    required double latitudeMax,
    required double longitudeMin,
    required double longitudeMax,
  }) async {
    try {
      await _supabase.from('salles_de_cours').insert({
        'nom': name,
        'description': description,
        'latitude_min': latitudeMin,
        'latitude_max': latitudeMax,
        'longitude_min': longitudeMin,
        'longitude_max': longitudeMax,
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la salle: $e');
    }
  }

  static Future<void> deleteRoom(String roomId) async {
    try {
      await _supabase
          .from('salles_de_cours')
          .delete()
          .eq('id', roomId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la salle: $e');
    }
  }

  // Méthodes pour les cours
  static Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      final data = await _supabase
          .from('cours')
          .select('*, professeur:professeurs(id, profiles(nom_complet)), salle:salles_de_cours(nom)')
          .order('nom');
      
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Erreur lors du chargement des cours: $e');
    }
  }

  static Future<void> addCourse({
    required String name,
    required String time,
    required String? professorId,
    required String? roomId,
  }) async {
    try {
      await _supabase.from('cours').insert({
        'nom': name,
        'horaire': time,
        'professeur_id': professorId,
        'salle_id': roomId,
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du cours: $e');
    }
  }

  static Future<void> deleteCourse(String courseId) async {
    try {
      await _supabase
          .from('cours')
          .delete()
          .eq('id', courseId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du cours: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getAttendanceStats({
    required String promotion,
    String? filiere,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_attendance_stats_for_promo',
        params: {
          'promo_filter': promotion,
          'filiere_filter': filiere,
        },
      );
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching attendance stats: $e');
      throw Exception('Failed to load statistics.');
    }
  }

  // Méthodes pour l'historique de présence
  static Future<List<Map<String, dynamic>>> getProfessorSessions(String professorId) async {
    print('DataService: Appel de getProfessorSessions pour professorId: $professorId');
    try {
      final data = await _supabase
          .from('sessions_presence')
          .select('*, cours(nom, salles_de_cours(nom))')
          .eq('professeur_id', professorId)
          .order('date', ascending: false);
      print('DataService: Requête getProfessorSessions réussie. ${data.length} enregistrements trouvés.');
      print('DataService: Données brutes: $data');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('DataService: ERREUR dans getProfessorSessions: $e');
      throw Exception('Erreur lors de la récupération des sessions du professeur: $e');
    }
  }

  static Future<Map<String, dynamic>> getSessionDetails(String sessionId) async {
    try {
      // Récupérer les détails de la session
      final sessionData = await _supabase
          .from('sessions_presence')
          .select('*, cours(nom, salles_de_cours(nom))')
          .eq('id', sessionId)
          .single();

      // Récupérer les étudiants présents
      final presentStudentsData = await _supabase
          .from('presences')
          .select('etudiants(profiles(nom_complet)))')
          .eq('session_id', sessionId)
          .eq('statut', 'present');

      final presentStudents = presentStudentsData
          .map((p) => p['etudiants']['profiles']['nom_complet'] as String)
          .toList();

      return {
        'session': sessionData,
        'present_students': presentStudents,
      };

    } catch (e) {
      throw Exception('Erreur lors de la récupération des détails de la session: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getStudentAttendanceHistory(String studentId) async {
    try {
      final data = await _supabase
          .from('presences')
          .select('sessions_presence(*, cours(nom))')
          .eq('etudiant_id', studentId)
          .eq('statut', 'present')
          .order('created_at', ascending: false);

      // Extraire les données de session de la structure imbriquée
      final sessions = data
          .where((item) => item['sessions_presence'] != null)
          .map((item) => item['sessions_presence'] as Map<String, dynamic>)
          .toList();
          
      return sessions;

    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'historique de présence de l\'étudiant: $e');
    }
  }

  /// Récupère les séances de la semaine pour un professeur donné
  static Future<List<Map<String, dynamic>>> getProfessorWeekSessions(String professorId, DateTime startOfWeek, DateTime endOfWeek) async {
    try {
      final data = await _supabase
          .from('sessions_presence')
          .select('id, date, duree_minutes, cours: cours_id (nom, salle: salle_id (nom)), professeur_id')
          .eq('professeur_id', professorId)
          .gte('date', startOfWeek.toIso8601String())
          .lt('date', endOfWeek.toIso8601String())
          .order('date', ascending: true);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des séances de la semaine: $e');
    }
  }

  /// Crée une séance planifiée (admin)
  static Future<void> createPlannedSession({
    required String coursId,
    required String? professeurId,
    required String salleId,
    required DateTime date,
    required int dureeMinutes,
  }) async {
    try {
      await _supabase.from('sessions_presence').insert({
        'cours_id': coursId,
        'professeur_id': professeurId,
        'salle_id': salleId,
        'date': date.toIso8601String(),
        'duree_minutes': dureeMinutes,
        'est_active': false,
        'qr_code': null,
      });
    } catch (e) {
      throw Exception('Erreur lors de la création de la séance planifiée: $e');
    }
  }

  /// Active une séance planifiée (professeur génère QR code)
  static Future<String> activatePlannedSession(String sessionId) async {
    try {
      final qrCode = const Uuid().v4();
      await _supabase
          .from('sessions_presence')
          .update({
            'qr_code': qrCode,
            'est_active': true,
          })
          .eq('id', sessionId);
      return qrCode;
    } catch (e) {
      throw Exception('Erreur lors de l\'activation de la séance: $e');
    }
  }

  /// Récupère les séances planifiées d'un professeur (avec ou sans QR code)
  static Future<List<Map<String, dynamic>>> getProfessorPlannedSessions(String professorId, DateTime startOfWeek, DateTime endOfWeek) async {
    try {
      final data = await _supabase
          .from('sessions_presence')
          .select('id, date, duree_minutes, qr_code, est_active, cours: cours_id (nom, salle: salle_id (nom)), professeur_id')
          .eq('professeur_id', professorId)
          .gte('date', startOfWeek.toIso8601String())
          .lt('date', endOfWeek.toIso8601String())
          .order('date', ascending: true);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des séances planifiées: $e');
    }
  }

  /// Récupère les cours assignés à un professeur
  static Future<List<Map<String, dynamic>>> getProfessorCourses(String professorId) async {
    try {
      final data = await _supabase
          .from('cours')
          .select('*, salles_de_cours(*)')
          .eq('professeur_id', professorId)
          .order('nom');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des cours du professeur: $e');
    }
  }

  /// Crée une session avec QR code pour un cours
  static Future<void> createSessionWithQR({
    required String coursId,
    required String qrCode,
    required String professorId,
  }) async {
    try {
      if (professorId.isEmpty) {
        throw Exception('ID du professeur requis.');
      }

      // Récupérer les informations du cours
      final coursData = await _supabase
          .from('cours')
          .select('salle_id')
          .eq('id', coursId)
          .single();

      await _supabase.from('sessions_presence').insert({
        'cours_id': coursId,
        'professeur_id': professorId,
        'salle_id': coursData['salle_id'],
        'date': DateTime.now().toIso8601String(),
        'duree_minutes': 120, // Durée par défaut de 2 heures
        'est_active': true,
        'qr_code': qrCode,
      });
    } catch (e) {
      throw Exception('Erreur lors de la création de la session avec QR code: $e');
    }
  }

}
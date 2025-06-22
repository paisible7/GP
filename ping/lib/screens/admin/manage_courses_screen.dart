import 'package:flutter/material.dart';
import 'package:ping/theme/app_theme.dart';
import 'package:ping/core/data_service.dart';
import 'package:ping/widgets/skeleton_loader.dart';
import 'package:ping/screens/admin/planify_session_screen.dart';

class ManageCoursesScreen extends StatefulWidget {
  final String level;
  final String? filiere;

  const ManageCoursesScreen({
    Key? key,
    required this.level,
    this.filiere,
  }) : super(key: key);

  @override
  State<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseController = TextEditingController();
  final _professorController = TextEditingController();
  final _roomController = TextEditingController();
  final _timeController = TextEditingController();
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _professors = [];
  List<Map<String, dynamic>> _rooms = [];
  bool _isLoading = false;
  String? _selectedProfessorId;
  String? _selectedRoomId;

  // Ajout du champ de recherche
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _courseController.dispose();
    _professorController.dispose();
    _roomController.dispose();
    _timeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Charger les cours
      final coursesData = await DataService.getCourses();
      
      // Charger les professeurs
      final professorsData = await DataService.getProfessors();

      // Charger les salles
      final roomsData = await DataService.getRooms();

      setState(() {
        _courses = coursesData;
        _professors = professorsData;
        _rooms = roomsData;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des données: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await DataService.addCourse(
        name: _courseController.text.trim(),
        time: _timeController.text.trim(),
        professorId: _selectedProfessorId,
        roomId: _selectedRoomId,
      );

      // Réinitialiser le formulaire
      _courseController.clear();
      _timeController.clear();
      _selectedProfessorId = null;
      _selectedRoomId = null;

      // Recharger les données
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cours ajouté avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout du cours: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteCourse(String courseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce cours ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await DataService.deleteCourse(courseId);

      // Recharger les données
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cours supprimé avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String search = _searchController.text.trim().toLowerCase();
    List<Map<String, dynamic>> filteredCourses = _courses.where((course) {
      final nom = (course['nom'] ?? '').toString().toLowerCase();
      final prof = (course['professeur']?['profiles']?['nom_complet'] ?? '').toString().toLowerCase();
      return search.isEmpty || nom.contains(search) || prof.contains(search);
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les Cours'),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const SimpleListSkeleton()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Rechercher par nom de cours ou professeur...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                Card(
                  elevation: 4,
                  shadowColor: AppColor.primary.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ajouter un cours',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColor.primary,
                              fontFamily: 'poppins',
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _courseController,
                            decoration: InputDecoration(
                              labelText: 'Nom du cours',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.book),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer le nom du cours';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedProfessorId,
                            decoration: InputDecoration(
                              labelText: 'Professeur',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.person),
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Sélectionner un professeur'),
                              ),
                              ..._professors.map((professor) {
                                return DropdownMenuItem<String>(
                                  value: professor['id'],
                                  child: Text(professor['nom_complet']),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedProfessorId = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedRoomId,
                            decoration: InputDecoration(
                              labelText: 'Salle',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.class_),
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Sélectionner une salle'),
                              ),
                              ..._rooms.map((room) {
                                return DropdownMenuItem<String>(
                                  value: room['id'],
                                  child: Text(room['nom']),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedRoomId = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _timeController,
                            decoration: InputDecoration(
                              labelText: 'Horaire',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.access_time),
                              hintText: 'ex: 08:00',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer l\'horaire';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _addCourse,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Ajouter le cours',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'poppins',
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredCourses.isEmpty
                          ? const Center(
                              child: Text(
                                'Aucun cours trouvé',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredCourses.length,
                              itemBuilder: (context, index) {
                                final course = filteredCourses[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    title: Text(
                                      course['nom'] ?? 'Cours sans nom',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'poppins',
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (course['professeur'] != null)
                                          Text('Professeur: ${course['professeur']['profiles']['nom_complet']}'),
                                        if (course['salle'] != null)
                                          Text('Salle: ${course['salle']['nom']}'),
                                        Text('Horaire: ${course['horaire'] ?? 'Non défini'}'),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.event_available, color: Colors.blue),
                                          tooltip: 'Planifier une séance',
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PlanifySessionScreen(course: course),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteCourse(course['id']),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }
} 
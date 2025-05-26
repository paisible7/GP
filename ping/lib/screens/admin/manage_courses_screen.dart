import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ping/theme/app_theme.dart';

class ManageCoursesScreen extends StatefulWidget {
  const ManageCoursesScreen({Key? key}) : super(key: key);

  @override
  State<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _horaireController = TextEditingController();
  String? _selectedProfessorId;
  String? _selectedRoomId;
  bool _isLoading = false;
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _professors = [];
  List<Map<String, dynamic>> _rooms = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _horaireController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Charger les cours
      final coursesData = await Supabase.instance.client
          .from('cours')
          .select('*, professeur:profiles(nom_complet), salle:salles_de_cours(nom)')
          .order('nom');
      
      // Charger les professeurs
      final professorsData = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('role', 'professeur')
          .order('nom_complet');

      // Charger les salles
      final roomsData = await Supabase.instance.client
          .from('salles_de_cours')
          .select()
          .order('nom');

      setState(() {
        _courses = List<Map<String, dynamic>>.from(coursesData);
        _professors = List<Map<String, dynamic>>.from(professorsData);
        _rooms = List<Map<String, dynamic>>.from(roomsData);
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
    if (_selectedProfessorId == null || _selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un professeur et une salle')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.from('cours').insert({
        'nom': _nameController.text.trim(),
        'horaire': _horaireController.text.trim(),
        'professeur_id': _selectedProfessorId,
        'salle_id': _selectedRoomId,
      });

      // Réinitialiser le formulaire
      _nameController.clear();
      _horaireController.clear();
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
      await Supabase.instance.client
          .from('cours')
          .delete()
          .eq('id', courseId);

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

  void _showAddCourseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un cours'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du cours',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _horaireController,
                  decoration: const InputDecoration(
                    labelText: 'Horaire',
                    hintText: 'ex: Lundi 8h-10h',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un horaire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Professeur',
                  ),
                  value: _selectedProfessorId,
                  items: _professors.map((professor) {
                    return DropdownMenuItem<String>(
                      value: professor['id'] as String,
                      child: Text(professor['nom_complet'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProfessorId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Veuillez sélectionner un professeur';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Salle',
                  ),
                  value: _selectedRoomId,
                  items: _rooms.map((room) {
                    return DropdownMenuItem<String>(
                      value: room['id'] as String,
                      child: Text(room['nom'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRoomId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Veuillez sélectionner une salle';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addCourse();
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les Cours'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                final professor = course['professeur'] as Map<String, dynamic>?;
                final room = course['salle'] as Map<String, dynamic>?;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        course['nom']?[0] ?? '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: AppColor.primary,
                    ),
                    title: Text(course['nom'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Horaire: ${course['horaire']}'),
                        Text('Professeur: ${professor?['nom_complet'] ?? 'Non assigné'}'),
                        Text('Salle: ${room?['nom'] ?? 'Non assignée'}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteCourse(course['id']),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCourseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
} 
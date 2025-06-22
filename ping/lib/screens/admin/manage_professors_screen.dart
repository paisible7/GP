import 'package:flutter/material.dart';
import 'package:ping/theme/app_theme.dart';
import 'package:ping/core/data_service.dart';
import 'package:ping/widgets/skeleton_loader.dart';

class ManageProfessorsScreen extends StatefulWidget {
  const ManageProfessorsScreen({Key? key}) : super(key: key);

  @override
  State<ManageProfessorsScreen> createState() => _ManageProfessorsScreenState();
}

class _ManageProfessorsScreenState extends State<ManageProfessorsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _professors = [];

  // Ajout du champ de recherche
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfessors();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProfessors() async {
    setState(() => _isLoading = true);
    try {
      final data = await DataService.getProfessors();
      setState(() {
        _professors = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des professeurs: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addProfessor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await DataService.addProfessor(
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        password: _passwordController.text,
      );

      // Réinitialiser le formulaire
      _emailController.clear();
      _nameController.clear();
      _passwordController.clear();

      // Recharger la liste
      await _loadProfessors();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Professeur ajouté avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout du professeur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteProfessor(String professorId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce professeur ?'),
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
      await DataService.deleteProfessor(professorId);

      // Recharger la liste
      await _loadProfessors();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Professeur supprimé avec succès')),
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

  void _showAddProfessorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un professeur'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'exemple@esisalama.org',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un email';
                  }
                  if (!value.endsWith('@esisalama.org')) {
                    return 'Veuillez utiliser un email ESIS';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
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
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un mot de passe';
                  }
                  if (value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _addProfessor,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String search = _searchController.text.trim().toLowerCase();
    List<Map<String, dynamic>> filteredProfessors = _professors.where((prof) {
      final nom = (prof['nom_complet'] ?? '').toString().toLowerCase();
      final email = (prof['email'] ?? '').toString().toLowerCase();
      return search.isEmpty || nom.contains(search) || email.contains(search);
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les Professeurs'),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const SimpleListSkeleton()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Rechercher par nom ou email...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                Expanded(
                  child: filteredProfessors.isEmpty
                      ? const Center(child: Text('Aucun professeur trouvé'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredProfessors.length,
                          itemBuilder: (context, index) {
                            final professor = filteredProfessors[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    professor['nom_complet']?[0] ?? '?',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: AppColor.primary,
                                ),
                                title: Text(professor['nom_complet'] ?? ''),
                                subtitle: Text(professor['email'] ?? ''),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteProfessor(professor['id']),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProfessorDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
} 
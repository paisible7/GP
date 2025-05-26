import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ping/theme/app_theme.dart';

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
    super.dispose();
  }

  Future<void> _loadProfessors() async {
    setState(() => _isLoading = true);
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('role', 'professeur')
          .order('nom_complet');
      
      setState(() {
        _professors = List<Map<String, dynamic>>.from(data);
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
      // Créer l'utilisateur dans Supabase Auth
      final authResponse = await Supabase.instance.client.auth.admin.createUser(
        AdminUserAttributes(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          emailConfirm: true,
        ),
      );

      if (authResponse.user == null) {
        throw Exception('Erreur lors de la création du compte');
      }

      // Ajouter le profil dans la table profiles
      await Supabase.instance.client.from('profiles').insert({
        'id': authResponse.user!.id,
        'email': _emailController.text.trim(),
        'nom_complet': _nameController.text.trim(),
        'role': 'professeur',
      });

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
      // Supprimer le profil
      await Supabase.instance.client
          .from('profiles')
          .delete()
          .eq('id', professorId);

      // Supprimer l'utilisateur de l'auth
      await Supabase.instance.client.auth.admin.deleteUser(professorId);

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
            onPressed: () {
              Navigator.pop(context);
              _addProfessor();
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
        title: const Text('Gérer les Professeurs'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _professors.length,
              itemBuilder: (context, index) {
                final professor = _professors[index];
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProfessorDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
} 
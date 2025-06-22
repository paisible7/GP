import 'package:flutter/material.dart';
import 'package:ping/theme/app_theme.dart';
import 'package:ping/core/data_service.dart';
import 'package:ping/widgets/skeleton_loader.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({Key? key}) : super(key: key);

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _promotionController = TextEditingController();
  final _filiereController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _students = [];

  // Ajout des variables de filtre
  String? _selectedPromotion;
  String? _selectedFiliere;

  final List<String> _promotions = ['L1', 'L2', 'L3', 'L4'];
  final List<String> _filieres = ['GL', 'MSI', 'DSG', 'TLC', 'AS'];

  // Ajout du champ de recherche
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _promotionController.dispose();
    _filiereController.dispose();
    _passwordController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final data = await DataService.getStudents();
      setState(() {
        _students = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des étudiants: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await DataService.addStudent(
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        password: _passwordController.text,
        promotion: _promotionController.text.trim(),
        filiere: _filiereController.text.trim(),
      );

      // Réinitialiser le formulaire
      _emailController.clear();
      _nameController.clear();
      _promotionController.clear();
      _filiereController.clear();
      _passwordController.clear();

      // Recharger la liste
      await _loadStudents();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Étudiant ajouté avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout de l\'étudiant: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteStudent(String studentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cet étudiant ?'),
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
      await DataService.deleteStudent(studentId);

      // Recharger la liste
      await _loadStudents();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Étudiant supprimé avec succès')),
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

  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un étudiant'),
        content: SingleChildScrollView(
          child: Form(
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
                  controller: _promotionController,
                  decoration: const InputDecoration(
                    labelText: 'Promotion',
                    hintText: 'ex: L1, L2, L3, L4',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une promotion';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _filiereController,
                  decoration: const InputDecoration(
                    labelText: 'Filière',
                    hintText: 'ex: GL, MSI, DSG, TLC, AS',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une filière';
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _addStudent,
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
    // Filtrage des étudiants
    String search = _searchController.text.trim().toLowerCase();
    List<Map<String, dynamic>> filteredStudents = _students.where((student) {
      final etudiantData = student['etudiants'] as Map<String, dynamic>?;
      final promotion = etudiantData?['promotion'] ?? student['promotion'];
      final filiere = etudiantData?['filiere'] ?? student['filiere'];
      final matchPromotion = _selectedPromotion == null || _selectedPromotion == '' || promotion == _selectedPromotion;
      final matchFiliere = _selectedFiliere == null || _selectedFiliere == '' || filiere == _selectedFiliere;
      final nom = (student['nom_complet'] ?? '').toString().toLowerCase();
      final email = (student['email'] ?? '').toString().toLowerCase();
      final matchSearch = search.isEmpty || nom.contains(search) || email.contains(search);
      return matchPromotion && matchFiliere && matchSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les Étudiants'),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Dropdown pour la promotion
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedPromotion,
                          decoration: const InputDecoration(
                            labelText: 'Promotion',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem<String>(value: null, child: Text('Toutes les promotions')),
                            ..._promotions.map((promo) => DropdownMenuItem<String>(
                                  value: promo,
                                  child: Text(promo),
                                )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedPromotion = value;
                              // Si on change la promotion, on reset la filière si ce n'est pas L3/L4
                              if (_selectedPromotion != 'L3' && _selectedPromotion != 'L4') {
                                _selectedFiliere = null;
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Dropdown pour la filière (seulement pour L3/L4)
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedFiliere,
                          decoration: const InputDecoration(
                            labelText: 'Filière',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem<String>(value: null, child: Text('Toutes les filières')),
                            ..._filieres.map((filiere) => DropdownMenuItem<String>(
                                  value: filiere,
                                  child: Text(filiere),
                                )),
                          ],
                          onChanged: (_selectedPromotion == 'L3' || _selectedPromotion == 'L4')
                              ? (value) {
                                  setState(() {
                                    _selectedFiliere = value;
                                  });
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filteredStudents.isEmpty
                      ? const Center(child: Text('Aucun étudiant trouvé'))
                      : GridView.count(
                          crossAxisCount: MediaQuery.of(context).size.width >= 900 ? 4 : 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          padding: const EdgeInsets.all(16),
                          childAspectRatio: 1.2,
                          children: filteredStudents.map((student) {
                            final etudiantData = student['etudiants'] as Map<String, dynamic>?;
                            return Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          child: Text(
                                            student['nom_complet']?[0] ?? '?',
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: AppColor.primary,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            student['nom_complet'] ?? '',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteStudent(student['id']),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Email: ${student['email'] ?? 'Non défini'}', style: const TextStyle(fontSize: 13)),
                                    Text('Promotion:${etudiantData?['promotion'] ?? student['promotion'] ?? 'Non définie'}', style: const TextStyle(fontSize: 13)),
                                    Text('Filière: ${etudiantData?['filiere'] ?? student['filiere'] ?? 'Non définie'}', style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
} 
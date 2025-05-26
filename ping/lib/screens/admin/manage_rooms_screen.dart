import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ping/theme/app_theme.dart';

class ManageRoomsScreen extends StatefulWidget {
  const ManageRoomsScreen({Key? key}) : super(key: key);

  @override
  State<ManageRoomsScreen> createState() => _ManageRoomsScreenState();
}

class _ManageRoomsScreenState extends State<ManageRoomsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _latitudeMinController = TextEditingController();
  final _latitudeMaxController = TextEditingController();
  final _longitudeMinController = TextEditingController();
  final _longitudeMaxController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _rooms = [];

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latitudeMinController.dispose();
    _latitudeMaxController.dispose();
    _longitudeMinController.dispose();
    _longitudeMaxController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    setState(() => _isLoading = true);
    try {
      final data = await Supabase.instance.client
          .from('salles_de_cours')
          .select()
          .order('nom');
      
      setState(() {
        _rooms = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des salles: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.from('salles_de_cours').insert({
        'nom': _nameController.text.trim(),
        'latitude_min': double.parse(_latitudeMinController.text),
        'latitude_max': double.parse(_latitudeMaxController.text),
        'longitude_min': double.parse(_longitudeMinController.text),
        'longitude_max': double.parse(_longitudeMaxController.text),
      });

      // Réinitialiser le formulaire
      _nameController.clear();
      _latitudeMinController.clear();
      _latitudeMaxController.clear();
      _longitudeMinController.clear();
      _longitudeMaxController.clear();

      // Recharger la liste
      await _loadRooms();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Salle ajoutée avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout de la salle: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteRoom(String roomId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette salle ?'),
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
          .from('salles_de_cours')
          .delete()
          .eq('id', roomId);

      // Recharger la liste
      await _loadRooms();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Salle supprimée avec succès')),
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

  void _showAddRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une salle'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de la salle',
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
                  controller: _latitudeMinController,
                  decoration: const InputDecoration(
                    labelText: 'Latitude minimale',
                    hintText: 'ex: -4.123456',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une latitude';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Veuillez entrer un nombre valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _latitudeMaxController,
                  decoration: const InputDecoration(
                    labelText: 'Latitude maximale',
                    hintText: 'ex: -4.123456',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une latitude';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Veuillez entrer un nombre valide';
                    }
                    final min = double.tryParse(_latitudeMinController.text);
                    final max = double.tryParse(value);
                    if (min != null && max != null && max <= min) {
                      return 'La latitude max doit être supérieure à la latitude min';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _longitudeMinController,
                  decoration: const InputDecoration(
                    labelText: 'Longitude minimale',
                    hintText: 'ex: 15.123456',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une longitude';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Veuillez entrer un nombre valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _longitudeMaxController,
                  decoration: const InputDecoration(
                    labelText: 'Longitude maximale',
                    hintText: 'ex: 15.123456',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une longitude';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Veuillez entrer un nombre valide';
                    }
                    final min = double.tryParse(_longitudeMinController.text);
                    final max = double.tryParse(value);
                    if (min != null && max != null && max <= min) {
                      return 'La longitude max doit être supérieure à la longitude min';
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
              _addRoom();
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
        title: const Text('Gérer les Salles'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                final room = _rooms[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        room['nom']?[0] ?? '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: AppColor.primary,
                    ),
                    title: Text(room['nom'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Latitude: ${room['latitude_min']} - ${room['latitude_max']}'),
                        Text('Longitude: ${room['longitude_min']} - ${room['longitude_max']}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteRoom(room['id']),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRoomDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ping/core/data_service.dart';
import 'package:ping/theme/app_theme.dart';

class PlanifySessionScreen extends StatefulWidget {
  final Map<String, dynamic> course;
  const PlanifySessionScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<PlanifySessionScreen> createState() => _PlanifySessionScreenState();
}

class _PlanifySessionScreenState extends State<PlanifySessionScreen> {
  String? _selectedDay;
  String? _selectedSlot;
  String? _selectedRoomId;
  List<Map<String, dynamic>> _rooms = [];
  bool _isLoading = false;

  final List<String> _days = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'
  ];
  final Map<String, TimeOfDay> _slotStart = {
    'Matin (8h-12h)': TimeOfDay(hour: 8, minute: 0),
    'Après-midi (13h30-17h30)': TimeOfDay(hour: 13, minute: 30),
  };
  final Map<String, int> _slotDuration = {
    'Matin (8h-12h)': 240,
    'Après-midi (13h30-17h30)': 240,
  };

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    setState(() => _isLoading = true);
    try {
      final rooms = await DataService.getRooms();
      setState(() {
        _rooms = rooms;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des salles : $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _planifySession() async {
    if (_selectedDay == null || _selectedSlot == null || _selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      // Calculer la date de la prochaine occurrence du jour choisi
      final now = DateTime.now();
      int selectedWeekday = _days.indexOf(_selectedDay!) + 1; // DateTime weekday: 1=lundi
      DateTime nextDate = now.add(Duration(days: (selectedWeekday - now.weekday + 7) % 7));
      final startTime = _slotStart[_selectedSlot!]!;
      final dateTime = DateTime(nextDate.year, nextDate.month, nextDate.day, startTime.hour, startTime.minute);
      final duration = _slotDuration[_selectedSlot!]!;
      await DataService.createPlannedSession(
        coursId: widget.course['id'],
        professeurId: widget.course['professeur']?['id'],
        salleId: _selectedRoomId!,
        date: dateTime,
        dureeMinutes: duration,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Séance planifiée avec succès !')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la planification : $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Planifier une séance'),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Cours : ${widget.course['nom']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedDay,
                    decoration: const InputDecoration(labelText: 'Jour de la semaine'),
                    items: _days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (v) => setState(() => _selectedDay = v),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedSlot,
                    decoration: const InputDecoration(labelText: 'Créneau'),
                    items: _slotStart.keys.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setState(() => _selectedSlot = v),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedRoomId,
                    decoration: const InputDecoration(labelText: 'Salle'),
                    items: _rooms.map((room) => DropdownMenuItem<String>(
                      value: room['id'] as String,
                      child: Text(room['nom'] as String),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedRoomId = v),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _planifySession,
                    child: const Text('Planifier la séance'),
                  ),
                ],
              ),
            ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:ping/core/data_service.dart';
import 'package:ping/theme/app_theme.dart';
import 'package:ping/widgets/skeleton_loader.dart';

class SessionDetailsScreen extends StatefulWidget {
  final String sessionId;
  const SessionDetailsScreen({super.key, required this.sessionId});

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
  late Future<Map<String, dynamic>> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = DataService.getSessionDetails(widget.sessionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la Session'),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SessionDetailsSkeleton();
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Aucun détail trouvé.'));
          }

          final details = snapshot.data!;
          final session = details['session'];
          final presentStudents = details['present_students'] as List<String>;
          
          final courseName = session['cours']?['nom'] ?? 'N/A';
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(courseName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('${presentStudents.length} étudiant(s) présent(s)', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _buildStudentList(presentStudents, Icons.check_circle, Colors.green),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStudentList(List<String> students, IconData icon, Color color) {
    if (students.isEmpty) {
      return const Center(child: Text('Aucun étudiant dans cette liste.'));
    }
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(icon, color: color),
          title: Text(students[index]),
        );
      },
    );
  }
} 
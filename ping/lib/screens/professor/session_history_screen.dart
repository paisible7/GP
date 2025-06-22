import 'package:flutter/material.dart';
import 'package:ping/core/data_service.dart';
import 'package:ping/providers/user_provider.dart';
import 'package:ping/screens/professor/session_details_screen.dart';
import 'package:ping/theme/app_theme.dart';
import 'package:ping/widgets/skeleton_loader.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class SessionHistoryScreen extends StatefulWidget {
  const SessionHistoryScreen({super.key});

  @override
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> {
  late Future<List<Map<String, dynamic>>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    print('SessionHistoryScreen: initState pour le professeur ID: ${userProvider.userId}');
    if (userProvider.userId == null) {
      print('ERREUR: userId est null. Impossible de charger les sessions.');
    }
    _sessionsFuture = DataService.getProfessorSessions(userProvider.userId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Sessions'),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SessionHistorySkeleton();
          } else if (snapshot.hasError) {
            print('SessionHistoryScreen FutureBuilder ERREUR: ${snapshot.error}');
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print('SessionHistoryScreen FutureBuilder: Aucune donnée ou données vides. Données: ${snapshot.data}');
            return const Center(child: Text('Aucune session trouvée.'));
          }

          final sessions = snapshot.data!;
          print('SessionHistoryScreen FutureBuilder: ${sessions.length} sessions trouvées.');

          // Group sessions by course name
          final Map<String, List<Map<String, dynamic>>> groupedSessions = {};
          for (var session in sessions) {
            final courseName = session['cours']?['nom'] ?? 'Cours inconnu';
            if (groupedSessions[courseName] == null) {
              groupedSessions[courseName] = [];
            }
            groupedSessions[courseName]!.add(session);
          }
          
          final courseNames = groupedSessions.keys.toList();

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: courseNames.length,
            itemBuilder: (context, index) {
              final courseName = courseNames[index];
              final courseSessions = groupedSessions[courseName]!;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      courseName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: courseSessions.length,
                    itemBuilder: (context, sessionIndex) {
                      final session = courseSessions[sessionIndex];
                      final roomName = session['cours']?['salles_de_cours']?['nom'] ?? 'N/A';
                      final date = DateTime.parse(session['date']);
                      final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);
                      
                      return ListTile(
                        title: Text('Session du $formattedDate', style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(roomName),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SessionDetailsScreen(sessionId: session['id']),
                            ),
                          );
                        },
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
} 
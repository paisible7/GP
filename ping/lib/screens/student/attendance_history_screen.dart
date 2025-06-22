import 'package:flutter/material.dart';
import 'package:ping/core/data_service.dart';
import 'package:ping/providers/user_provider.dart';
import 'package:ping/theme/app_theme.dart';
import 'package:ping/widgets/skeleton_loader.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  late Future<List<Map<String, dynamic>>> _attendanceFuture;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _attendanceFuture = DataService.getStudentAttendanceHistory(userProvider.userId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Historique de Présence'),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _attendanceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AttendanceHistorySkeleton();
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune présence enregistrée.'));
          }

          final attendances = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: attendances.length,
            itemBuilder: (context, index) {
              final attendance = attendances[index];
              final courseName = attendance['cours']?['nom_cours'] ?? 'N/A';
              final date = DateTime.parse(attendance['date']);
              final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(courseName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(formattedDate),
                  trailing: const Text('Présent', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ping/core/data_service.dart';
import 'package:ping/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ping/theme/app_theme.dart';
import 'package:qr/qr.dart';

class CalendrierScreen extends StatefulWidget {
  const CalendrierScreen({Key? key}) : super(key: key);

  @override
  State<CalendrierScreen> createState() => _CalendrierScreenState();
}

class _CalendrierScreenState extends State<CalendrierScreen> {
  late Future<List<Map<String, dynamic>>> _sessionsFuture;
  late Future<List<Map<String, dynamic>>> _coursesFuture;
  late Future<List<Map<String, dynamic>>> _allHorairesFuture;
  Map<DateTime, List<Map<String, dynamic>>> _sessionsByDay = {};
  Map<String, int> _courseTotalHours = {}; // cours_id -> volume horaire total
  Map<String, double> _coursePlannedHours = {}; // cours_id -> heures déjà planifiées
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7)); // Lundi suivant 00:00:00
    print('[CalendrierScreen] Chargement des horaires pour userId=${userProvider.userId}, semaine du $startOfWeek au $endOfWeek');
    _sessionsFuture = DataService.getProfessorHorairesForWeek(
      userProvider.userId!,
      startOfWeek,
      endOfWeek,
    );
    _coursesFuture = DataService.getProfessorCourses(userProvider.userId!);
    _allHorairesFuture = DataService.getAllProfessorHoraires(userProvider.userId!);
    _selectedDay = now;
  }

  List<Map<String, dynamic>> _getSessionsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    final sessions = _sessionsByDay[key] ?? [];
    print('[CalendrierScreen] Horaires pour le $key : ${sessions.length}');
    return sessions;
  }

  void _computeCourseHours(List<Map<String, dynamic>> allHoraires, List<Map<String, dynamic>> courses) {
    _courseTotalHours.clear();
    _coursePlannedHours.clear();
    for (var course in courses) {
      final id = course['id']?.toString();
      final volume = course['volume_horaire'] is int ? course['volume_horaire'] : int.tryParse(course['volume_horaire']?.toString() ?? '0') ?? 0;
      if (id != null) {
        _courseTotalHours[id] = volume;
        _coursePlannedHours[id] = 0.0;
      }
    }
    for (var horaire in allHoraires) {
      final coursId = horaire['cours_id']?.toString();
      final duree = horaire['duree_minutes'] is int ? horaire['duree_minutes'] : int.tryParse(horaire['duree_minutes']?.toString() ?? '0') ?? 0;
      if (coursId != null && _coursePlannedHours.containsKey(coursId)) {
        _coursePlannedHours[coursId] = (_coursePlannedHours[coursId] ?? 0) + duree / 60.0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier de la semaine'),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          print('[CalendrierScreen] FutureBuilder - état: [${snapshot.connectionState}]');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('[CalendrierScreen] Erreur FutureBuilder : [${snapshot.error}]');
            return Center(child: Text('Erreur : [${snapshot.error}]'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print('[CalendrierScreen] Aucun horaire prévu cette semaine.');
            return const Center(child: Text('Aucun horaire prévu cette semaine.'));
          }

          final horaires = snapshot.data!;
          print('[CalendrierScreen] Nombre total d\'horaires récupérés : ${horaires.length}');
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _coursesFuture,
            builder: (context, courseSnap) {
              if (courseSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (courseSnap.hasError) {
                return Center(child: Text('Erreur chargement cours : ${courseSnap.error}'));
              } else if (!courseSnap.hasData) {
                return const Center(child: Text('Aucun cours trouvé.'));
              }
              final courses = courseSnap.data!;
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _allHorairesFuture,
                builder: (context, allHorairesSnap) {
                  if (allHorairesSnap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (allHorairesSnap.hasError) {
                    return Center(child: Text('Erreur chargement horaires globaux : ${allHorairesSnap.error}'));
                  } else if (!allHorairesSnap.hasData) {
                    return const Center(child: Text('Aucun horaire global trouvé.'));
                  }
                  final allHoraires = allHorairesSnap.data!;
                  _computeCourseHours(allHoraires, courses);
                  // Trier les horaires par date
                  horaires.sort((a, b) {
                    final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(1970);
                    final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(1970);
                    return dateA.compareTo(dateB);
                  });
                  // Grouper les horaires par jour (clé = DateTime sans heure)
                  _sessionsByDay.clear();
                  for (var horaire in horaires) {
                    try {
                      final date = DateTime.parse(horaire['date'] ?? '');
                      final key = DateTime(date.year, date.month, date.day);
                      _sessionsByDay.putIfAbsent(key, () => []).add(horaire);
                    } catch (e) {
                      print('[CalendrierScreen] Erreur lors du parsing de l\'horaire : $horaire\nErreur: $e');
                    }
                  }

                  return Column(
                    children: [
                      TableCalendar(
                        firstDay: DateTime.now().subtract(const Duration(days: 365)),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        focusedDay: _focusedDay,
                        calendarFormat: CalendarFormat.week,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                            print('[CalendrierScreen] Jour sélectionné : $_selectedDay');
                          });
                        },
                        eventLoader: (day) => _getSessionsForDay(day),
                        calendarStyle: const CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: AppColor.secondary,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: AppColor.secondary,
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: BoxDecoration(
                            color: AppColor.primary,
                            shape: BoxShape.circle,
                          ),
                          markersMaxCount: 2,
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        locale: 'fr_FR',
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _getSessionsForDay(_selectedDay ?? DateTime.now()).isEmpty
                            ? const Center(child: Text('Aucun horaire ce jour.'))
                            : ListView(
                                children: _getSessionsForDay(_selectedDay ?? DateTime.now()).map((horaire) {
                                  final coursNom = horaire['cours']?['nom'] ?? 'Cours inconnu';
                                  final salleNom = horaire['salle']?['nom'] ?? 'N/A';
                                  final dateStr = horaire['date'] ?? '';
                                  DateTime? date;
                                  try {
                                    date = DateTime.parse(dateStr);
                                  } catch (e) {
                                    print('[CalendrierScreen] Erreur parsing date: $dateStr');
                                  }
                                  final heure = date != null ? DateFormat('HH:mm').format(date) : '--:--';
                                  final duree = horaire['duree_minutes'] != null ? (horaire['duree_minutes'] / 60).toStringAsFixed(1) : '?';
                                  final coursId = horaire['cours_id']?.toString();
                                  final total = coursId != null && _courseTotalHours.containsKey(coursId) ? _courseTotalHours[coursId] : null;
                                  final volumeHoraire = horaire['cours']?['volume_horaire'];
                                  // Calcul du volume restant APRÈS cette séance
                                  double sommeAvant = 0;
                                  if (coursId != null && date != null) {
                                    // On prend toutes les séances du même cours, triées par date
                                    final allSeances = allHoraires.where((h) => h['cours_id']?.toString() == coursId).toList();
                                    allSeances.sort((a, b) {
                                      final dA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(1970);
                                      final dB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(1970);
                                      return dA.compareTo(dB);
                                    });
                                    for (var s in allSeances) {
                                      final d = DateTime.tryParse(s['date'] ?? '');
                                      final dureeS = s['duree_minutes'] is int ? s['duree_minutes'] : int.tryParse(s['duree_minutes']?.toString() ?? '0') ?? 0;
                                      if (d != null && (d.isBefore(date) || d.isAtSameMomentAs(date))) {
                                        sommeAvant += dureeS / 60.0;
                                      }
                                      if (d != null && d.isAtSameMomentAs(date)) {
                                        // Si c'est la séance courante, on s'arrête après l'avoir ajoutée
                                        break;
                                      }
                                    }
                                  }
                                  final restantApres = (total != null) ? (total - sommeAvant).clamp(0, total) : null;
                                  return Card(
                                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: ListTile(
                                      leading: Icon(Icons.event, color: AppColor.primary),
                                      title: Text(
                                        coursNom,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Heure : $heure', style: const TextStyle(fontSize: 16)),
                                          Text('Salle : $salleNom', style: const TextStyle(fontSize: 16)),
                                          Text('Durée : $duree h', style: const TextStyle(fontSize: 16)),
                                          if (restantApres != null && total != null)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 6.0),
                                              child: Text(
                                                'Volume horaire restant après cette séance : ${restantApres.toStringAsFixed(1)} h / $total h',
                                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                              ),
                                            ),
                                          if (volumeHoraire != null)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2.0),
                                              child: Text(
                                                'Volume horaire total du cours : $volumeHoraire h',
                                                style: const TextStyle(fontSize: 16, color: Colors.black87),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class QrImageWidget extends StatelessWidget {
  final String data;
  final double size;

  const QrImageWidget({
    Key? key,
    required this.data,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final qrCode = QrCode(4, QrErrorCorrectLevel.L)..addData(data);

    return CustomPaint(
      size: Size(size, size),
      painter: QrPainter(
        qrImage: QrImage(qrCode),
        color: Colors.black,
      ),
    );
  }
}

class QrPainter extends CustomPainter {
  final QrImage qrImage;
  final Color color;

  QrPainter({
    required this.qrImage,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    final moduleSize = size.width / qrImage.moduleCount;

    for (var x = 0; x < qrImage.moduleCount; x++) {
      for (var y = 0; y < qrImage.moduleCount; y++) {
        if (qrImage.isDark(y, x)) {
          canvas.drawRect(
            Rect.fromLTWH(x * moduleSize, y * moduleSize, moduleSize, moduleSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant QrPainter oldDelegate) {
    return oldDelegate.qrImage != qrImage || oldDelegate.color != color;
  }
} 
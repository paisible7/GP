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
  Map<DateTime, List<Map<String, dynamic>>> _sessionsByDay = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Lundi
    final endOfWeek = startOfWeek.add(const Duration(days: 7)); // Lundi suivant
    _sessionsFuture = DataService.getProfessorPlannedSessions(
      userProvider.userId!,
      startOfWeek,
      endOfWeek,
    );
    _selectedDay = now;
  }

  List<Map<String, dynamic>> _getSessionsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _sessionsByDay[key] ?? [];
  }

  Future<void> _activateSession(String sessionId) async {
    try {
      final qrCode = await DataService.activatePlannedSession(sessionId);
      if (mounted) {
        _showQRCodeDialog(qrCode);
        // Recharger les données
        setState(() {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          final now = DateTime.now();
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 7));
          _sessionsFuture = DataService.getProfessorPlannedSessions(
            userProvider.userId!,
            startOfWeek,
            endOfWeek,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'activation: $e')),
        );
      }
    }
  }

  void _showQRCodeDialog(String qrCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code généré'),
        content: SizedBox(
          width: 250,
          height: 250,
          child: Center(
            child: QrImageWidget(data: qrCode, size: 200),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier de la semaine'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune séance prévue cette semaine.'));
          }

          final sessions = snapshot.data!;
          // Grouper les séances par jour (clé = DateTime sans heure)
          _sessionsByDay.clear();
          for (var session in sessions) {
            final date = DateTime.parse(session['date']);
            final key = DateTime(date.year, date.month, date.day);
            _sessionsByDay.putIfAbsent(key, () => []).add(session);
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
                    ? const Center(child: Text('Aucune séance ce jour.'))
                    : ListView(
                        children: _getSessionsForDay(_selectedDay ?? DateTime.now()).map((session) {
                          final isActive = session['est_active'] == true;
                          final hasQRCode = session['qr_code'] != null;
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              title: Text(session['cours']['nom'] ?? 'Cours inconnu'),
                              subtitle: Text(
                                'Heure : ${DateFormat('HH:mm').format(DateTime.parse(session['date']))}\n'
                                'Salle : ${session['cours']['salle']?['nom'] ?? 'N/A'}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${(session['duree_minutes'] / 60).toStringAsFixed(1)} h',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  if (!isActive)
                                    IconButton(
                                      icon: const Icon(Icons.play_arrow, color: Colors.green),
                                      tooltip: 'Démarrer la séance',
                                      onPressed: () => _activateSession(session['id']),
                                    )
                                  else if (hasQRCode)
                                    const Icon(Icons.check_circle, color: Colors.green),
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
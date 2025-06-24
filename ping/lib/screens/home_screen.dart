import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ping/providers/navigation_provider.dart';
import 'package:ping/providers/user_provider.dart';
import 'package:ping/screens/scan_screen.dart';
import 'package:ping/screens/profile_screen.dart';
import 'package:ping/screens/admin/admin_dashboard.dart';
import 'package:ping/screens/professor/session_history_screen.dart';
import 'package:ping/screens/student/attendance_history_screen.dart';
import 'package:ping/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:qr/qr.dart';

import '../widgets/skeleton_loader.dart';
import 'professor/calendrier_screen.dart';
import 'professor/generate_qr_screen.dart';
import '../core/data_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Widget>? _pages;
  late final NavigationProvider _navigationProvider;

  @override
  void initState() {
    super.initState();
    _navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    _initializePages();
    _navigationProvider.setIndex(0);
  }

  void _initializePages() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // Pour les professeurs et étudiants, on utilise la page d'accueil
    userProvider.userRole == 'admin' ?
    (_pages = [
      const AdminDashboard(),
    ]):
    (  _pages = [
    const _HomePage(),
    const ProfileScreen(showBottomNav: false),
    ]);

  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    // Vérifier si les pages doivent être mises à jour
    if (_pages == null || 
        (userProvider.userRole == 'admin' && _pages![0] is! AdminDashboard) ||
        ((userProvider.userRole == 'professeur' || userProvider.userRole == 'etudiant') && _pages![0] is! _HomePage)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _initializePages();
            _navigationProvider.setIndex(0);
          });
        }
      });
    }

    if (_pages == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: navigationProvider.currentIndex,
        children: _pages!,
      ),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  List<Map<String, dynamic>> _coursList = [];
  List<Map<String, dynamic>> _horairesDuJour = [];
  Map<String, Map<String, dynamic>> _sessionsByHoraireId = {};
  bool _isCoursesLoading = false;
  bool _coursesHaveBeenFetched = false;
  String? _selectedSessionId;
  bool _isGeneratingQR = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchCours() async {
    if (!mounted) return;
    setState(() {
      _isCoursesLoading = true;
    });
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté.');
      }

      final data = await Supabase.instance.client
          .from('cours')
          .select('*, salles_de_cours(*)')
          .eq('professeur_id', userId);

      if (mounted) {
        setState(() {
          _coursList = List<Map<String, dynamic>>.from(data as List);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erreur lors du chargement des cours: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCoursesLoading = false;
        });
      }
    }
  }

  Future<void> _fetchHorairesDuJour() async {
    if (!mounted) return;
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        print('[fetchHorairesDuJour] Utilisateur non connecté.');
        throw Exception('Utilisateur non connecté.');
      }
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      print('[fetchHorairesDuJour] userId=$userId, startOfDay=$startOfDay, endOfDay=$endOfDay');
      // Récupérer les horaires du jour
      final horaires = await Supabase.instance.client
        .from('horaires')
        .select('id, date, duree_minutes, cours: cours_id(nom), salle: salle_id(nom), professeur_id')
        .eq('professeur_id', userId)
        .gte('date', startOfDay.toIso8601String())
        .lt('date', endOfDay.toIso8601String());
      print('[fetchHorairesDuJour] horaires=$horaires');
      // Récupérer les sessions_presence pour ces horaires
      final horaireIds = (horaires as List).map((h) => h['id'] as String).toList();
      Map<String, Map<String, dynamic>> sessionsMap = {};
      if (horaireIds.isNotEmpty) {
        final sessions = await Supabase.instance.client
          .from('sessions_presence')
          .select('id, qr_code, est_active, horaire_id')
          .inFilter('horaire_id', horaireIds);
        print('[fetchHorairesDuJour] sessions_presence=$sessions');
        for (var s in sessions) {
          sessionsMap[s['horaire_id']] = s;
        }
      }
      if (mounted) {
        setState(() {
          _horairesDuJour = List<Map<String, dynamic>>.from(horaires as List);
          _horairesDuJour.sort((a, b) {
            final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(1970);
            final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(1970);
            return dateA.compareTo(dateB);
          });
          _sessionsByHoraireId = sessionsMap;
        });
        print('[fetchHorairesDuJour] _horairesDuJour=${_horairesDuJour.length} éléments');
      }
    } catch (e, stack) {
      print('[fetchHorairesDuJour] ERREUR: $e');
      print(stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erreur lors du chargement des horaires du jour: $e')));
      }
    }
  }

  void _selectSession(String sessionId) {
    setState(() {
      _selectedSessionId = sessionId;
    });
  }

  Future<void> _generateQRCode() async {
    if (_selectedSessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez d\'abord sélectionner un cours du jour')),
      );
      return;
    }

    setState(() {
      _isGeneratingQR = true;
    });

    try {
      final qrCode = const Uuid().v4();
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté.');
      }
      // On retrouve l'horaire sélectionné
      final horaire = _horairesDuJour.firstWhere((h) => h['id'] == _selectedSessionId);
      // Créer une nouvelle session_presence avec le QR code
      await Supabase.instance.client
        .from('sessions_presence')
        .insert({
          'horaire_id': horaire['id'],
          'qr_code': qrCode,
          'est_active': true,
        });

      if (mounted) {
        _showQRCodeDialog(qrCode);
        _fetchHorairesDuJour();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la génération du QR code: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingQR = false;
        });
      }
    }
  }

  void _showQRCodeDialog(String qrCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code généré avec succès'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Vos étudiants peuvent maintenant scanner ce QR code pour enregistrer leur présence.'),
            const SizedBox(height: 20),
            SizedBox(
              width: 250,
              height: 250,
              child: Center(
                child: QrImageWidget(data: qrCode, size: 200),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Code: $qrCode',
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              textAlign: TextAlign.center,
            ),
          ],
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
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.userRole == 'professeur' && !_coursesHaveBeenFetched) {
      _coursesHaveBeenFetched = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fetchCours();
          _fetchHorairesDuJour();
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100.0,
        title: const Text('Accueil',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            )),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        actions: [
          if (userProvider.userRole == 'professeur')
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.white),
              tooltip: 'Voir le calendrier',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CalendrierScreen(),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // TODO: Implémenter les notifications
            },
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profil');
              },
              icon: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bienvenue ${userProvider.userName}',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (userProvider.userRole == 'professeur') ...[
              // Section des cours du jour (à partir des horaires)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.today, color: AppColor.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Cours du jour',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColor.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_horairesDuJour.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "Aucun cours prévu aujourd'hui.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _horairesDuJour.length,
                          itemBuilder: (context, index) {
                            final horaire = _horairesDuJour[index];
                            final cours = horaire['cours'] as Map<String, dynamic>?;
                            final date = DateTime.parse(horaire['date'] ?? '');
                            final session = _sessionsByHoraireId[horaire['id']];
                            final isActive = session != null && session['est_active'] == true;
                            final isSelected = _selectedSessionId == horaire['id'];
                            return GestureDetector(
                              onTap: () => _selectSession(horaire['id']),
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: isSelected ? AppColor.primary.withOpacity(0.15) : (isActive ? Colors.green.shade50 : null),
                                child: ListTile(
                                  leading: Icon(
                                    isActive ? Icons.play_circle : Icons.schedule,
                                    color: isActive ? Colors.green : Colors.orange,
                                  ),
                                  title: Text(
                                    cours?['nom'] ?? 'Cours inconnu',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Heure: ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'),
                                      if (horaire['salle'] != null)
                                        Text('Salle: ${horaire['salle']['nom']}'),
                                      Text(
                                        isActive ? 'Session active' : 'Session planifiée',
                                        style: TextStyle(
                                          color: isActive ? Colors.green : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: isSelected
                                      ? const Icon(Icons.check_circle, color: AppColor.primary)
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SessionHistoryScreen()),
                  );
                },
                child: const Text('Voir l\'historique de mes sessions'),
              ),
              // Section de tous les cours assignés (affichage simple, sans sélection)
              if (_isCoursesLoading)
                const Center(child: CircularProgressIndicator())
              else if (_coursList.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Vous n'avez aucun cours assigné pour le moment.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.school, color: AppColor.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Tous vos cours assignés',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColor.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 3 / 2,
                          ),
                          itemCount: _coursList.length,
                          itemBuilder: (context, index) {
                            final cours = _coursList[index];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    cours['nom'] as String,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ] else if (userProvider.userRole == 'etudiant') ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const AttendanceHistoryScreen()),
                  );
                },
                child: const Text('Voir mon historique de présence'),
              ),
            ]
          ],
        ),
      ),
      floatingActionButton: userProvider.userRole == 'professeur'
          ? FloatingActionButton.extended(
              onPressed: (_isGeneratingQR || _selectedSessionId == null) ? null : _generateQRCode,
              icon: _isGeneratingQR 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.qr_code, color: Colors.white),
              label: Text(
                _isGeneratingQR ? 'Génération...' : 'Générer QR Code',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)
              ),
              backgroundColor: AppColor.primary,
            )
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const QRScannerScreen()),
                );
              },
              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
              label: const Text('Scanner QR',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              backgroundColor: AppColor.primary,
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

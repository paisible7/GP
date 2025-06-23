import 'package:flutter/material.dart';
import 'package:ping/models/statistic_model.dart';
import 'package:ping/theme/app_theme.dart';
import 'package:ping/core/data_service.dart';
import 'package:ping/widgets/skeleton_loader.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String? _selectedPromotion;
  String? _selectedFiliere;
  bool _isLoading = false;
  List<CourseStatistic> _stats = [];

  final List<String> _promotions = ['L1', 'L2', 'L3', 'L4'];
  final List<String> _filieres = ['GL', 'MSI', 'DSG', 'TLC', 'AS'];

  Future<void> _fetchStatistics() async {
    if (_selectedPromotion == null) {
      setState(() => _stats = []);
      return;
    }
    setState(() => _isLoading = true);
    try {
      print('[DEBUG] Chargement des stats pour promotion=$_selectedPromotion, filiere=$_selectedFiliere');
      final rawData = await DataService.getAttendanceStats(
        promotion: _selectedPromotion!,
        filiere: _selectedFiliere,
      );
      print('[DEBUG] Données brutes reçues :');
      print(rawData);

      // Grouper les données par cours
      final Map<String, CourseStatistic> courseStatsMap = {};
      for (var row in rawData) {
        print('[DEBUG] Traitement de la ligne :');
        print(row);
        final courseId = row['cours_id'];
        final courseName = row['cours_nom'];
        final volumeHoraire = (row['volume_horaire'] as int?) ?? 0;

        final studentStat = StudentStatistic(
          studentId: row['etudiant_id'],
          studentName: row['etudiant_nom'],
          heuresPresences: (row['heures_presences'] as num?)?.toDouble() ?? 0.0,
          tauxPresence: (row['taux_presence'] as num?)?.toDouble() ?? 0.0,
          tauxAbsence: (row['taux_absence'] as num?)?.toDouble() ?? 0.0,
          alerte25: row['alerte_25'] == true,
        );
        print('[DEBUG] StudentStat créé : $studentStat');

        if (courseStatsMap.containsKey(courseId)) {
          courseStatsMap[courseId]!.studentStats.add(studentStat);
        } else {
          courseStatsMap[courseId] = CourseStatistic(
            courseId: courseId,
            courseName: courseName,
            volumeHoraire: volumeHoraire,
            studentStats: [studentStat],
          );
        }
      }
      setState(() {
        _stats = courseStatsMap.values.toList();
      });
      print('[DEBUG] Statistiques finales prêtes à afficher :');
      print(_stats);
    } catch (e, stack) {
      print('[ERREUR] lors du chargement des stats : $e');
      print(stack);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des stats: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Statistiques de Présence'),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const StatsCardSkeleton()
                : _selectedPromotion == null
                    ? _buildEmptyState('📊', 'Sélectionnez une promotion pour voir les statistiques.')
                    : _stats.isEmpty
                        ? _buildEmptyState('📭', 'Aucune donnée trouvée pour cette sélection.')
                        : _buildStatsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 16, color: Colors.grey[600]), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(
        color: AppColor.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildDropdown(_selectedPromotion, _promotions, 'Promotion', (value) {
            setState(() {
              _selectedPromotion = value;
              _selectedFiliere = null;
            });
            _fetchStatistics();
          })),
          const SizedBox(width: 16),
          Expanded(child: _buildDropdown(_selectedFiliere, _filieres, 'Filière',
            (_selectedPromotion == 'L3' || _selectedPromotion == 'L4')
              ? (value) {
                  setState(() { _selectedFiliere = value; });
                  _fetchStatistics();
                }
              : null
          )),
        ],
      ),
    );
  }

  Widget _buildDropdown(String? value, List<String> items, String label, Function(String?)? onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white, width: 2)),
      ),
      dropdownColor: AppColor.primary.withRed(100),
      iconEnabledColor: Colors.white,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildStatsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _stats.length,
      itemBuilder: (context, index) {
        final courseStat = _stats[index];
        return _buildCourseStatCard(courseStat);
      },
    );
  }

  Widget _buildCourseStatCard(CourseStatistic courseStat) {
    double averageAbsenceRate = courseStat.studentStats.isNotEmpty
        ? courseStat.studentStats.map((s) => s.tauxAbsence).reduce((a, b) => a + b) / courseStat.studentStats.length
        : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          title: Text(courseStat.courseName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColor.primary)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text('${courseStat.studentStats.length} étudiant(s) • Moyenne d\'absence: ${averageAbsenceRate.toStringAsFixed(1)}% • Volume horaire: ${courseStat.volumeHoraire}h'),
          ),
          children: [
            Container(
              color: Colors.grey.withOpacity(0.05),
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: courseStat.studentStats.map((stat) => _buildStudentStatCard(stat)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentStatCard(StudentStatistic stat) {
    final hasHighAbsence = stat.alerte25;
    final color = hasHighAbsence ? Colors.orange.shade800 : AppColor.primary;

    return SizedBox(
      width: 180,
      child: Card(
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              SizedBox(
                width: 65,
                height: 65,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: stat.tauxAbsence / 100,
                      strokeWidth: 6,
                      backgroundColor: color.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                    Center(child: Text('${stat.tauxAbsence.toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color))),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                stat.studentName,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              const Divider(height: 1),
              const SizedBox(height: 6),
              Text('Présence : ${stat.heuresPresences.toStringAsFixed(1)}h', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
              Text('Taux présence : ${stat.tauxPresence.toStringAsFixed(1)}%', style: TextStyle(color: Colors.green.shade700)),
              Text('Taux absence : ${stat.tauxAbsence.toStringAsFixed(1)}%', style: TextStyle(color: color)),
              if (stat.alerte25)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text('⚠️ Plus de 25% d\'absences', style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

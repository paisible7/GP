class CourseStatistic {
  final String courseId;
  final String courseName;
  final int volumeHoraire;
  final List<StudentStatistic> studentStats;

  CourseStatistic({
    required this.courseId,
    required this.courseName,
    required this.volumeHoraire,
    required this.studentStats,
  });
}

class StudentStatistic {
  final String studentId;
  final String studentName;
  final double heuresPresences;
  final double tauxPresence;
  final double tauxAbsence;
  final bool alerte25;

  StudentStatistic({
    required this.studentId,
    required this.studentName,
    required this.heuresPresences,
    required this.tauxPresence,
    required this.tauxAbsence,
    required this.alerte25,
  });
} 
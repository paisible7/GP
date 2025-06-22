class CourseStatistic {
  final String courseId;
  final String courseName;
  final int totalSessions;
  final List<StudentStatistic> studentStats;

  CourseStatistic({
    required this.courseId,
    required this.courseName,
    required this.totalSessions,
    required this.studentStats,
  });
}

class StudentStatistic {
  final String studentId;
  final String studentName;
  final int presences;
  final int totalSessions;
  late final int absences;
  late final double absenceRate;

  StudentStatistic({
    required this.studentId,
    required this.studentName,
    required this.presences,
    required this.totalSessions,
  }) {
    absences = totalSessions - presences;
    absenceRate = totalSessions > 0 ? (absences / totalSessions) * 100 : 0.0;
  }
} 
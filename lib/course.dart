class Course {
  final String name;
  final String code;
  final String subject;
  final double grade;
  final int creditHours;

  const Course({
    required this.name,
    required this.code,
    required this.subject,
    required this.grade,
    required this.creditHours,
  });

  // Converts a numeric grade to a letter grade
  String get letterGrade {
    if (grade >= 90) return 'A';
    if (grade >= 80) return 'B';
    if (grade >= 70) return 'C';
    if (grade >= 60) return 'D';
    return 'F';
  }
}
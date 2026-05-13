class CourseData {
  // Single source of truth for courses
  static const List<Map<String, String>> courses = [
    {'name': 'Computer Science 101', 'code': 'CS101'},
    {'name': 'Calculus II',          'code': 'MATH202'},
    // can add more here later
  ];

  // Just the codes for dropdowns
  static List<String> get courseCodes =>
      courses.map((c) => c['code']!).toList();

  // Get name from code
  static String nameFromCode(String code) {
    final course = courses.firstWhere(
      (c) => c['code'] == code,
      orElse: () => {'name': code, 'code': code},
    );
    return course['name']!;
  }
}
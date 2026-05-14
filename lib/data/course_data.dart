class CourseData {
  // Single source of truth for courses
  static const List<Map<String, String>> courses = [
    {'name': 'Software Engineering Management', 'code': 'CS583'},
    {'name': 'Calculus II',          'code': 'MATH202'},
    {'name': 'Intro to Physics',     'code': 'PHYS101A'},
    {'name': 'Intro to Physics LAB', 'code': 'PHYS101B'},
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

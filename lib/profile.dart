import 'package:flutter/material.dart';
import 'package:deadline_app/styled_page_name.dart';
import 'package:deadline_app/course.dart';

class Profile extends StatefulWidget {
  final String studentName;
  final String studentID;
  final String email;
  final List<Course> courses;
  final String profileImageUrl;

  const Profile({
    super.key,
    required this.studentName,
    required this.studentID,
    required this.email,
    required this.courses,
    this.profileImageUrl = '',
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late String studentName;
  late String studentID;
  late String email;
  late List<Course> sortedCourses;
  String? struggledSubject;       

  @override
  void initState() {
    super.initState();
    studentName = widget.studentName;
    studentID = widget.studentID;
    email = widget.email;
    sortedCourses = List.from(widget.courses); // NEW
  }

  // reorders courses putting the struggled subject first
  void _onSubjectTapped(String subject) {
    setState(() {
      if (struggledSubject == subject) {
        // Tapping the same subject again resets the order
        struggledSubject = null;
        sortedCourses = List.from(widget.courses);
      } else {
        struggledSubject = subject;
        sortedCourses = List.from(widget.courses)
          ..sort((a, b) {
            if (a.subject == subject) return -1;
            if (b.subject == subject) return 1;
            return 0;
          });
      }
    });
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: studentName);
    final idController = TextEditingController(text: studentID);
    final emailController = TextEditingController(text: email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: 'Student ID'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                studentName = nameController.text;
                studentID = idController.text;
                email = emailController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Profile picture
          Image.asset(
            'assets/images/default_avatar.png',
            width: 120,
            height: 120,
            errorBuilder: (context, error, stackTrace) {
              print('Image error: $error');
              return const Icon(Icons.person, size: 120, color: Colors.black);
            },
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            studentName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Student ID
          Text(
            'ID: $studentID',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),

          // Email
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                email,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 24),

   
          

          // Courses (now using sortedCourses)
          ...sortedCourses.map((course) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.school, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          course.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        course.code,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'GRADE',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                course.letterGrade,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '(${course.grade.toStringAsFixed(1)}%)',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'CREDITS',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${course.creditHours} hrs',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
          
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: const Text(
              'Areas You Struggle In',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.courses.map((course) {
              final isSelected = struggledSubject == course.subject;
              return ElevatedButton(
                onPressed: () => _onSubjectTapped(course.subject),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.red[300] : null,
                  foregroundColor: isSelected ? Colors.white : null,
                ),
                child: Text(course.subject),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: () => _showEditProfileDialog(context),
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }
}

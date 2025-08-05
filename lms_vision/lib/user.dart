import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai.dart';
import 'main.dart' show customPurple;
import 'services/api_service.dart';

class UserPage extends StatefulWidget {
  final Map<String, dynamic> user; // from login
  const UserPage({super.key, required this.user});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _selectedIndex = 0;
  late String username;
  late String email;
  late int userId;

  @override
  void initState() {
    super.initState();
    username = widget.user['username']?.toString() ?? "User";
    email = widget.user['email']?.toString() ?? "unknown@example.com";
    userId = int.tryParse(widget.user['id']?.toString() ?? '0') ?? 0;
    _buildScreens();
  }

  final List<Widget> _screens = [];

  void _buildScreens() {
    _screens
      ..clear()
      ..addAll([
        HomeScreen(username: username),
        CourseSection(userId: userId),
        const AIScreen(),
        ProfileScreen(
          username: username,
          email: email,
          onLogout: _logout,
        ),
      ]);
  }

  void _onItemTapped(int i) => setState(() => _selectedIndex = i);

  Future<void> _logout() async {
    await ApiService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: customPurple,
        title: const Text(
          "LMS Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red[600],
                  size: 20,
                ),
              ),
              onPressed: _logout,
            ),
          )
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: customPurple,
          unselectedItemColor: Colors.grey[400],
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded, size: 24),
              activeIcon: Icon(Icons.home_rounded, size: 26),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded, size: 24),
              activeIcon: Icon(Icons.menu_book_rounded, size: 26),
              label: "Courses",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_rounded, size: 24),
              activeIcon: Icon(Icons.smart_toy_rounded, size: 26),
              label: "AI",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded, size: 24),
              activeIcon: Icon(Icons.person_rounded, size: 26),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------ Home Screen ------------------

class HomeScreen extends StatelessWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [customPurple, customPurple.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: customPurple.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Welcome back, $username!",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "Ready to continue your learning journey?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: [
              _buildQuickActionCard(
                  icon: Icons.menu_book_rounded,
                  title: "My Courses",
                  subtitle: "View enrolled courses",
                  color: Colors.blue),
              _buildQuickActionCard(
                  icon: Icons.smart_toy_rounded,
                  title: "AI Assistant",
                  subtitle: "Get instant help",
                  color: Colors.green),
              _buildQuickActionCard(
                  icon: Icons.assignment_rounded,
                  title: "Assignments",
                  subtitle: "Check pending tasks",
                  color: Colors.orange),
              _buildQuickActionCard(
                  icon: Icons.analytics_rounded,
                  title: "Progress",
                  subtitle: "Track your learning",
                  color: Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ------------------ Course Section ------------------

class CourseSection extends StatefulWidget {
  final int userId;
  const CourseSection({super.key, required this.userId});

  @override
  State<CourseSection> createState() => _CourseSectionState();
}

class _CourseSectionState extends State<CourseSection> {
  String? _selectedOption;
  final List<String> _courseOptions = [
    'Add Courses',
    'Current Courses',
    'View More Courses'
  ];

  Future<void> _enrollInCourse(int courseId, String title) async {
    final success =
        await ApiService.enrollCourse(widget.userId, courseId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? "Enrolled in $title"
            : "Failed to enroll in $title")));
    setState(() {}); // Refresh list
  }

  Widget _buildCourseCard(Map<String, dynamic> course, {bool showEnroll = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(course['title'] ?? '',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(course['description'] ?? '',
              style: TextStyle(color: Colors.grey[600])),
          if (showEnroll)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () =>
                    _enrollInCourse(int.parse(course['id']), course['title']),
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text("Enroll"),
                style: TextButton.styleFrom(
                  foregroundColor: customPurple,
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _getSelectedWidget() {
    if (_selectedOption == 'Add Courses') {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: ApiService.getAvailableCourses(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading courses"));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("No new courses available"));
          }
          return Column(
            children: snapshot.data!
                .map((c) => _buildCourseCard(c, showEnroll: true))
                .toList(),
          );
        },
      );
    } else if (_selectedOption == 'Current Courses') {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: ApiService.getEnrolledCourses(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading courses"));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("No enrolled courses"));
          }
          return Column(
            children:
                snapshot.data!.map((c) => _buildCourseCard(c)).toList(),
          );
        },
      );
    } else if (_selectedOption == 'View More Courses') {
      return _buildContentCard(
        icon: Icons.explore_rounded,
        title: "Explore All Courses",
        description: "Discover all available courses across categories",
        color: Colors.purple,
      );
    }
    return Container(
      padding: const EdgeInsets.all(40),
      child: Text("Select an option above",
          style: TextStyle(color: Colors.grey[600])),
    );
  }

  Widget _buildContentCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 60, color: color),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style:
                const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Course Management",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Manage your learning journey",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: DropdownButton<String>(
              value: _selectedOption,
              hint: Text(
                "Select Course Option",
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              isExpanded: true,
              underline: const SizedBox(),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: customPurple),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedOption = newValue;
                });
              },
              items: _courseOptions
                  .map((String option) =>
                      DropdownMenuItem<String>(value: option, child: Text(option)))
                  .toList(),
            ),
          ),
          const SizedBox(height: 32),
          _getSelectedWidget(),
        ],
      ),
    );
  }
}

// ------------------ AI Screen ------------------

class AIScreen extends StatelessWidget {
  const AIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  customPurple.withOpacity(0.1),
                  customPurple.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: customPurple.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: customPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.smart_toy_rounded,
                    size: 60,
                    color: customPurple,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "AI Learning Assistant",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Get personalized help with your studies, ask questions, and receive instant explanations.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AIPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.smart_toy_rounded, size: 20),
                        SizedBox(width: 12),
                        Text(
                          "Start Conversation",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------ Profile Screen ------------------

class ProfileScreen extends StatelessWidget {
  final String username;
  final String email;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.username,
    required this.email,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: customPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, size: 80, color: customPurple),
          ),
          const SizedBox(height: 16),
          Text(
            username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(email, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          _buildProfileCard(
            icon: Icons.settings_rounded,
            title: "Account Settings",
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _buildProfileCard(
            icon: Icons.lock_rounded,
            title: "Change Password",
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _buildProfileCard(
            icon: Icons.logout_rounded,
            title: "Logout",
            color: Colors.red,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (color ?? customPurple).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color ?? customPurple, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color ?? Colors.black,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}

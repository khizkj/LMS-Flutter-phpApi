import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'manage_user.dart';
import 'manage_courses.dart';
import 'settings.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    DashboardPage(),
    ManageUsersPage(),
    ManageCoursesPage(),
    SettingsPage(),
  ];

  final List<String> titles = [
    "Dashboard",
    "Manage Users",
    "Manage Courses",
    "Settings",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          titles[selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded),
              color: Colors.white,
              iconSize: 22,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 280,
            decoration: const BoxDecoration(
              color: Color(0xFF111111),
              border: Border(
                right: BorderSide(color: Color(0xFF333333), width: 1),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                ...List.generate(4, (index) {
                  final isSelected = selectedIndex == index;
                  final icons = [Icons.dashboard_rounded, Icons.people_rounded, Icons.book_rounded, Icons.settings_rounded];
                  final labels = ['Dashboard', 'Users', 'Courses', 'Settings'];
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          setState(() => selectedIndex = index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF1A1A1A) : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected ? Border.all(color: const Color(0xFF333333)) : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                icons[index],
                                color: isSelected ? Colors.white : Colors.white60,
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                labels[index],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white60,
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFF0A0A0A),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: pages[selectedIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = true; // Default to dark mode to match admin theme
  bool _notificationsEnabled = true;

  void _toggleTheme(bool v) => setState(() => _isDarkMode = v);
  void _toggleNotifications(bool v) => setState(() => _notificationsEnabled = v);

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Logged out successfully"),
        backgroundColor: const Color(0xFF059669),
      ),
    );
    Navigator.of(context).pop(); // back out of admin
  }

  Widget _buildSettingsCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF60A5FA),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              )
            : null,
        trailing: trailing ??
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF60A5FA),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 14,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF2563EB),
        activeTrackColor: const Color(0xFF2563EB).withOpacity(0.3),
        inactiveThumbColor: Colors.white60,
        inactiveTrackColor: const Color(0xFF333333),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Customize your admin experience',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 32),

            // Appearance Settings
            _buildSettingsCard(
              title: 'Appearance',
              children: [
                _buildSwitchTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Dark Mode',
                  subtitle: 'Toggle dark theme on or off',
                  value: _isDarkMode,
                  onChanged: _toggleTheme,
                ),
                const SizedBox(height: 20),
              ],
            ),

            // Account Settings
            _buildSettingsCard(
              title: 'Account',
              children: [
                _buildSettingsTile(
                  icon: Icons.lock_rounded,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: () {
                    // TODO: Implement change password functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Password change coming soon"),
                        backgroundColor: const Color(0xFF333333),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildSettingsTile(
                  icon: Icons.person_rounded,
                  title: 'Profile Settings',
                  subtitle: 'Manage your profile information',
                  onTap: () {
                    // TODO: Implement profile settings
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Profile settings coming soon"),
                        backgroundColor: const Color(0xFF333333),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),

            // Notification Settings
            _buildSettingsCard(
              title: 'Notifications',
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications_rounded,
                  title: 'Push Notifications',
                  subtitle: 'Receive notifications about system updates',
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                ),
                const SizedBox(height: 8),
                _buildSettingsTile(
                  icon: Icons.email_rounded,
                  title: 'Email Notifications',
                  subtitle: 'Configure email notification preferences',
                  onTap: () {
                    // TODO: Implement email notification settings
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Email settings coming soon"),
                        backgroundColor: const Color(0xFF333333),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),

            // System Settings
            _buildSettingsCard(
              title: 'System',
              children: [
                _buildSettingsTile(
                  icon: Icons.backup_rounded,
                  title: 'Backup & Restore',
                  subtitle: 'Manage system backups',
                  onTap: () {
                    // TODO: Implement backup functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Backup settings coming soon"),
                        backgroundColor: const Color(0xFF333333),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildSettingsTile(
                  icon: Icons.security_rounded,
                  title: 'Security Settings',
                  subtitle: 'Manage security preferences',
                  onTap: () {
                    // TODO: Implement security settings
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Security settings coming soon"),
                        backgroundColor: const Color(0xFF333333),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),

            // Logout Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.logout_rounded,
                    size: 48,
                    color: Colors.white30,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You will be signed out of your account',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded, color: Colors.white),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminLibrarySettingsScreen extends StatefulWidget {
  const AdminLibrarySettingsScreen({super.key});

  @override
  State<AdminLibrarySettingsScreen> createState() => _AdminLibrarySettingsScreenState();
}

class _AdminLibrarySettingsScreenState extends State<AdminLibrarySettingsScreen> {
  String _selectedDuration = '7 Days';
  String _selectedMaxBooks = '3 Books';
  bool _isNotificationEnabled = true;
  bool _isSyncEnabled = false;
  bool _isLoading = true;

  final List<String> _durationOptions = ['3 Days', '7 Days', '14 Days', '30 Days'];
  final List<String> _maxBooksOptions = ['1 Book', '2 Books', '3 Books', '5 Books'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedDuration = prefs.getString('library_duration') ?? '7 Days';
      _selectedMaxBooks = prefs.getString('library_max_books') ?? '3 Books';
      _isNotificationEnabled = prefs.getBool('library_notifications') ?? true;
      _isSyncEnabled = prefs.getBool('library_sync') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('library_duration', _selectedDuration);
    await prefs.setString('library_max_books', _selectedMaxBooks);
    await prefs.setBool('library_notifications', _isNotificationEnabled);
    await prefs.setBool('library_sync', _isSyncEnabled);
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Library preferences updated successfully!'), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A68FF),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A68FF).withAlpha(40),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.settings_outlined, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Library Settings',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Manage library preferences',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 28),

              _buildSettingCard(
                icon: Icons.access_time_rounded,
                title: 'Default Borrow Duration',
                subtitle: 'Set the standard lending period for books',
                child: _buildDropdown(
                  value: _selectedDuration,
                  items: _durationOptions,
                  onChanged: (val) => setState(() => _selectedDuration = val!),
                ),
              ),

              const SizedBox(height: 16),

              _buildSettingCard(
                icon: Icons.book_outlined,
                title: 'Maximum Borrowed Books',
                subtitle: 'Limit books per student account',
                child: _buildDropdown(
                  value: _selectedMaxBooks,
                  items: _maxBooksOptions,
                  onChanged: (val) => setState(() => _selectedMaxBooks = val!),
                ),
              ),

              const SizedBox(height: 16),

              _buildSettingCard(
                icon: Icons.notifications_none_rounded,
                title: 'Book Availability Notifications',
                subtitle: 'Alert students when reserved books are available',
                trailing: Switch(
                  value: _isNotificationEnabled,
                  activeThumbColor: Colors.white, // MEMPERBAIKI DEPRECATED MEMBER USE
                  activeTrackColor: const Color(0xFF1A68FF),
                  inactiveTrackColor: const Color(0xFFE2E8F0),
                  onChanged: (val) => setState(() => _isNotificationEnabled = val),
                ),
              ),

              const SizedBox(height: 16),

              _buildSettingCard(
                icon: Icons.dns_outlined,
                title: 'Database Synchronization',
                subtitle: 'Auto-sync library data with cloud backup',
                trailing: Switch(
                  value: _isSyncEnabled,
                  activeThumbColor: Colors.white, // MEMPERBAIKI DEPRECATED MEMBER USE
                  activeTrackColor: const Color(0xFF1A68FF),
                  inactiveTrackColor: const Color(0xFFE2E8F0),
                  onChanged: (val) => setState(() => _isSyncEnabled = val),
                ),
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
                ),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF1D4ED8)),
                    children: [
                      TextSpan(
                        text: 'Note: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: 'Changes will apply to all new transactions. Existing borrowed books will retain their original settings.',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withAlpha(50),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF3B82F6), size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          if (child != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(color: Color(0xFFF1F5F9), height: 1),
            ),
            child,
          ]
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
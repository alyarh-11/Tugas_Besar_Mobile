import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../api_service.dart';
import 'google_books_search_screen.dart';
import 'account_detail_screen.dart';
import 'library_setting_screen.dart';
import 'system_information_screen.dart';
import 'library_collection_screen.dart';
import 'register_member_screen.dart';
import 'view_reports_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Membangun ulang list tab di dalam build() agar dapat mengirimkan flag isActive 
    // secara dinamis guna memicu refresh data saat tab aktif berubah
    final List<Widget> tabs = [
      _DashboardTab(
        isActive: _currentIndex == 0,
        onNavigateToSearch: () {
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      const GoogleBooksSearchScreen(),
      const _ProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'API Library'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET INTERNAL TAB 0: DASHBOARD UTAMA (STATEFUL)
// ==========================================
class _DashboardTab extends StatefulWidget {
  final bool isActive;
  final VoidCallback onNavigateToSearch;

  const _DashboardTab({
    required this.isActive,
    required this.onNavigateToSearch,
  });

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  int _totalBooks = 0;
  int _overdueBooks = 0;
  int _borrowedBooks = 0;
  int _activeUsers = 0;
  bool _isLoading = false;
  List<Map<String, String>> _recentActivities = [];
  String _fullName = '';
  String _profileImage = '';

  @override
  void initState() {
    super.initState();
    _loadSession();
    _fetchDashboardData();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _fullName = prefs.getString('user_full_name') ?? 'Admin';
        _profileImage = prefs.getString('user_profile_image') ?? '';
      });
    }
  }

  @override
  void didUpdateWidget(covariant _DashboardTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadSession();
      _fetchDashboardData();
    }
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final booksFuture = ApiService.getBooks();
      final usersFuture = ApiService.getUsers();
      final loansFuture = ApiService.getAllLoans();

      final books = await booksFuture;
      final usersData = await usersFuture;
      final loans = await loansFuture;

      int total = books.length;
      int overdue = books.where((b) => b.status.toLowerCase() == 'overdue').length;
      int borrowed = loans.where((l) => l['status'] == 'active').length;
      int activeUsers = int.tryParse(usersData['total']?.toString() ?? '0') ?? 0;

      // Build activities from recent loans + books
      List<Map<String, String>> activities = [];
      
      for (var i = 0; i < loans.length && i < 3; i++) {
        final loan = loans[i];
        final status = loan['status'] ?? 'active';
        final title = loan['title'] ?? 'Unknown Book';
        final fullName = loan['full_name'] ?? 'Unknown User';
        activities.add({
          'title': status == 'returned'
              ? 'Buku dikembalikan: "$title"'
              : 'Buku dipinjam: "$title"',
          'subtitle': 'Oleh: $fullName • ${loan['borrow_date'] ?? ''}',
        });
      }

      if (activities.isEmpty) {
        final reversedBooks = books.reversed.toList();
        for (var i = 0; i < reversedBooks.length && i < 3; i++) {
          activities.add({
            'title': 'Buku tersedia: "${reversedBooks[i].title}"',
            'subtitle': 'Penulis: ${reversedBooks[i].author}',
          });
        }
      }

      if (activities.isEmpty) {
        activities.add({
          'title': 'Belum ada aktivitas',
          'subtitle': 'Silakan cari & tambahkan buku di tab API Library',
        });
      }

      if (mounted) {
        setState(() {
          _totalBooks = total;
          _overdueBooks = overdue;
          _borrowedBooks = borrowed;
          _activeUsers = activeUsers;
          _recentActivities = activities;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil data statistik dashboard: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue),
            tooltip: 'Refresh Data',
            onPressed: _fetchDashboardData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        color: AppColors.primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER PROFILE SEPERTI DI STUDENT
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 35),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.smartphone, size: 28, color: Colors.grey.shade400),
                          const Positioned(
                            top: 8,
                            child: Icon(Icons.menu_book, size: 14, color: AppColors.primaryBlue),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Welcome back,', style: TextStyle(color: Color(0xFF93C5FD), fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(_fullName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Library Statistics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: constraints.maxWidth > 800 ? 1.4 : 1.1,
                    children: [
                      _StatCard(
                        title: 'Total Books',
                        value: _isLoading ? '...' : _totalBooks.toString(),
                        icon: Icons.book_rounded,
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminLibraryCollectionScreen(
                                initialStatus: 'All',
                              ),
                            ),
                          ).then((_) => _fetchDashboardData());
                        },
                      ),
                      _StatCard(
                        title: 'Borrowed',
                        value: _isLoading ? '...' : _borrowedBooks.toString(),
                        icon: Icons.bookmark_rounded,
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminLibraryCollectionScreen(
                                initialStatus: 'Borrowed',
                              ),
                            ),
                          ).then((_) => _fetchDashboardData());
                        },
                      ),
                      _StatCard(
                        title: 'Overdue',
                        value: _isLoading ? '...' : _overdueBooks.toString(),
                        icon: Icons.warning_rounded,
                        color: Colors.red,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminLibraryCollectionScreen(
                                initialStatus: 'Overdue',
                              ),
                            ),
                          ).then((_) => _fetchDashboardData());
                        },
                      ),
                      _StatCard(
                        title: 'Active Users',
                        value: _isLoading ? '...' : _activeUsers.toString(),
                        icon: Icons.people_rounded,
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminRegisterMemberScreen(),
                            ),
                          ).then((_) => _fetchDashboardData());
                        },
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 32),
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _QuickActionCard(
                      icon: Icons.add_box_rounded,
                      title: 'Add New Book',
                      onTap: widget.onNavigateToSearch,
                    ),
                    const SizedBox(width: 12),
                    _QuickActionCard(
                      icon: Icons.person_add_rounded,
                      title: 'Register Member',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminRegisterMemberScreen()),
                        ).then((_) => _fetchDashboardData());
                      },
                    ),
                    const SizedBox(width: 12),
                    _QuickActionCard(
                      icon: Icons.assignment_rounded,
                      title: 'View Reports',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminViewReportsScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              const Text(
                'Recent Activities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              
              if (_isLoading && _recentActivities.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                ..._recentActivities.map((act) => _RecentActivityCard(
                      title: act['title'] ?? '',
                      subtitle: act['subtitle'] ?? '',
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================================
// WIDGET INTERNAL STAT CARD (ANTI CRASH / OVERFLOW)
// ========================================================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================================
// WIDGET INTERNAL QUICK ACTION CARD
// ========================================================
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Card(
        elevation: 1,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.primaryBlue, size: 30),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========================================================
// WIDGET INTERNAL RECENT ACTIVITY CARD
// ========================================================
class _RecentActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _RecentActivityCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blueGrey,
          child: Icon(Icons.history_rounded, color: Colors.white),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}

// ==========================================
// WIDGET INTERNAL TAB 2: PROFIL ADMIN
// ==========================================
class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  String _fullName = '';
  String _email = '';
  String _id = '';
  String _profileImage = '';

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('user_full_name') ?? 'Admin';
      _email = prefs.getString('user_email') ?? '';
      _id = prefs.getString('user_id') ?? '';
      _profileImage = prefs.getString('user_profile_image') ?? '';
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Apakah Anda yakin ingin keluar dari\nPocket Library?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pop(context); // Tutup dialog
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Berhasil keluar dari akun')),
                            );
                            Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                              '/login',
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header Profile dengan Background Gradient Biru Admin
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 45, left: 24, right: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admin Profile',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(Icons.smartphone, size: 48, color: Colors.grey.shade400),
                              const Positioned(
                                top: 12,
                                child: Icon(Icons.menu_book, size: 22, color: AppColors.primaryBlue),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _fullName.isEmpty ? 'Admin' : _fullName,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Admin ID: ADM-$_id',
                          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _email,
                          style: const TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Daftar Menu Navigasi (Menghubungkan ke Screen Asli)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Administration Control',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildMenuItem(
                    icon: Icons.person_outline_rounded,
                    iconColor: const Color(0xFF2563EB),
                    iconBg: const Color(0xFFEFF6FF),
                    title: 'Account Details',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminAccountDetailScreen()),
                      ).then((_) => _loadSession());
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    iconColor: const Color(0xFF10B981),
                    iconBg: const Color(0xFFE6F4EA),
                    title: 'Library Settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminLibrarySettingsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildMenuItem(
                    icon: Icons.info_outline_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    iconBg: const Color(0xFFFEF3C7),
                    title: 'System Information',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminSystemInformationScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildMenuItem(
                    icon: Icons.logout_rounded,
                    iconColor: const Color(0xFFEF4444),
                    iconBg: const Color(0xFFFEE2E2),
                    title: 'Logout',
                    titleColor: const Color(0xFFEF4444),
                    arrowColor: const Color(0xFFEF4444),
                    onTap: () => _showLogoutDialog(context),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required VoidCallback onTap,
    Color titleColor = const Color(0xFF1E293B),
    Color arrowColor = const Color(0xFF94A3B8),
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: iconBg,
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: titleColor)),
            ),
            Icon(Icons.chevron_right_rounded, color: arrowColor, size: 20),
          ],
        ),
      ),
    );
  }
}

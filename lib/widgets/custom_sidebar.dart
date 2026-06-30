import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomSidebar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const CustomSidebar({
    super.key, 
    required this.currentIndex, 
    required this.onTabSelected
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Row(
              children: [
                Icon(Icons.menu_book, color: AppColors.primaryBlue, size: 30),
                SizedBox(width: 12),
                Text(
                  'Pocket Library',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Menu Items dengan Fungsi Aktif
          _buildSidebarItem(context, 0, Icons.dashboard, 'Dashboard'),
          _buildSidebarItem(context, 1, Icons.search, 'API Library'),
          
          const Spacer(), // Mendorong menu logout ke paling bawah
          const Divider(height: 1),
          
          // Tombol Logout Berfungsi Penuh
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.dangerRed),
            title: const Text('Logout', style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.bold)),
            onTap: () {
              // Menghapus semua riwayat tumpukan halaman dan kembali ke Portal Login
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, int index, IconData icon, String title) {
    final isSelected = currentIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primaryBlue.withValues(alpha: 0.05),
      onTap: () {
        onTabSelected(index);
        // Logika perpindahan halaman berdasarkan index menu sidebar
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
        } else if (index == 1) {
          Navigator.pushNamed(context, '/admin/google-search');
        }
      },
    );
  }
}
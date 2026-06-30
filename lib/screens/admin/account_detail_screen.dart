import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../api_service.dart';
import '../../constants/colors.dart';

class AdminAccountDetailScreen extends StatefulWidget {
  const AdminAccountDetailScreen({super.key});

  @override
  State<AdminAccountDetailScreen> createState() => _AdminAccountDetailScreenState();
}

class _AdminAccountDetailScreenState extends State<AdminAccountDetailScreen> {
  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _adminId = '';
  String _role = 'student';
  String _profileImageUrl = '';
  XFile? _pickedImage;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadFromSession();
  }

  Future<void> _loadFromSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('user_full_name') ?? '';
      _email = prefs.getString('user_email') ?? '';
      _phone = prefs.getString('user_phone') ?? '';
      _adminId = prefs.getString('user_id') ?? '1';
      _role = prefs.getString('user_role') ?? 'student';
      _profileImageUrl = prefs.getString('user_profile_image') ?? '';
      _isLoading = false;
    });
  }

  Future<void> _saveToSession({String? newProfileImage}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_full_name', _fullName);
    await prefs.setString('user_email', _email);
    await prefs.setString('user_phone', _phone);
    if (newProfileImage != null && newProfileImage.isNotEmpty) {
      await prefs.setString('user_profile_image', newProfileImage);
      setState(() => _profileImageUrl = newProfileImage);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _pickedImage = picked);
      // Immediately upload
      await _uploadProfileImage(picked);
    }
  }

  Future<void> _uploadProfileImage(XFile imageFile) async {
    setState(() => _isSaving = true);
    final bytes = await imageFile.readAsBytes();
    final result = await ApiService.updateUserProfile(
      _adminId, _fullName, _phone, _email, '',
      imageBytes: bytes,
      imageName: imageFile.name,
    );
    setState(() => _isSaving = false);

    if (!mounted) return;
    if (result['status'] == 'success') {
      await _saveToSession(newProfileImage: result['profile_image'] ?? '');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diperbarui!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal upload foto'), backgroundColor: Colors.red),
      );
    }
  }

  void _showEditDialog() {
    final nameCtrl = TextEditingController(text: _fullName);
    final emailCtrl = TextEditingController(text: _email);
    final phoneCtrl = TextEditingController(text: _phone);
    final passCtrl = TextEditingController();
    bool obscurePass = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.edit_rounded, color: AppColors.primaryBlue, size: 20),
              SizedBox(width: 8),
              Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor HP',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: passCtrl,
                  obscureText: obscurePass,
                  decoration: InputDecoration(
                    labelText: 'Password Baru (kosongkan jika tidak berubah)',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: Icon(obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setDialogState(() => obscurePass = !obscurePass),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                setState(() => _isSaving = true);

                final result = await ApiService.updateUserProfile(
                  _adminId,
                  nameCtrl.text.trim(),
                  phoneCtrl.text.trim(),
                  emailCtrl.text.trim(),
                  passCtrl.text,
                );

                if (!mounted) return;
                setState(() => _isSaving = false);

                if (result['status'] == 'success') {
                  // Update state and save to SharedPreferences
                  setState(() {
                    _fullName = nameCtrl.text.trim();
                    _email = emailCtrl.text.trim();
                    _phone = phoneCtrl.text.trim();
                  });
                  await _saveToSession();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.green),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message'] ?? 'Gagal memperbarui profil'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)));
    }

    final imageUrl = _profileImageUrl.isNotEmpty ? '${ApiService.baseUrl}/$_profileImageUrl' : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Account Details',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: false,
      ),
      body: _isSaving
          ? const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryBlue),
                SizedBox(height: 16),
                Text('Menyimpan perubahan...', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // === FOTO PROFIL ===
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF1A68FF),
                                    image: _pickedImage != null
                                        ? DecorationImage(
                                            image: kIsWeb ? NetworkImage(_pickedImage!.path) : NetworkImage(_pickedImage!.path), 
                                            // Fallback for picking in web: XFile.path is object URL in web which works with NetworkImage
                                            fit: BoxFit.cover,
                                          )
                                        : imageUrl.isNotEmpty
                                            ? DecorationImage(
                                                image: NetworkImage(imageUrl),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF1A68FF).withAlpha(50),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: (_pickedImage == null && imageUrl.isEmpty)
                                      ? const Icon(Icons.person_outline_rounded, color: Colors.white, size: 48)
                                      : null,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2563EB),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library_outlined, size: 14, color: AppColors.primaryBlue),
                            label: const Text('Ganti Foto Profil', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _fullName.isEmpty ? 'User' : _fullName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _role == 'admin' ? 'Admin ID: ADM-$_adminId' : 'Student ID: STU-$_adminId',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: _role == 'admin' ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _role == 'admin' ? const Color(0xFFDBEAFE) : const Color(0xFFDCFCE7)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _role == 'admin' ? Icons.shield_outlined : Icons.school_outlined, 
                                  size: 14, 
                                  color: _role == 'admin' ? const Color(0xFF2563EB) : const Color(0xFF16A34A)
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _role == 'admin' ? 'Administrator' : 'Student', 
                                  style: TextStyle(
                                    fontSize: 12, 
                                    fontWeight: FontWeight.bold, 
                                    color: _role == 'admin' ? const Color(0xFF2563EB) : const Color(0xFF16A34A)
                                  )
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // === INFO AKUN ===
                    const Text(
                      'ACCOUNT INFORMATION',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569), letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 12),

                    _buildInfoCard(
                      icon: Icons.person_outline_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      iconBg: const Color(0xFFEFF6FF),
                      label: 'Nama Lengkap',
                      value: _fullName.isEmpty ? '-' : _fullName,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.mail_outline_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      iconBg: const Color(0xFFEFF6FF),
                      label: 'Email Address',
                      value: _email.isEmpty ? '-' : _email,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.phone_outlined,
                      iconColor: const Color(0xFF3B82F6),
                      iconBg: const Color(0xFFEFF6FF),
                      label: 'Nomor HP',
                      value: _phone.isEmpty ? '-' : _phone,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.lock_outline_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      iconBg: const Color(0xFFEFF6FF),
                      label: 'Password',
                      value: '••••••••',
                    ),

                    const SizedBox(height: 36),

                    // === TOMBOL EDIT ===
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
                        child: ElevatedButton.icon(
                          onPressed: _showEditDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                          label: const Text(
                            'Edit Profile',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
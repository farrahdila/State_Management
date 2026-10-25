import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _favoriteController = TextEditingController();

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final user = context.read<UserProvider>().user;
      _nameController.text = user.name;
      _emailController.text = user.email;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _favoriteController.dispose();
    super.dispose();
  }

  // Latihan 5: validasi dan penyimpanan profil.
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<UserProvider>();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();

    final prefs = await SharedPreferences.getInstance();

    // Simulasi daftar email yang sudah pernah digunakan.
    final registeredEmails = prefs.getStringList('registered_emails') ?? [];

    final currentEmail = provider.user.email.toLowerCase();

    if (email != currentEmail &&
        (registeredEmails.contains(email) ||
            prefs.getString('user_email')?.toLowerCase() == email)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email sudah digunakan. Gunakan email lain.'),
        ),
      );
      return;
    }

    // Simpan email yang sudah terdaftar untuk simulasi pemeriksaan.
    if (!registeredEmails.contains(currentEmail) && currentEmail.isNotEmpty) {
      registeredEmails.add(currentEmail);
    }

    if (!registeredEmails.contains(email)) {
      registeredEmails.add(email);
    }

    await prefs.setStringList('registered_emails', registeredEmails);

    await provider.updateUser(User(name: name, email: email, isLoggedIn: true));

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profil berhasil disimpan.')));
  }

  // Latihan 3: menambah favorit.
  Future<void> _addFavorite() async {
    final item = _favoriteController.text.trim();

    if (item.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan item favorit terlebih dahulu.')),
      );
      return;
    }

    final provider = context.read<UserProvider>();

    if (provider.favorites.contains(item)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item tersebut sudah ada di favorit.')),
      );
      return;
    }

    await provider.toggleFavorite(item);
    _favoriteController.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favorit berhasil ditambahkan.')),
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah kamu yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;

    await context.read<UserProvider>().logout();

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Profil Pengguna')),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Icon(Icons.account_circle, size: 80),
                    const SizedBox(height: 20),

                    // Form profil dan validasi keamanan.
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama lengkap',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              final name = value?.trim() ?? '';

                              if (name.isEmpty) {
                                return 'Nama tidak boleh kosong.';
                              }

                              // Menolak tag HTML/script.
                              if (RegExp(
                                r'<[^>]*>',
                                caseSensitive: false,
                              ).hasMatch(name)) {
                                return 'Nama mengandung karakter/tag berbahaya.';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Alamat email',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email),
                            ),
                            validator: (value) {
                              final email = value?.trim() ?? '';

                              if (email.isEmpty) {
                                return 'Email tidak boleh kosong.';
                              }

                              final emailPattern = RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              );

                              if (!emailPattern.hasMatch(email)) {
                                return 'Format email tidak valid.';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _saveProfile,
                              child: const Text('Simpan Profil'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 32),

                    // Latihan 3: daftar favorit.
                    const Text(
                      'Daftar Favorit',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _favoriteController,
                            decoration: const InputDecoration(
                              labelText: 'Hobi atau item favorit',
                              hintText: 'Contoh: Membaca',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _addFavorite(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          tooltip: 'Tambah favorit',
                          onPressed: _addFavorite,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    if (provider.favorites.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Belum ada item favorit.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ...provider.favorites.map(
                        (item) => ListTile(
                          leading: const Icon(Icons.favorite),
                          title: Text(item),
                          trailing: IconButton(
                            tooltip: 'Hapus favorit',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              provider.toggleFavorite(item);
                            },
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    OutlinedButton.icon(
                      onPressed: _confirmLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

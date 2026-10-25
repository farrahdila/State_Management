import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('State & Preferences'),
            actions: [
              IconButton(
                tooltip: userProvider.isDarkMode
                    ? 'Aktifkan Mode Terang'
                    : 'Aktifkan Mode Gelap',
                icon: Icon(
                  userProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  userProvider.toggleDarkMode(!userProvider.isDarkMode);
                },
              ),
              IconButton(
                tooltip: 'Profil',
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: userProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Icon(
                      Icons.waving_hand,
                      size: 70,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userProvider.user.name.isNotEmpty
                          ? 'Halo, ${userProvider.user.name}!'
                          : 'Selamat Datang!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userProvider.user.isLoggedIn
                          ? 'Kamu sudah login.'
                          : 'Silakan lengkapi profil kamu.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Kartu jumlah kunjungan aplikasi
                    Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.visibility,
                          color: Colors.deepPurple,
                        ),
                        title: const Text('Jumlah Kunjungan'),
                        subtitle: const Text('Total aplikasi dibuka'),
                        trailing: Text(
                          '${userProvider.visitCount}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Kartu jumlah favorit
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.favorite, color: Colors.red),
                        title: const Text('Daftar Favorit'),
                        subtitle: Text(
                          '${userProvider.favorites.length} item tersimpan',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tombol menuju profil
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_outline),
                      label: const Text('Buka Profil'),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

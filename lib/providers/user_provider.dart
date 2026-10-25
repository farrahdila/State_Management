import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(name: '', email: '');
  bool _isLoading = true;
  bool _isDarkMode = false;
  int _visitCount = 0;
  List<String> _favorites = [];

  User get user => _user;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  int get visitCount => _visitCount;
  List<String> get favorites => List.unmodifiable(_favorites);

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    _user = User(
      name: prefs.getString('user_name') ?? '',
      email: prefs.getString('user_email') ?? '',
      isLoggedIn: prefs.getBool('is_logged_in') ?? false,
    );

    _isDarkMode = prefs.getBool('is_dark_mode') ?? false;

    _visitCount = (prefs.getInt('visit_count') ?? 0) + 1;
    await prefs.setInt('visit_count', _visitCount);

    _favorites = prefs.getStringList('favorites') ?? [];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = value;
    await prefs.setBool('is_dark_mode', value);
    notifyListeners();
  }

  Future<void> toggleFavorite(String item) async {
    final favorite = item.trim();
    if (favorite.isEmpty) return;

    if (_favorites.contains(favorite)) {
      _favorites.remove(favorite);
    } else {
      _favorites.add(favorite);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites);
    notifyListeners();
  }

  Future<void> updateUser(User newUser) async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newUser.name);
    await prefs.setString('user_email', newUser.email);
    await prefs.setBool('is_logged_in', newUser.isLoggedIn);

    _user = newUser;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('user_name');
    await prefs.setBool('is_logged_in', false);

    _user = _user.copyWith(name: '', isLoggedIn: false);

    notifyListeners();
  }
}

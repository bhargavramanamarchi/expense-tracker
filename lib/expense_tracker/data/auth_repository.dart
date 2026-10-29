import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';

/// Repository for persisting the active user profile and preferences locally.
class AuthRepository {
  static const String _userKey = 'expense_tracker_active_user_v1';

  final SharedPreferences? _prefs;

  AuthRepository([this._prefs]);

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  /// Retrieves the current user profile, returning the default profile if none saved.
  Future<AppUser> getCurrentUser() async {
    final prefs = await _getPrefs();
    final rawJson = prefs.getString(_userKey);
    if (rawJson == null || rawJson.isEmpty) {
      final defaultUser = AppUser.defaultProfile();
      await saveUser(defaultUser);
      return defaultUser;
    }

    try {
      final Map<String, dynamic> map =
          jsonDecode(rawJson) as Map<String, dynamic>;
      return AppUser.fromJson(map);
    } catch (_) {
      return AppUser.defaultProfile();
    }
  }

  /// Persists updated user information.
  Future<void> saveUser(AppUser user) async {
    final prefs = await _getPrefs();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  /// Convenience method to update just the monthly budget.
  Future<AppUser> updateBudget(double newBudget) async {
    final user = await getCurrentUser();
    final updated = user.copyWith(monthlyBudget: newBudget);
    await saveUser(updated);
    return updated;
  }

  /// Convenience method to update the preferred currency symbol.
  Future<AppUser> updateCurrency(String currencySymbol) async {
    final user = await getCurrentUser();
    final updated = user.copyWith(currencySymbol: currencySymbol);
    await saveUser(updated);
    return updated;
  }
}

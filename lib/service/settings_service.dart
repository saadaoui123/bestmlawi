import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_best_mlewi/l10n/app_localizations.dart';

class SettingsService extends ChangeNotifier {
  bool _notifications = true;
  bool _emailNotifications = false;
  bool _darkMode = false;
  String _language = 'Français';
  bool _isLoading = true;

  bool get notifications => _notifications;
  bool get emailNotifications => _emailNotifications;
  bool get darkMode => _darkMode;
  String get language => _language;
  bool get isLoading => _isLoading;
  AppLocalizations get localizations => AppLocalizations(_language);

  SettingsService() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('preferences')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _notifications = data['notifications'] ?? true;
        _emailNotifications = data['emailNotifications'] ?? false;
        _darkMode = data['darkMode'] ?? false;
        _language = data['language'] ?? 'Français';
      }
    } catch (e) {
      // Ignore errors
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('preferences')
          .set({
        'notifications': _notifications,
        'emailNotifications': _emailNotifications,
        'darkMode': _darkMode,
        'language': _language,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Ignore errors
    }
  }

  void updateNotifications(bool value) {
    _notifications = value;
    notifyListeners();
    _saveSettings();
  }

  void updateEmailNotifications(bool value) {
    _emailNotifications = value;
    notifyListeners();
    _saveSettings();
  }

  void updateDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
    _saveSettings();
  }

  void updateLanguage(String value) {
    _language = value;
    notifyListeners();
    _saveSettings();
  }
}

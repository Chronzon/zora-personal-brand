import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  // Default ke null dulu, artinya belum dipilih
  Locale? _locale;

  Locale? get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
  
  // Helper untuk mendapatkan kode bahasa string ('id' atau 'en')
  // Ini nanti dikirim ke AI
  String get languageCode => _locale?.languageCode ?? 'id';
  
  // Helper untuk nama bahasa yang mudah dibaca
  String get languageName {
    if (_locale?.languageCode == 'id') return 'Bahasa Indonesia';
    return 'English';
  }
}
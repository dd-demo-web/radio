import 'package:flutter/foundation.dart';

class RadioAppState extends ChangeNotifier {
  int _currentNavIndex = 0; // 0: Live, 1: Palinsesto, 2: Discover, 3: Preferiti, 4: Profilo
  int get currentNavIndex => _currentNavIndex;

  void setNavIndex(int index) {
    if (_currentNavIndex != index) {
      _currentNavIndex = index;
      notifyListeners();
    }
  }

  // Favorites
  final List<String> _favs = ['fresh', 'funky', 'liquid'];
  List<String> get favs => _favs;

  bool isFav(String id) => _favs.contains(id);

  void toggleFav(String id) {
    if (_favs.contains(id)) {
      _favs.remove(id);
    } else {
      _favs.add(id);
    }
    notifyListeners();
  }

  // Alerts for favorites
  final Map<String, bool> _alerts = {'fresh': true, 'funky': true};
  bool hasAlert(String id) => _alerts[id] == true;

  void toggleAlert(String id) {
    _alerts[id] = !(_alerts[id] ?? false);
    notifyListeners();
  }

  // Notifications
  bool _unreadNotifications = true;
  bool get unreadNotifications => _unreadNotifications;

  void markNotificationsRead() {
    if (_unreadNotifications) {
      _unreadNotifications = false;
      notifyListeners();
    }
  }

  // Preferences
  final Map<String, bool> _prefs = {
    'live': true,
    'mix': true,
    'wifi': true,
  };
  bool getPref(String key) => _prefs[key] ?? true;

  void togglePref(String key) {
    _prefs[key] = !(_prefs[key] ?? true);
    notifyListeners();
  }

  // Live program selection
  int _liveIndex = 0;
  int get liveIndex => _liveIndex;

  void nextLive() {
    _liveIndex = (_liveIndex + 1) % 5;
    notifyListeners();
  }

  // Discover quote song selection
  int _songIndex = 0;
  int get songIndex => _songIndex;

  void setSongIndex(int index) {
    _songIndex = index;
    notifyListeners();
  }

  // Active mixtape/mood playback if any
  String? _activeMix;
  String? get activeMix => _activeMix;

  void setActiveMix(String? mixId) {
    _activeMix = mixId;
    notifyListeners();
  }
}

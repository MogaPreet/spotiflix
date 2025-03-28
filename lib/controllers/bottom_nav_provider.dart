import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class BottomNavProvider with ChangeNotifier {
  int _currentIndex = 0;
  
  int get currentIndex => _currentIndex;
  
  // Update the getter to include "Reels" title
  String get appBarTitle {
    switch (_currentIndex) {
      case 0:
        return 'Spotiflix';
      case 1:
        return 'Trailers';  // New title for Reels tab
      case 2:
        return 'Search';
      case 3:
        return 'My Library';
      default:
        return 'Spotiflix';
    }
  }
  
  void updateIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
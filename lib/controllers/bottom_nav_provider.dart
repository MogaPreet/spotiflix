import 'package:flutter/material.dart';

class BottomNavProvider extends ChangeNotifier {
  int _currentIndex = 0;
  
  int get currentIndex => _currentIndex;
  
  String get appBarTitle {
    switch (_currentIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Search';
      case 2:
        return 'Library';
      default:
        return 'Spotiflix';
    }
  }
  
  void updateIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
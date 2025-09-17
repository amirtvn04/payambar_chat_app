import 'package:chat_app/core/other/base_viewmodel.dart';

class BottomNavigationViewmodel extends BaseViewmodel {
  int _currentIndex = 1;

  int get currentIndex => _currentIndex;

  setIndex(int value) {
    if (_currentIndex != value) {
      _currentIndex = value;
      notifyListeners();
    }
  }
}

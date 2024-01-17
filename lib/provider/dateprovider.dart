import 'package:flutter/cupertino.dart';

class SelectDateProvider extends ChangeNotifier{
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void updateSelectedDate(DateTime newDate) {
    _selectedDate = newDate;
    notifyListeners();
  }
}
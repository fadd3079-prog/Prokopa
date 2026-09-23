import 'package:flutter/foundation.dart';

class AppDateController extends ChangeNotifier {
  AppDateController({DateTime? initialDate})
    : _selectedDate = _day(initialDate ?? DateTime.now()),
      _displayedMonth = _month(initialDate ?? DateTime.now());

  DateTime _selectedDate;
  DateTime _displayedMonth;

  DateTime get selectedDate => _selectedDate;
  DateTime get displayedMonth => _displayedMonth;

  bool get isCurrentMonth {
    final now = DateTime.now();
    return _displayedMonth.year == now.year &&
        _displayedMonth.month == now.month;
  }

  void selectDate(DateTime value) {
    final next = _day(value);
    if (next == _selectedDate) {
      return;
    }
    _selectedDate = next;
    _displayedMonth = _month(next);
    notifyListeners();
  }

  void showMonth(DateTime value) {
    final next = _month(value);
    if (next == _displayedMonth) {
      return;
    }
    _displayedMonth = next;
    notifyListeners();
  }

  void previousMonth() =>
      showMonth(DateTime(_displayedMonth.year, _displayedMonth.month - 1));

  void nextMonth() =>
      showMonth(DateTime(_displayedMonth.year, _displayedMonth.month + 1));

  void showToday() {
    final now = _day(DateTime.now());
    _selectedDate = now;
    _displayedMonth = _month(now);
    notifyListeners();
  }

  static DateTime _day(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime _month(DateTime value) => DateTime(value.year, value.month);
}

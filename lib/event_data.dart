import 'package:flutter/material.dart';

class EventData extends ChangeNotifier {
  List<Map<String, dynamic>> savedEvents = [];
  List<Map<String, dynamic>> purchasedEvents = [];

  void saveEvent(Map<String, dynamic> event) {
    savedEvents.add(event);
    notifyListeners();
  }

  void purchaseEvent(Map<String, dynamic> event) {
    purchasedEvents.add(event);
    notifyListeners();
  }
}
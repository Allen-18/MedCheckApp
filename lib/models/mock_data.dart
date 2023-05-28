import 'dart:convert';

import '../screens/simulator.dart';

String generateMockData() {
  final mockData = {
    'pulse': {'value': 80, 'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000},
    'temperature': {'value': 26.5, 'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000},
    'humidity': {'value': 62.5, 'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000},
    'ekg': List.generate(20, (i) => {'value': (i + 1) / 100, 'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + i})
  };
  return jsonEncode(mockData);
}
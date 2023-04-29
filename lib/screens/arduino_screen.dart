import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ArduinoScreen extends StatefulWidget {
  final BluetoothConnection connection;

  const ArduinoScreen({Key? key, required this.connection}) : super(key: key);

  @override
  ArduinoScreenState createState() => ArduinoScreenState();
}

class ArduinoScreenState extends State<ArduinoScreen> {
  int pulse = 0;
  double ecg = 0.0;
  double humidity = 0.0;
  int temperature = 0;

  @override
  void initState() {
    super.initState();
    widget.connection.input?.listen(_onDataReceived);
  }

  void _onDataReceived(Uint8List data) {
    String jsonString = utf8.decode(data);
    dynamic json = jsonDecode(jsonString);

    setState(() {
      pulse = json['pulse'] ?? 0.0;
      ecg = json['ecg'] ?? 0.0;
      humidity = json['humidity'] ?? 0.0;
      temperature = json['temperature'] ?? 0.0;
    });

    if (kDebugMode) {
      print('Received data: pulse=$pulse, ecg=$ecg, humidity=$humidity, temperature=$temperature');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arduino Data'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Pulse: $pulse'),
            Text('ECG: $ecg'),
            Text('Humidity: $humidity'),
            Text('Temperature: $temperature'),
          ],
        ),
      ),
    );
  }
}

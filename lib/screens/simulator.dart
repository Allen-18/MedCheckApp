import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';

class DataSensor extends StatefulWidget {
  const DataSensor(Map<String, dynamic> jsonData, {super.key});
  @override
  DataSensorState createState() => DataSensorState();
}

class DataSensorState extends State<DataSensor> {

  String _temperature = "?";
  String _humidity = "?";
  String _pulse = "?";
  late StreamSubscription<List<int>> _dataSubscription;
  @override
  void initState() {
    super.initState();
    _establishBluetoothConnection();
  }

  @override
  void dispose() {
    _cancelDataSubscription();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Card(
            child: SizedBox(
              width: 150,
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.asset('images/temperature.png'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Temperatura",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Text(
                    _temperature,
                    style: const TextStyle(fontSize: 30),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: SizedBox(
              width: 150,
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.asset('images/humidity.png'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Umiditate",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Text(
                    _humidity,
                    style: const TextStyle(fontSize: 30),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: SizedBox(
              width: 150,
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.asset('images/temperature.png'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Puls",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Text(
                    _pulse,
                    style: const TextStyle(fontSize: 30),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _establishBluetoothConnection() async {
    try {
      FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
      List<BluetoothDevice> devices = await flutterBlue.connectedDevices;
      if (devices.isNotEmpty) {
        BluetoothDevice device = devices.first;
        await device.connect();
        _subscribeToData(device);
      }
    } catch (e) {
      if(kDebugMode){
        print("Eroare $e");
      }
    }
  }

  void _cancelDataSubscription() {
    _dataSubscription.cancel();
  }

  void _subscribeToData(BluetoothDevice device) {
    _dataSubscription = device.state.listen((value) {
      String jsonString = utf8.decode(value as List<int>);
      _dataParser(jsonString);
    }) as StreamSubscription<List<int>>;
  }

  void _dataParser(String jsonString) {
    Map<String, dynamic> jsonData = json.decode(jsonString);
    var tempValue = jsonData['temperature'];
    var humidityValue = jsonData['humidity'];
    var pulseValue = jsonData['pulse'];

    setState(() {
      _temperature = "$tempValue'C";
      _humidity = "$humidityValue%";
      _pulse = "$pulseValue";
    });
  }
}

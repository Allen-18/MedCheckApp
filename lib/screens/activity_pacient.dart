import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  @override
  ActivityScreenState createState() => ActivityScreenState();
}

class ActivityScreenState extends State<ActivityScreen> {
  List<String> activities = [];

  @override
  void initState() {
    super.initState();
    _getActivitiesFromApi();
  }

  Future<void> _getActivitiesFromApi() async {
    final response =
        await http.get(Uri.parse('https://example.com/api/recommendations'));
    final data = jsonDecode(response.body);

    setState(() {
      activities = List<String>.from(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activitati recomandate'),
      ),
      body: activities.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: activities.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(activities[index]),
                );
              },
            ),
    );
  }
}

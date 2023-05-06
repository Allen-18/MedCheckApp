import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReferenceScreen extends StatefulWidget {
  const ReferenceScreen({Key? key}) : super(key: key);
  @override
  ReferenceScreenState createState() => ReferenceScreenState();
}

class ReferenceScreenState extends State<ReferenceScreen> {
  late String recomandari;
  final storage = const FlutterSecureStorage();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    setState(() {
      _isLoading = true;
    });
    final accessToken = await storage.read(key: 'access');
    try {
      final response = await http.get(
        Uri.parse('https://medcheck.azurewebsites.net/api/me/recomandari/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<String> recomandari = List<String>.from(
            data['results'].map((result) => result['tip_recomandare']));
        this.recomandari = recomandari.join(', ');
      } else {
        throw Exception(
            'Failed to fetch profile data:${response.reasonPhrase} ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching profile data: $e');
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Recomandari'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Recomandarile medicului sunt :',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    recomandari,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
    );
  }
}

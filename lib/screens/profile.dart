import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _prenumeController;
  late TextEditingController _istoricController;
  late TextEditingController _alergiiController;
  late TextEditingController _emailController;
  final storage = const FlutterSecureStorage();

  bool _isLoading = true;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _prenumeController = TextEditingController();
    _istoricController = TextEditingController();
    _alergiiController = TextEditingController();
    _emailController = TextEditingController();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    setState(() {
      _isLoading = true;
    });
    final accessToken = await storage.read(key: 'access');

    try {
      final response = await http.get(
        Uri.parse('https://medcheck.azurewebsites.net/api/me/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json'
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final nume = data['nume'];
        final prenume = data['prenume'];
        final istoric = data['istoric_medical'];
        final alergii = data['alergii'];
        final email = data['email'];
        if (nume == null ||
            nume.isEmpty ||
            prenume == null ||
            prenume.isEmpty) {
          throw Exception('Name or surname is missing');
        }
        final formattedNume = nume.toString();
        final formattedPrenume = prenume.toString();
        _nameController.text = formattedNume;
        _prenumeController.text = formattedPrenume;
        _istoricController.text = istoric ?? '';
        _alergiiController.text = alergii ?? '';
        _emailController.text = email ?? '';
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
        title: const Text('Profil pacient'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              children: <Widget>[
                imageProfile(),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 20),
                  decoration: const InputDecoration(
                    labelText: 'Nume',
                    labelStyle: TextStyle(fontSize: 20),
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.redAccent,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.redAccent),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _prenumeController,
                  style: const TextStyle(fontSize: 20),
                  decoration: const InputDecoration(
                    labelText: 'Prenume',
                    labelStyle: TextStyle(fontSize: 20),
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.redAccent,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.redAccent),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _istoricController,
                  style: const TextStyle(fontSize: 20),
                  decoration: const InputDecoration(
                    labelText: 'Istoric_medical',
                    labelStyle: TextStyle(fontSize: 20),
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.medical_information,
                      color: Colors.redAccent,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.redAccent),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _alergiiController,
                  style: const TextStyle(fontSize: 20),
                  decoration: const InputDecoration(
                    labelText: 'Alergii',
                    labelStyle: TextStyle(fontSize: 20),
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.medical_information,
                      color: Colors.redAccent,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.redAccent),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(fontSize: 20),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(fontSize: 20),
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.redAccent,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.redAccent),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
    );
  }

  Widget imageProfile() {
    return Center(
      child: Stack(
        children: <Widget>[
          CircleAvatar(
            radius: 60.0,
            backgroundImage: _imageFile == null
                ? const AssetImage('assets/images/profile.png')
                    as ImageProvider<Object>?
                : FileImage(File(_imageFile!.path)),
          ),
          Positioned(
            bottom: 1.0,
            right: 1.0,
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (builder) => bottomSheet(),
                );
              },
              child: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 25.0,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          const Text(
            "Alege o poza de profil",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                icon: const Icon(Icons.camera),
                onPressed: () {
                  takePhoto(ImageSource.camera);
                },
                label: const Text("Camera"),
              ),
              TextButton.icon(
                icon: const Icon(Icons.image),
                onPressed: () {
                  takePhoto(ImageSource.gallery);
                },
                label: const Text("Gallery"),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> takePhoto(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }
}

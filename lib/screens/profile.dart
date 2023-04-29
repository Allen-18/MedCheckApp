import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  ProfileScreenState createState() => ProfileScreenState();
}
class ProfileScreenState extends State<ProfileScreen> {
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _diagnosticController = TextEditingController();

  bool _isLoading = true;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _diagnosticController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }
  Future<void> _fetchProfileData() async {
    //final response = await http.get(Uri.parse('your-url-here'));
    // Parse response data and update text fields using setState
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://example.com/profile'));
      final data = jsonDecode(response.body);

      _idController.text = data['id'];
      _nameController.text = data['name'];
      _diagnosticController.text = data['diagnose'];
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
        leading: const BackButton(), title: const Text('Profil pacient'),
      ),
      body: _isLoading
          ? const Center(child:CircularProgressIndicator())
          : Form(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          children: <Widget>[
            imageProfile(),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _idController,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(
                labelText: 'ID',
                labelStyle: TextStyle(fontSize: 20),
                contentPadding: EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(fontSize: 20),
                contentPadding: EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _diagnosticController,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(
                labelText: 'Diagnose',
                labelStyle: TextStyle(fontSize: 20),
                contentPadding: EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
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
                ? const AssetImage('assets/images/profile.png') as ImageProvider<
                Object>?
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
      width: MediaQuery
          .of(context)
          .size
          .width,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          const Text("Alege o poza de profil",
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
  Widget idTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextFormField(
        initialValue: '01',
        style: const TextStyle(
          fontSize: 20,
        ),
        decoration: const InputDecoration(
          labelText: 'ID',
          labelStyle: TextStyle(
            fontSize: 20,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16.0),
          border: OutlineInputBorder(),
          prefixIcon: Icon(
            Icons.person,
            color: Colors.blue,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }

  Widget nameTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextFormField(
        initialValue: 'Pop Ioana',
        style: const TextStyle(
          fontSize: 20,
        ),
        decoration: const InputDecoration(
          labelText: 'Name',
          labelStyle: TextStyle(
            fontSize: 20,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16.0),
          border: OutlineInputBorder(),
          prefixIcon: Icon(
            Icons.person,
            color: Colors.blue,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }

  Widget diagnosticTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextFormField(
        initialValue: 'BPOC',
        style: const TextStyle(
          fontSize: 20,
        ),
        decoration: const InputDecoration(
          labelText: 'Diagnose',
          labelStyle: TextStyle(
            fontSize: 20,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16.0),
          border: OutlineInputBorder(),
          prefixIcon: Icon(
            Icons.person,
            color: Colors.blue,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }
}

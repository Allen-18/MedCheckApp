import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'menu.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey =
      GlobalKey<FormState>(); // add a form key to validate the form
  String?
      _usernameError; // add error variables for the email and password fields
  String? _passwordError;
  String? _accessToken;
  String? _refreshToken;
  final storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String username, password) async {
    setState(() {
      _usernameError = _validateUsername(_usernameController.text);
      _passwordError = _validatePassword(_passwordController.text);
    });
    if (_usernameError != null || _passwordError != null) {
      if (kDebugMode) {
        print("Error: ${_usernameError ?? ""} ${_passwordError ?? ""}");
      }
      return <String, dynamic>{}; //
    }
    final url =
        Uri.parse('https://medcheck.azurewebsites.net/api/auth/get_token/');
    final body = {
      "username": _usernameController.text,
      "password": _passwordController.text,
    };

    if (kDebugMode) {
      print("Request: ${url.toString()}");
      print("Headers: ${json.encode({'Content-Type': 'application/json'})}");
      print("Body: ${json.encode(body)}");
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final tokenResponse = json.decode(response.body);
        _accessToken = tokenResponse['access'];
        _refreshToken = tokenResponse['refresh'];
        // Store the access token in the secure storage
        await storage.write(key: 'access', value: _accessToken);
        return {
          'access': _accessToken,
          'refresh': _refreshToken,
        };
      } else if (response.statusCode == 401) {
        if (_refreshToken == null) {
          throw Exception('Failed to refresh token: Refresh token is null');
        }

        final refreshUrl = Uri.parse(
            'https://medcheck.azurewebsites.net/api/auth/get_token/refresh/');

        final refreshBody = {
          'refresh': _refreshToken,
        };

        final refreshResponse = await http.post(
          refreshUrl,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(refreshBody),
        );

        if (refreshResponse.statusCode == 200) {
          final tokenResponse = json.decode(refreshResponse.body);
          _accessToken = tokenResponse['access'];
          _refreshToken = tokenResponse['refresh'];
          return {
            'access': _accessToken,
          };
        } else {
          throw Exception(
              'Failed to refresh token: ${refreshResponse.reasonPhrase} ${refreshResponse.body}');
        }
      } else {
        throw Exception(
            'Failed to authenticate user: ${response.reasonPhrase} ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      throw Exception('Failed to authenticate user');
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    } else if (value.length < 4) {
      return 'Please enter a valid username';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (value.length < 4) {
      return 'Your password must be at least 6 characters long';
    }
    return null;
  }

  bool _rememberMe = false;
  _loadRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
    });
  }

  @override
  initState() {
    super.initState();
    _loadRememberMe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text(
            'Login',
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
        ),
        body: SafeArea(
            child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                key: const PageStorageKey("Divider 1"),
                children: <Widget>[
              const SizedBox(
                height: 220.0,
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Icon(
                      Icons.person,
                      size: 175.0,
                    )),
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Username',
                        prefixIcon: const Icon(Icons
                            .person), // Add an icon to the left of the text field
                        filled:
                            true, // Fill the background of the text field with a color
                        border: OutlineInputBorder(
                          // Add a border around the text field
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.cyan,
                            width: 1,
                          ),
                        ),
                      ),
                      validator:
                          _validateUsername, // add validation logic to the email field
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons
                            .password), // Add an icon to the left of the text field
                        filled:
                            true, // Fill the background of the text field with a color
                        border: OutlineInputBorder(
                          // Add a border around the text field
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator:
                          _validatePassword, // add validation logic to the password field
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    ListTile(
                      title: Text(
                        'Remember Me',
                        textScaleFactor: MediaQuery.of(context).textScaleFactor,
                      ),
                      trailing: Switch.adaptive(
                        value: _rememberMe,
                        onChanged: (newValue) async {
                          setState(() {
                            _rememberMe = newValue;
                          });
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setBool('rememberMe', _rememberMe);
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          login(_usernameController.text,
                                  _passwordController.text)
                              .then((result) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MenuScreen(
                                    access: result['access'],
                                    refresh: result['refresh']),
                              ),
                            );
                            // Navigate to the home screen or show a success message
                          }).catchError((error) {
                            // Handle any error that occurs during the login process
                            if (kDebugMode) {
                              print(error.toString());
                            }
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content:
                                  Text('Failed to login. Please try again.'),
                            ));
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Center(
                        child: Text('Login'),
                      ),
                    ),
                  ],
                ),
              ),
            ])));
  }
}

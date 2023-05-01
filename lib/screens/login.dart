import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'menu.dart';

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
        Uri.parse('http://medcheck.azurewebsites.net/api/auth/get_token/');
    final body = {
      "username": _usernameController.text,
      "password": _passwordController.text,
    };

    if (kDebugMode) {
      print("Request: ${url.toString()}");
      print("Headers: ${json.encode({'Content-Type': 'application/json'})}");
      print("Body: ${json.encode(body)}");
      print("Response:${jsonDecode(_accessToken!)}");
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
        return {
          'access': _accessToken,
          'refresh': _refreshToken,
        };
      } else if (response.statusCode == 401) {
        if (_refreshToken == null) {
          throw Exception('Failed to refresh token: Refresh token is null');
        }

        final refreshUrl =
        Uri.parse('http://medcheck.azurewebsites.net/api/auth/get_token/refresh/');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sign Up Api'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(hintText: 'Username'),
                  validator:
                      _validateUsername, // add validation logic to the email field
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(hintText: 'Password'),
                  validator:
                      _validatePassword, // add validation logic to the password field
                ),
                const SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      login(_usernameController.text, _passwordController.text)
                          .then((result) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuScreen(
                              access: result['access'],
                                refresh: result ['refresh']
                            ),
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
                          content: Text('Failed to login. Please try again.'),
                        ));
                      });
                    }
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Center(child: Text('Login')),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

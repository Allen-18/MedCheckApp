import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.contact_mail, color: Colors.redAccent),
            title: const Text('Contacteza-ne'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.login_outlined, color: Colors.redAccent),
            title: const Text("Log Out"),
            onTap: () {
              SystemNavigator.pop(); // Close the app
            },
          ),
        ],
      ),
    );
  }
}

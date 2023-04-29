import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // final _auth = Provider.of<AuthModel>(context, listen: true);
    return Drawer(
      child: SafeArea(
        // color: Colors.grey[50],
        child: ListView(
          children: <Widget>[
            const ListTile(
              leading: Icon(Icons.account_circle),
              //title: Text(
              //_auth.user.firstname + " " + _auth.user.lastname,
              //  textScaleFactor: textScaleFactor,
              //  maxLines: 1,
              //  ),
              //subtitle: Text(
              //  _auth.user.id.toString(),
              //   textScaleFactor: textScaleFactor,
              //    maxLines: 1,
            ),
            // onTap: () {
            //   Navigator.of(context).popAndPushNamed("/myaccount");
            // },
            //),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.info),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text(
                'Settings',
              ),
              onTap: () {
                Navigator.of(context).popAndPushNamed("/settings");
              },
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.arrow_back),
              title: Text(
                'Logout',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

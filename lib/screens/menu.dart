import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key, required access});

  @override
  Widget build(BuildContext context) {
    return _MenuScreen();
  }
}

class _MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar:
                AppBar(leading: const Text(''), title: const Text('App Menu')),
            body: ListView(children: <Widget>[
              Card(
                color: Colors.transparent,
                child: ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  title: Text("Login",
                      style: GoogleFonts.lato(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w800)),
                ),
              ),
              Card(
                color: Colors.transparent,
                child: ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, '/profilePatient');
                  },
                  title: Text("Profil pacient",
                      style: GoogleFonts.lato(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w800)),
                ),
              ),
              Card(
                color: Colors.transparent,
                child: ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, '/calendar', arguments: false);
                  },
                  title: Text("Calendar",
                      style: GoogleFonts.lato(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w800)),
                ),
              ),
              Card(
                color: Colors.transparent,
                child: ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, '/recommendations');
                  },
                  title: Text("Recomandari medic",
                      style: GoogleFonts.lato(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w800)),
                ),
              ),
              Card(
                color: Colors.transparent,
                child: ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, '/activities');
                  },
                  title: Text("Activitati recomandate",
                      style: GoogleFonts.lato(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w800)),
                ),
              ),
              Card(
                color: Colors.transparent,
                child: ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, '/connectArduino');
                  },
                  title: Text("Conectare Arduino",
                      style: GoogleFonts.lato(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w800)),
                ),
              ),
              Card(
                color: Colors.transparent,
                child: ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, '/graphics');
                  },
                  title: Text("Grafice si rapoarte",
                      style: GoogleFonts.lato(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w800)),
                ),
              ),
            ])));
  }
}

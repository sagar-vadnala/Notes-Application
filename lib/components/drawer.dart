import 'package:flutter/material.dart';
import 'package:notes_app/components/drawer_title.dart';
import 'package:notes_app/pages/settings_page.dart';
import 'package:notes_app/tracker/tracker.dart';
import 'package:notes_app/weather/weatherpage.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          // header
          const DrawerHeader(
            child: Icon(Icons.edit),
          ),

          const SizedBox(height: 25,),

          // note title
          DrawerTile(
            title: "N O T E S",
            leading: const Icon(Icons.home),
            onTap: () => Navigator.pop(context),
            ),

            // weather

            DrawerTile(
            title: "W E A T H E R",
            leading: const Icon(Icons.cloud),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => WeatherPage()));
            },
            ),

            //Expense Tracker

            DrawerTile(
            title: "E X P E N S E",
            leading: const Icon(Icons.money),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => Tracker()));
            },
            ),

            // settings title

            DrawerTile(
            title: "S E T T I N G S",
            leading: const Icon(Icons.settings),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
            },
            ),
        ],
      ),
    );
  }
}

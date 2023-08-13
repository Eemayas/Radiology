import 'package:flutter/material.dart';
import 'package:radiology/Pages/Drawer/switchOff_On.dart';
import 'package:radiology/Pages/Settings/settings.dart';

class Drawerr extends StatelessWidget {
  const Drawerr({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text('Drawer Header'),
        ),
        ListTile(
          leading: Icon(
            Icons.home,
          ),
          title: const Text('Home'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(
            Icons.menu_book_sharp,
          ),
          trailing: SwitchScreen(),
          title: const Text('See Solutions'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(
            Icons.settings,
          ),
          title: const Text("Settings"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Settings()),
            );
          },
        ),
      ],
    );
  }
}

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
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          // TODO: ADd image
          child: const Text('Drawer Header'),
        ),
        ListTile(
          leading: const Icon(
            Icons.home,
          ),
          title: const Text('Home'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.menu_book_sharp,
          ),
          trailing: const SwitchScreen(),
          title: const Text('See Solutions'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.settings,
          ),
          title: const Text("Settings"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Settings()),
            );
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class ListTileCard extends StatelessWidget {
  ListTileCard(
      {super.key, required this.title, required this.OnTap, required this.trailing});
  late String title;
  late Function() OnTap;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          trailing: Text(trailing),
          title: Text(title),
          onTap: OnTap,
        ),
        const Divider(
          thickness: 2,
        ),
      ],
      // ),
    );
  }
}

import 'package:flutter/material.dart';

class ListTileCard extends StatelessWidget {
  ListTileCard(
      {required this.title, required this.OnTap, required this.trailing});
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
        Divider(
          thickness: 2,
        ),
      ],
      // ),
    );
  }
}

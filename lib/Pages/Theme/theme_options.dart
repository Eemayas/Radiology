import 'dart:ffi';

import 'package:flutter/material.dart';

import 'components/theme_switcher.dart';

class ThemeOptionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double? _containerWidth = 500;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme & Primary Color Switcher'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 17),
          // width: _containerWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('Theme'),
              ),
              ThemeSwitcher(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('Primary Color'),
              ),
              PrimaryColorSwitcher(),
            ],
          ),
        ),
      ),
    );
  }
}

class S {}

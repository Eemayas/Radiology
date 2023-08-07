// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'components/app_colors_themes.dart';
import 'components/theme_switcher.dart';

class ThemeOptionsPage extends StatelessWidget {
  const ThemeOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Theme & Primary Color Switcher'),
        ),
        body: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.portrait) {
              // Handle portrait orientation
              return Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 17),
                  // width: _containerWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Theme',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      ThemeSwitcher(
                        side: MediaQuery.of(context).size.width / (appThemes.length + 1),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Primary Color',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      PrimaryColorSwitcher(
                        side: MediaQuery.of(context).size.width / (AppColors.primaryColors.length + 1),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              // Handle landscape orientation
              return SingleChildScrollView(
                child: Center(
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
                        ThemeSwitcher(
                          side: MediaQuery.of(context).size.height / (appThemes.length + 1),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text('Primary Color'),
                        ),
                        PrimaryColorSwitcher(
                          side: MediaQuery.of(context).size.height / (AppColors.primaryColors.length + 1),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ));
  }
}

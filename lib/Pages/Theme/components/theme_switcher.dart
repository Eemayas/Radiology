import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Settings/Componet/Provider/theme_provider.dart';
import 'app_colors_themes.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key, required this.side});
  final double side;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
        builder: (c, themeProvider, _) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < appThemes.length; i++)
                  GestureDetector(
                    onTap: appThemes[i].mode == themeProvider.selectedThemeMode ? null : () => themeProvider.setSelectedThemeMode(appThemes[i].mode),
                    child: AnimatedContainer(
                      width: side,
                      height: side,
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: appThemes[i].mode == themeProvider.selectedThemeMode ? Theme.of(context).primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 2, color: Theme.of(context).primaryColor),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(appThemes[i].icon),
                            Text(
                              appThemes[i].title,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ));
  }
}

class PrimaryColorSwitcher extends StatelessWidget {
  final double side;

  const PrimaryColorSwitcher({super.key, required this.side});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (c, themeProvider, _) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < AppColors.primaryColors.length; i++)
            GestureDetector(
              onTap: AppColors.primaryColors[i] == themeProvider.selectedPrimaryColor
                  ? null
                  : () => themeProvider.setSelectedPrimaryColor(AppColors.primaryColors[i]),
              child: Container(
                height: side,
                width: side,
                decoration: BoxDecoration(
                  color: AppColors.primaryColors[i],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: AppColors.primaryColors[i] == themeProvider.selectedPrimaryColor ? 1 : 0,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Theme.of(context).cardColor.withOpacity(0.5),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

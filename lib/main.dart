// ignore_for_file: non_constant_identifier_names, no_leading_underscores_for_local_identifiers
// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:radiology/Pages/Case/case.dart';
import 'package:radiology/Pages/Theme/theme_options_page.dart';
import './Pages/Settings/settings.dart';
import 'Pages/Home/home.dart';
import 'Pages/Settings/Componet/Provider/theme_provider.dart';
import 'Pages/Settings/Componet/Provider/value.dart';

import 'Pages/Theme/components/app_colors_themes.dart';

const APP_NAME = "Radiology";

GoRouter _router = GoRouter(routes: [
  GoRoute(
      name: "home",
      path: "/",
      builder: (BuildContext context, GoRouterState state) {
        return Home();
      },
      routes: [
        GoRoute(
            name: "case",
            path: "case/:case_no",
            builder: (BuildContext context, GoRouterState state) {
              return Case(
                case_no: int.parse(state.params["case_no"]!),
              );
            }),
        GoRoute(
            name: "settings",
            path: "settings",
            builder: (BuildContext context, GoRouterState state) {
              return const Settings();
            }),
      ]),
]);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider();
  await themeProvider.loadSavedPreferences();
  var sensitivityValue = await SensitivityValue.fromSharedPref();
  var resolveValue = await ResolveValue.fromSharedPref();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => themeProvider),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => sensitivityValue),
      ChangeNotifierProvider(create: (_) => resolveValue),
      ChangeNotifierProvider(create: (_) => loadValue())
    ],
    child: Consumer<ThemeProvider>(
      child: ThemeOptionsPage(),
      builder: (c, themeProvider, child) {
        return MaterialPageApp(
          themeProvider: themeProvider,
          child: child,
        );
      },
    ),
  ));
}

class MaterialPageApp extends HookWidget {
  const MaterialPageApp({
    super.key,
    this.themeProvider,
    this.child,
  });
  final themeProvider;
  final child;
  final storage_permission = Permission.storage;
  @override
  Widget build(BuildContext context) {
    useEffect(() {
      checkAndRequestPermissions();
    });

    return MaterialApp.router(
      title: APP_NAME,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      themeMode: themeProvider.selectedThemeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: AppColors.getMaterialColorFromColor(themeProvider.selectedPrimaryColor),
        primaryColor: themeProvider.selectedPrimaryColor,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: AppColors.getMaterialColorFromColor(themeProvider.selectedPrimaryColor),
        primaryColor: themeProvider.selectedPrimaryColor,
      ),
    );
  }

  void checkAndRequestPermissions() async {
    if (await storage_permission.isDenied) {
      storage_permission.request();
    }
  }
}












// class App extends HookWidget {
//   final storage_permission = Permission.storage;
//   const App({super.key});

//   @override
//   Widget build(BuildContext context) {
//     useEffect(() {
//       checkAndRequestPermissions();
//     });

//     return MaterialApp.router(
//       title: APP_NAME,
//       debugShowCheckedModeBanner: false,
//       routerConfig: _router,
//     );
//   }

//   void checkAndRequestPermissions() async {
//     if (await storage_permission.isDenied) {
//       storage_permission.request();
//     }
//   }
// }
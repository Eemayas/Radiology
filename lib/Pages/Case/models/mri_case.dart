// ignore_for_file: non_constant_identifier_names

import 'dart:collection';
import 'dart:io';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:path_provider/path_provider.dart';
import 'package:radiology/Pages/Home/home.dart';
import 'package:radiology/db/objbox.dart';
import 'package:radiology/utils.dart';
import './window.dart';

const BASE_DIR = "/storage/emulated/0/Android";

/// Representation of a Case, all one needs to do is simply pass on the Case Number,
/// it will load the first existing Plane and Window
///
class MRICase {
  /// All possible Planes and Windows within this Case
  List<PlaneStorage> allPlaneStorage;

  /// Represents the current Plane loaded
  PlaneStorage currentPlaneStorage;

  /// Represents the current Window loaded
  WindowStorage currentWindowStorage;

  /// Current Window being loaded
  Window window;

  MRICase(this.allPlaneStorage, this.currentPlaneStorage, this.currentWindowStorage, this.window);

  //static Future<MRICase> fromCaseNumber(int case_no) async {
  static Future<MRICase?> fromCaseDisplayDetails(CaseStorage caseStorage) async {
    List<PlaneStorage> allPlaneStorage = caseStorage.planes.toList();
    PlaneStorage currentPlaneStorage = allPlaneStorage.first;
    WindowStorage currentWindowStorage = currentPlaneStorage.windows.first;

    Window window = await Window.fromImagesDirectory(currentWindowStorage.imagesPath);

    return MRICase(allPlaneStorage, currentPlaneStorage, currentWindowStorage, window);
  }

  Future loadWindow(WindowStorage windowStorage) async {
    window.clean_all();
    window = await Window.fromImagesDirectory(windowStorage.imagesPath);
  }

  Future<void> clean_all() async {
    await window.clean_all();
  }
}

// Type that represents the type of Plane
enum PlaneType {
  axial("axial"),
  sagittal("sagittal"),
  coronal("coronal");

  final String value;

  const PlaneType(this.value);

  static PlaneType? from(String data) {
    switch (data) {
      case "axial":
        return PlaneType.axial;
      case "sagittal":
        return PlaneType.sagittal;
      case "coronal":
        return PlaneType.coronal;
    }
    return null;
  }
}

class CaseDisplay extends StatefulWidget {
  const CaseDisplay({super.key});

  @override
  State<CaseDisplay> createState() => CaseDisplayState();
}

class CaseDisplayState extends State<CaseDisplay> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

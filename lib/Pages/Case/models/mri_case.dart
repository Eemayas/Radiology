// ignore_for_file: non_constant_identifier_names

import 'dart:collection';
import 'dart:io';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:path_provider/path_provider.dart';
import './window.dart';

const BASE_DIR = "/storage/emulated/0/Android";

/// Representation of a Case, all one needs to do is simply pass on the Case Number,
/// it will load the first existing Plane and Window
///
class MRICase {
  /// All possible Planes and Windows within this Case
  HashMap<PlaneType, List<WindowType>> possible_planes_and_windows;

  /// Represents the current Plane loaded
  PlaneType current_plane_type;

  /// Represents the current Window loaded
  WindowType current_window_type;

  /// Current Window being loaded
  Window window;

  MRICase(this.possible_planes_and_windows, this.current_plane_type, this.current_window_type, this.window);

  static Future<MRICase> fromCaseNumber(int case_no) async {
    HashMap<PlaneType, List<WindowType>> possible_cases = await getAllPossibleCases(case_no);

    // Get the first PlaneType and it's WindowType from possible_cases
    PlaneType initial_plane = possible_cases.keys.first;
    WindowType initial_window = possible_cases.values.first.first;

    String dir = "$BASE_DIR/$case_no/${initial_plane.value}/${initial_window.value}";
    Window window = await Window.fromImagesDirectory(dir);
    return MRICase(possible_cases, initial_plane, initial_window, window);
  }

  Future loadWindow(int case_no, PlaneType plane_type, WindowType window_type) async {
    current_plane_type = plane_type;
    current_window_type = window_type;
    window.clean_all();
    window = await Window.fromImagesDirectory("$BASE_DIR/$case_no/${current_plane_type.value}/${current_window_type.value}");
  }

  /// Gets all possible Planes and Windows from the given case no
  static Future<HashMap<PlaneType, List<WindowType>>> getAllPossibleCases(int case_no) async {
    HashMap<PlaneType, List<WindowType>> possible_cases = HashMap<PlaneType, List<WindowType>>();

    Directory base_dir = Directory("$BASE_DIR/$case_no");

    // Gets all the folders within the case number
    List<String> folders = (await base_dir.list().toList()).map((f) => f.path.split("/").last).toList();

    for (String folder in folders) {
      if (folder == PlaneType.axial.value) {
        possible_cases[PlaneType.axial] = List.empty(growable: true);
      } else if (folder == PlaneType.sagittal.value) {
        possible_cases[PlaneType.sagittal] = List.empty(growable: true);
      } else if (folder == PlaneType.coronal.value) {
        possible_cases[PlaneType.coronal] = List.empty(growable: true);
      }
    }

    for (PlaneType key in possible_cases.keys) {
      Directory base_dir = Directory("$BASE_DIR/$case_no/${key.value}");

      List<String> folders = (await base_dir.list().toList()).map((f) => f.path.split("/").last).toList();
      for (String folder in folders) {
        if (folder == WindowType.bone.value) {
          possible_cases[key]?.add(WindowType.bone);
        } else if (folder == WindowType.brain.value) {
          possible_cases[key]?.add(WindowType.brain);
        } else if (folder == WindowType.lung.value) {
          possible_cases[key]?.add(WindowType.lung);
        } else if (folder == WindowType.soft_tissue.value) {
          possible_cases[key]?.add(WindowType.soft_tissue);
        }
      }
    }
    return possible_cases;
  }

  Future<void> clean_all() async {
    window.clean_all();
  }
}

// Type that represents the type of Plane
enum PlaneType {
  axial("axial"),
  sagittal("sagittal"),
  coronal("coronal");

  final String value;

  const PlaneType(this.value);
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

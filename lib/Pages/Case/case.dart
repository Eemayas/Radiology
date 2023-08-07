// ignore_for_file: non_constant_identifier_names, no_leading_underscores_for_local_identifiers, constant_identifier_names, must_be_immutable
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:provider/provider.dart';
import 'package:radiology/Pages/Settings/Componet/Provider/value.dart';
import '../Case/models/mri_case.dart';
import './models/window.dart';

// The base directory where all the cases live,
// this is just for testing purpose
const int DRAG_DIFF = 30;

extension StringExtension on String {
  String capitalizeFirstChar() => substring(0, 1).toUpperCase() + substring(1);
}

class Case extends HookWidget {
  final int case_no;
  int dragYPosition = 0;
  WindowType? current_window;
  PlaneType? current_plane;

  Case({super.key, required this.case_no});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<MRICase?> mri_case = useState(null);
    ValueNotifier<Image?> current_image = useState(null);
    ValueNotifier<bool> showWindowPlaneTabBar = useState(true);
    ValueNotifier<bool> displayDescriptionDialog = useState(false);

    final SensitivityValue sensitivity_value = Provider.of<SensitivityValue>(context);
    final sensitivity = sensitivity_value.svalue;

    final statusbar_height = MediaQuery.of(context).viewPadding.top;

    void onPlaneOrWindowChange(PlaneType selected_plane, WindowType selected_window) {
      if (current_plane != selected_plane && current_window != selected_window) {
        mri_case.value?.loadWindow(case_no, selected_plane, selected_window).then((_) {
          mri_case.value?.window.next().then((img) {
            current_image.value = img;
          });
        });
        current_plane = selected_plane;
        current_window = selected_window;
      }
    }

    void _onVerticalDragStart(DragStartDetails e) {
      dragYPosition = e.globalPosition.dy.round();
    }

    void _onVerticalDragUpdate(DragUpdateDetails e) {
      int currentDragYPosition = e.globalPosition.dy.round();
      int diff = currentDragYPosition - dragYPosition;

      if (diff < -(DRAG_DIFF - sensitivity)) {
        dragYPosition = currentDragYPosition;
        mri_case.value?.window.next().then((img) {
          current_image.value = img;
        });
      } else if (diff > (DRAG_DIFF - sensitivity)) {
        dragYPosition = currentDragYPosition;
        mri_case.value?.window.prev().then((img) {
          current_image.value = img;
        });
      }
    }

    useEffect(() {
      MRICase.fromCaseNumber(case_no).then((_case) {
        mri_case.value = _case;
        mri_case.value?.window.next().then((img) {
          current_image.value = img;
          current_window = mri_case.value?.current_window_type;
          current_plane = mri_case.value?.current_plane_type;
        });
      });
      return () {
        mri_case.value?.clean_all();
      };
    }, []);

    return Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragStart: _onVerticalDragStart,
            onVerticalDragUpdate: _onVerticalDragUpdate,
            child: mri_case.value != null
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(child: current_image.value ?? const Text("Wait")),
                      showWindowPlaneTabBar.value
                          ? WindowPlaneTabBar(
                              possible_planes_and_windows: (mri_case.value?.possible_planes_and_windows)!,
                              onPlaneOrWindowChange: onPlaneOrWindowChange)
                          : const SizedBox.shrink(),
                      Positioned(
                          top: statusbar_height + 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.help_outline_outlined),
                            color: Colors.white,
                            onPressed: () {
                              displayDescriptionDialog.value = !displayDescriptionDialog.value;
                            },
                          )),
                      Positioned(
                          top: statusbar_height + 8,
                          left: 8,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_rounded),
                            color: Colors.white,
                            onPressed: () {},
                          )),
                      DescriptionDialog(
                          display: displayDescriptionDialog.value,
                          data: "[A_BW2021](alsjfd)",
                          onTapLink: (a, b, c) {
                            //
                          })
                    ],
                  )
                : const Text(
                    "Loading right now",
                    style: TextStyle(color: Colors.white),
                  )));
  }
}

class DescriptionDialog extends HookWidget {
  bool display;
  String data;
  Function(String, String?, String) onTapLink;

  DescriptionDialog({this.display = true, required this.data, required this.onTapLink});

  @override
  Widget build(BuildContext context) {
    return display
        ? SizedBox(
            height: 500,
            width: 800,
            child: Dialog(
                child: Markdown(
              data: data,
              onTapLink: onTapLink,
            )),
          )
        : SizedBox.shrink();
  }
}

class WindowPlaneTabBar extends HookWidget {
  /// All the possible planes that can be selected
  final HashMap<PlaneType, List<WindowType>> possible_planes_and_windows;

  // All the current planes available, mapped to a tab bar widget
  final current_planes = <PlaneType, Widget>{};

  // TODO : Make sure it doesnt get called when we select already selected window and its plane
  // Callback when Window or Plane is changed
  final Function(PlaneType selected_plane, WindowType selected_window) onPlaneOrWindowChange;

  WindowPlaneTabBar({super.key, required this.possible_planes_and_windows, required this.onPlaneOrWindowChange}) {
    possible_planes_and_windows.forEach((key, _) {
      current_planes[key] = Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Text(key.value.capitalizeFirstChar(), style: const TextStyle(fontSize: 16)));
    });
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<Map<WindowType, Widget>> current_windows = useState({});
    ValueNotifier<PlaneType> current_plane = useState(current_planes.keys.first);
    ValueNotifier<WindowType?> current_window = useState(null);

    void loadWindowsTabBar(PlaneType plane) {
      possible_planes_and_windows.forEach((_plane, _windows) {
        if (_plane == plane) {
          Map<WindowType, Widget> __windows = {};
          _windows.forEach((window) {
            __windows[window] = Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: Text(
                  window.value.capitalizeFirstChar(),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ));
          });
          current_windows.value = __windows;
          current_window.value = __windows.keys.first;
        }
      });
    }

    void loadPlane(PlaneType plane) {}

    useEffect(() {
      current_plane.value = possible_planes_and_windows.keys.first;
      loadWindowsTabBar(current_plane.value);
      current_window.value = possible_planes_and_windows.values.first.first;
      return null;
    }, []);

    return Positioned(
        bottom: 50,
        child: (current_plane.value != null && current_window.value != null)
            ? Column(
                children: [
                  MaterialSegmentedControl(
                    borderRadius: 12,
                    selectionIndex: current_plane.value,
                    children: current_planes,
                    unselectedColor: Colors.black,
                    selectedColor: Colors.white,
                    onSegmentTapped: (plane) {
                      current_plane.value = plane;
                      loadWindowsTabBar(plane);
                      onPlaneOrWindowChange(current_plane.value, (current_window.value)!);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: current_window.value != null
                        ? MaterialSegmentedControl(
                            borderRadius: 12,
                            children: current_windows.value,
                            selectionIndex: current_window.value,
                            unselectedColor: Colors.black,
                            selectedColor: Colors.white,
                          )
                        : const Text("HERE"),
                  )
                ],
              )
            : const SizedBox.shrink());
  }
}

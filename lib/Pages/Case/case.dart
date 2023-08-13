// ignore_for_file: non_constant_identifier_names, no_leading_underscores_for_local_identifiers, constant_identifier_names, must_be_immutable
import 'dart:collection';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:provider/provider.dart';
import 'package:radiology/Pages/Home/home.dart';
import 'package:radiology/Pages/Settings/Componet/Provider/value.dart';
import 'package:radiology/db/objbox.dart';
import '../Case/models/mri_case.dart';
import './models/window.dart';

// The base directory where all the cases live,
// this is just for testing purpose
const int DRAG_DIFF = 30;

extension StringExtension on String {
  String capitalizeFirstChar() => substring(0, 1).toUpperCase() + substring(1);
}

class Case extends HookWidget {
  final CaseStorage caseStorage;
  int dragYPosition = 0;
  PlaneStorage? currentPlaneStorage;
  WindowStorage? currentWindowStorage;
  AnnotatedImages? annotatedImages;

  Case({super.key, required this.caseStorage});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<MRICase?> mri_case = useState(null);
    ValueNotifier<Image?> current_image = useState(null);
    ValueNotifier<bool> showWindowPlaneTabBar = useState(true);
    ValueNotifier<bool> displayDescriptionDialog = useState(false);
    ValueNotifier<PlaneStorage?> currentPlaneStorage = useState(null);
    ValueNotifier<WindowStorage?> currentWindowStorage = useState(null);

    final SensitivityValue sensitivity_value = Provider.of<SensitivityValue>(context);
    final sensitivity = sensitivity_value.svalue;

    final statusbar_height = MediaQuery.of(context).viewPadding.top;

    void onPlaneOrWindowChange(PlaneStorage selectedPlaneStorage, WindowStorage selectedWindowStorage) {
      if (currentPlaneStorage.value!.planeType != selectedPlaneStorage.planeType &&
          currentWindowStorage.value!.windowType != selectedWindowStorage.windowType) {
        mri_case.value?.loadWindow(selectedWindowStorage).then((_) {
          mri_case.value?.window.next().then((img) {
            current_image.value = img;
          });
        });
        currentPlaneStorage.value = selectedPlaneStorage;
        currentWindowStorage.value = selectedWindowStorage;
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

    Future<void> loadAnnotatedImages(annotatedImageDirectory) async {
      debugPrint("$annotatedImageDirectory");
      annotatedImages = await AnnotatedImages.fromAnnotatedImageDirectory(annotatedImageDirectory);
    }

    useEffect(() {
      debugPrint("${caseStorage.planes.length}");
      MRICase.fromCaseDisplayDetails(caseStorage).then((_case) {
        loadAnnotatedImages(caseStorage.annotatedImagesPath);
        mri_case.value = _case;
        mri_case.value?.window.next().then((img) {
          current_image.value = img;
          currentPlaneStorage.value = mri_case.value?.currentPlaneStorage;
          currentWindowStorage.value = mri_case.value?.currentWindowStorage;
        });
        //  });
        return () {
          mri_case.value?.clean_all();
        };
      });
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
                          ? WindowPlaneTabBar(allPlaneStorage: caseStorage.planes.toList(), onPlaneOrWindowChange: onPlaneOrWindowChange)
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
                          data: caseStorage.description,
                          onTapLink: (text, url, title) {
                            if (url != null && annotatedImages != null) {
                              AnnotatedImage? annotatedImage = annotatedImages!.getImage(url);
                              debugPrint("$annotatedImage");
                              if (annotatedImage != null) {
                                current_image.value = annotatedImage.image;
                              }
                            }
                          })
                    ],
                  )
                : const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )));
  }
}

class AnnotatedImage {
  Image image;

  ImageStreamListener listener;

  ImageStream? imageStream;

  String path;

  AnnotatedImage(this.image, this.listener, this.path);

  static Future<AnnotatedImage> fromPath(String path) async {
    File file = File(path);

    var buf = await file.readAsBytes(); // Represents the buffer of image file
    var image = Image.memory(buf, gaplessPlayback: true);
    var listener = ImageStreamListener((image, synchronousCall) {});
    final annotatedImage = AnnotatedImage(image, listener, path);
    annotatedImage.resolve();
    return annotatedImage;
  }

  /// Resolves the loaded image by adding a listener attached to it, it will
  /// resolve the image and store in the memory
  void resolve() {
    imageStream = image.image.resolve(const ImageConfiguration());
    imageStream?.completer?.addListener(listener);
  }

  /// Unloads from the memory by removing the listener attached to it,
  /// it simply frees the resolved images from the memory
  void unresolve() {
    imageStream?.removeListener(listener);
    imageStream = null;
    image.image.evict().then((value) => {});
  }
}

class AnnotatedImages {
  List<AnnotatedImage> images;

  AnnotatedImages(this.images);

  static Future<AnnotatedImages> fromAnnotatedImageDirectory(String annotatedImageDirectory) async {
    List<AnnotatedImage> images = List.empty(growable: true);

    List<FileSystemEntity> images_paths = await Directory(annotatedImageDirectory).list().toList();

    for (FileSystemEntity e in images_paths) {
      var annotatedImage = await AnnotatedImage.fromPath(e.path);
      images.add(annotatedImage);
      annotatedImage.resolve();
    }

    return AnnotatedImages(images);
  }

  // Gives you the annotatedImage of the "identifier" of the image is in its path
  AnnotatedImage? getImage(String identifier) {
    for (AnnotatedImage annotatedImage in images) {
      if (annotatedImage.path.contains(identifier)) {
        return annotatedImage;
      }
    }
  }
}

class ImageIdentifier {
  PlaneType? plane_type;
  WindowType? window_type;
  int? image_index;

  ImageIdentifier(String url) {
    List<String> parts = url.split(' ');
    plane_type = PlaneType.from(parts[0]);
    window_type = WindowType.from(parts[1]);
    image_index = int.parse(parts[2]);
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
  Map<PlaneStorage, List<WindowStorage>> possible_planes_and_windows = {};

  // All the current planes available, mapped to a tab bar widget
  final current_planes = <PlaneStorage, Widget>{};

  final Function(PlaneStorage selected_plane, WindowStorage selected_window) onPlaneOrWindowChange;

  WindowPlaneTabBar({super.key, required List<PlaneStorage> allPlaneStorage, required this.onPlaneOrWindowChange}) {
    possible_planes_and_windows = {};

    allPlaneStorage.forEach((PlaneStorage planeStorage) {
      List<WindowStorage> allWindowStorage = List.empty(growable: true);
      planeStorage.windows.toList().forEach((WindowStorage windowStorage) {
        allWindowStorage.add(windowStorage);
      });

      possible_planes_and_windows[planeStorage] = allWindowStorage;
    });

    possible_planes_and_windows.forEach((key, _) {
      current_planes[key] = Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Text(key.planeType.capitalizeFirstChar(), style: const TextStyle(fontSize: 16)));
    });
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<Map<WindowStorage, Widget>> current_windows = useState({});
    ValueNotifier<PlaneStorage> current_plane = useState(current_planes.keys.first);
    ValueNotifier<WindowStorage?> current_window = useState(null);

    void loadWindowsTabBar(PlaneStorage plane) {
      possible_planes_and_windows.forEach((_plane, _windows) {
        if (_plane.planeType == plane.planeType) {
          Map<WindowStorage, Widget> __windows = {};
          _windows.forEach((window) {
            __windows[window] = Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: Text(
                  window.windowType.capitalizeFirstChar(),
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

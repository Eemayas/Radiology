import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:radiology/Pages/Case/models/plane.dart';
import 'dart:io';

import 'package:radiology/Pages/Case/models/window.dart';

class MRIImage {
  // Image Widget of the image to be displayed
  Image image;

  /// Index of image within the given Plane Or Window
  int index;

  ImageStreamListener listener;

  ImageStream? imageStream;

  MRIImage(this.image, this.index, this.listener);

  /// This is the core method to create a MRIImage, index and path of the image
  /// is passed as parameter and from those two a MRIImage with bytes of that image file
  /// shall be created
  static Future<MRIImage> fromPathAndIndex(String path, int index) async {
    File file = File(path);

    var buf = await file.readAsBytes(); // Represents the buffer of image file
    var image = Image.memory(buf, gaplessPlayback: true);
    var listener = ImageStreamListener((image, synchronousCall) {});
    return MRIImage(image, index, listener);
  }

  // Creates an empty MRI Image
  static Future<MRIImage> empty() async {
    var listener = ImageStreamListener((image, synchronousCall) {});
    Image image = Image.memory(Uint8List.fromList(List.empty()));
    return MRIImage(image, -1, listener);
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

class AnnotatedImage {
  /// The window type of the annotated image
  WindowType window_type;

  /// The plane type of the annotated image
  PlaneType plane_type;

  // Image Widget of the image to be displayed
  Image image;

  /// Index of image within the given Plane Or Window
  int index;

  ImageStreamListener listener;

  ImageStream? imageStream;

  AnnotatedImage(this.window_type, this.plane_type, this.image, this.index, this.listener);

  static Future<AnnotatedImage> fromPathAndIndex(String path, WindowType windowType, PlaneType planeType, int index) async {
    File file = File(path);

    var buf = await file.readAsBytes(); // Represents the buffer of image file
    var image = Image.memory(buf, gaplessPlayback: true);
    var listener = ImageStreamListener((image, synchronousCall) {});
    final annotatedImage = AnnotatedImage(windowType, planeType, image, index, listener);
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

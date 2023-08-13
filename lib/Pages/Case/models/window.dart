// ignore_for_file: constant_identifier_names, non_constant_identifier_names
/// Type that represents the type of Window
import 'package:flutter/material.dart';
import '../../../utils.dart';
import 'dart:io';

const int IMG_BUF_SIZE = 10;
const int RESOLVE_BUF_SIZE = 10;

enum WindowType {
  soft_tissue("soft_tissue"),
  lung("lung"),
  brain("brain"),
  bone("bone");

  final String value;
  const WindowType(this.value);

  static WindowType? from(String data) {
    switch (data) {
      case "soft_tissue":
        return WindowType.soft_tissue;
      case "lung":
        return WindowType.lung;
      case "brain":
        return WindowType.brain;
      case "bone":
        return WindowType.bone;
    }
    return null;
  }
}

class Window {
  /// Buffer of all images data,
  /// both resolved and unresolved as well for smooth loading
  List<Future<MRIImage>> images;

  /// Ordered list of all paths of images within this Plane
  List<String> paths;

  /// Index the current image being displayed from the buffer
  /// -1 means that it's not pointing to any image
  int index = -1;

  /// Upper index of buffered image data
  int upper_img_buf_index = IMG_BUF_SIZE - 1;

  /// Lower index of buffered image data
  int lower_img_buf_index = 0;

  /// Upper index of resolved image data
  int upper_resolve_buf_index = RESOLVE_BUF_SIZE - 1;

  /// Lower index of resolved image data
  int lower_resolve_buf_index = 0;

  Window(this.images, this.paths);

  /// Creates a Window Instance from directory full of images
  static Future<Window> fromImagesDirectory(String dir) async {
    List<Future<MRIImage>> images = List<Future<MRIImage>>.empty(growable: true);
    List<String> paths = List<String>.empty(growable: true);

    List<FileSystemEntity> images_paths = await Directory(dir).list().toList();

    debugPrint("The total values here are ${images_paths.length}");
    for (FileSystemEntity e in images_paths) {
      paths.add(e.path);
    }
    paths.sort();

    for (var i = 0; i < IMG_BUF_SIZE; i++) {
      var fut = Future(() async {
        var mri_image = await MRIImage.fromPathAndIndex(paths[i], i);
        int lower_triggering_index = (IMG_BUF_SIZE / 2).truncate();
        if (i <= lower_triggering_index) {
          mri_image.resolve();
        }
        return mri_image;
      });
      images.add(fut);
    }

    return Window(images, paths);
  }

  // Checks if any images are there in the queue
  bool areImagesAvailable() {
    return images.isNotEmpty;
  }

  // Initially IMG_BUF_SIZE images data are loaded in the buffer and
  // RESOLVE_BUF_SIZE images are resolved, as the index reaches IMG_BUF_SIZE/2, for every increase
  //in index one new Future will be appended at index of IMG_BUF_SIZE + 1
  Future<Image> next() async {
    MRIImage mri_image;
    int last_index = paths.length - 1;

    if (index == last_index) {
      mri_image = await images.last;
    } else {
      mri_image = await images[++index];
      _cache_next();
      await _resolve_next();
    }

    return mri_image.image;
  }

  Future<Image> prev() async {
    MRIImage mri_image;
    if (index == 0) {
      mri_image = await images.first;
    } else {
      mri_image = await images.elementAt(--index);
      _cache_prev();
      await _resolve_prev();
    }
    debugPrint("While going prev the current index being loaded is $index");
    return mri_image.image;
  }

  /// When next() is triggered, its ran to cache data dynamically.
  /// Let's say we have 1000 paths of images, we can't load the data and resolve all of the images directly,
  /// it will totally blow up the memory.
  ///
  /// So we load the data of IMG_BUF_SIZE = 40 (assume) images and then, as we move up to IMG_BUF_SIZE / 2 images
  /// we simply fill empty data at index 0 and fill new image at IMG_BUF_SIZE + 1
  void _cache_next() {
    /// Assuming that IMG_BUF_SIZE = 40, and RESOLVE_BUF_SIZE = 20
    /// Then caching will be triggered when index is reached at IMG_BUF_SIZE/2
    int lower_triggering_index = (IMG_BUF_SIZE / 2).truncate();
    int last_index = paths.length - 1;

    if (index >= lower_triggering_index && upper_img_buf_index < last_index) {
      // Element at the very lower_img_buf_index is removed i.e at index 0 and lower_img_buf_index is then increased by 1
      // Similarly element at the new upper_img_buf_index + 1 index is add
      images[lower_img_buf_index] = Future(() => MRIImage.empty());
      ++lower_img_buf_index;
      ++upper_img_buf_index;
      if (images.length - 1 > upper_img_buf_index) {
        images[upper_img_buf_index] = Future(() => MRIImage.fromPathAndIndex(paths[upper_img_buf_index], upper_img_buf_index));
      } else {
        images.add(Future(() => MRIImage.fromPathAndIndex(paths[upper_img_buf_index], upper_img_buf_index)));
      }
    }
  }

  /// When next() is triggered, its ran to cache data dynamically
  void _cache_prev() {
    /// Assuming that IMG_BUF_SIZE = 40, and RESOLVE_BUF_SIZE = 20
    /// Then caching will be triggered when index is reached at IMG_BUF_SIZE/2
    int last_index = paths.length - 1;
    int upper_triggering_index = last_index - (IMG_BUF_SIZE / 2).truncate();

    if (index <= upper_triggering_index && lower_img_buf_index > 0) {
      images[upper_img_buf_index] = Future(() => MRIImage.empty());
      --lower_img_buf_index;
      --upper_img_buf_index;
      images[lower_img_buf_index] = Future(() => MRIImage.fromPathAndIndex(paths[lower_img_buf_index], lower_img_buf_index));
    }
  }

  Future _resolve_next() async {
    int lower_triggering_index = (RESOLVE_BUF_SIZE / 2).truncate();
    int last_index = paths.length - 1;

    if (index >= lower_triggering_index && upper_resolve_buf_index < last_index) {
      (await images[lower_resolve_buf_index]).unresolve();
      ++lower_resolve_buf_index;
      ++upper_resolve_buf_index;
      (await images[upper_resolve_buf_index]).resolve();
    }
  }

  Future _resolve_prev() async {
    /// Assuming that IMG_BUF_SIZE = 40, and RESOLVE_BUF_SIZE = 20
    /// Then caching will be triggered when index is reached at IMG_BUF_SIZE/2
    int last_index = paths.length - 1;
    int upper_triggering_index = last_index - (RESOLVE_BUF_SIZE / 2).truncate();

    if (index <= upper_triggering_index && lower_resolve_buf_index > 0) {
      (await images[upper_resolve_buf_index]).unresolve();
      --lower_resolve_buf_index;
      --upper_resolve_buf_index;
      (await images[lower_resolve_buf_index]).resolve();
    }
  }

  Future<void> clean_all() async {
    for (int i = lower_img_buf_index; i <= upper_img_buf_index; i++) {
      (await images[i]).unresolve();
    }
  }
}

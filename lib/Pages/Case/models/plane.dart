// ignore_for_file: non_constant_identifier_names, constant_identifier_names
import 'dart:io';
import 'dart:async';
import '../../../utils.dart';
import 'package:flutter/material.dart';

/// Size of Buffer to store images
int IMG_BUF_SIZE = 30; // Must be even size
int RESOLVE_BUF_SIZE = 10; // Must be even size and less than IMG_BUF_SIZE

enum PlaneType { transverse, coronal, sagittal }

/// A Data Structure representing the plane of a certain case.
///
/// A plane can have different windows within itself
///

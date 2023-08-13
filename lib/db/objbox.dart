import 'package:objectbox/objectbox.dart';
import 'package:radiology/Pages/Case/models/plane.dart';
import 'package:radiology/Pages/Case/models/window.dart';

@Entity()
class CaseStorage {
  @Id()
  int id = 0;

  int caseId;

  String caseTitle;

  String description;

  String annotatedImagesPath;

  var planes = ToMany<PlaneStorage>();

  CaseStorage(this.caseId, this.caseTitle, this.description, this.annotatedImagesPath);
}

@Entity()
class PlaneStorage {
  @Id()
  int id = 0;

  final String planeType;

  var windows = ToMany<WindowStorage>();

  PlaneStorage(this.planeType);
}

@Entity()
class WindowStorage {
  @Id()
  int id = 0;

  String imagesPath;

  final String windowType;

  WindowStorage(this.windowType, this.imagesPath);
}

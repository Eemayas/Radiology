// ignore_for_file: implementation_imports, prefer_const_constructors, use_key_in_widget_constructors, non_constant_identifier_names, unnecessary_brace_in_string_interps, must_be_immutable

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:objectbox/objectbox.dart' as objectbox;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:radiology/Pages/Drawer/drawer.dart';
import 'package:radiology/db/objbox.dart';
import 'package:http/http.dart' as http;
import 'package:radiology/objectbox.g.dart';

const BASE_URL = "http://172.188.28.31:8001/";

class PlaneDisplayDetail {
  int planeId;

  String planeType;

  List<WindowDisplayDetail> windowDisplayDetails;

  PlaneDisplayDetail(this.planeId, this.planeType, this.windowDisplayDetails);
}

class WindowDisplayDetail {
  int windowId;
  String windowType;
  String imagesZipFileLink;

  WindowDisplayDetail(this.windowId, this.windowType, this.imagesZipFileLink);
}

// Details necessary to display cases in Home
class CaseDisplayDetails {
  int caseId;
  String caseTitle;
  String description;
  String annotated_image_zip_file_url;
  DownloadStatus downloadStatus;
  List<PlaneDisplayDetail> planeDisplayDetails;

  CaseDisplayDetails(
      {required this.caseId,
      required this.caseTitle,
      required this.description,
      required this.annotated_image_zip_file_url,
      required this.downloadStatus,
      required this.planeDisplayDetails});

  /// List out all cases from the Server
  static Future<List<CaseDisplayDetails>> fromOnlineCases() async {
    String case_url = "$BASE_URL/cases/case-model-viewset";
    String plane_url = "$BASE_URL/cases/plane-model-view";
    String window_url = "$BASE_URL/cases/window-model-view";

    final case_response = http.get(Uri.parse(case_url));
    final plane_response = http.get(Uri.parse(plane_url));
    final window_response = http.get(Uri.parse(window_url));

    final case_response_json = jsonDecode((await case_response).body);
    final plane_response_json = jsonDecode((await plane_response).body);
    final window_response_json = jsonDecode((await window_response).body);

    List<CaseDisplayDetails> online_cases = List.empty(growable: true);

    for (dynamic response_case in case_response_json) {
      int caseId = response_case["case_id"];
      String caseTitle = response_case["case_title"];
      String description = response_case["description"];
      String annotated_image_zip_file_url = response_case["annotated_image_zip_file"];

      online_cases.add(CaseDisplayDetails(
        caseId: caseId,
        caseTitle: caseTitle,
        description: description,
        annotated_image_zip_file_url: annotated_image_zip_file_url,
        downloadStatus: DownloadStatus.notDownloaded,
        planeDisplayDetails: List.empty(growable: true),
      ));
    }

    for (dynamic response_plane in plane_response_json) {
      int planeId = response_plane["plane_id"];
      String planeType = response_plane["plane_type"];
      int caseId = response_plane["Case"];

      for (CaseDisplayDetails online_case in online_cases) {
        if (online_case.caseId == caseId) {
          online_case.planeDisplayDetails.add(PlaneDisplayDetail(planeId, planeType, List.empty(growable: true)));
        }
      }
    }

    for (dynamic response_window in window_response_json) {
      debugPrint("$response_window");
      int windowId = response_window["window_id"];
      String imagesZipFileLink = response_window["images_zip_file"];
      String windowType = response_window["window_type"];
      int planeId = response_window["Plane"];

      for (CaseDisplayDetails online_case in online_cases) {
        for (PlaneDisplayDetail planeDisplayDetail in online_case.planeDisplayDetails) {
          if (planeDisplayDetail.planeId == planeId) {
            planeDisplayDetail.windowDisplayDetails.add(WindowDisplayDetail(windowId, windowType, imagesZipFileLink));
          }
        }
      }
    }

    return online_cases;
  }
}

Future<List<int>> downloadFile(String url) async {
  var httpClient = http.Client();
  var request = http.Request('GET', Uri.parse(url));
  var response = await httpClient.send(request);

  List<List<int>> chunks = List.empty(growable: true);
  List<int> output = List.empty(growable: true);

  Completer<List<int>> output_completer = Completer<List<int>>();

  response.stream.listen((List<int> chunk) {
    chunks.add(chunk);
  }, onDone: () async {
    for (List<int> chunk in chunks) {
      output.addAll(chunk);
    }
    output_completer.complete(output);
  });

  return output_completer.future;
}

class Home extends HookWidget {
  var solutions = false;

  void goToCase(BuildContext context, CaseStorage caseDisplayDetails) {
    context.goNamed("case", extra: caseDisplayDetails);
  }

  final cases = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    // Using the useState hook to manage a counter
    final all_online_and_downloaded_cases = useState(List<CaseDisplayDetails>.empty(growable: true));

    /// Get the details of downloaded casesv
    Future<void> getOnlineCases() async {
      final all_online_cases = await CaseDisplayDetails.fromOnlineCases();

      final currentAllOnlineAndDownloadedCases = [...all_online_and_downloaded_cases.value]; // Create a copy

      for (CaseDisplayDetails online_case in all_online_cases) {
        bool alreadyAdded = false;
        for (CaseDisplayDetails online_and_downloaded_case in currentAllOnlineAndDownloadedCases) {
          if (online_and_downloaded_case.caseId == online_case.caseId) {
            alreadyAdded = true;
            break;
          }
        }

        if (!alreadyAdded) {
          currentAllOnlineAndDownloadedCases.add(online_case);
        }
      }

      debugPrint("WAS ADDDDDDDDDEDDDdd-2");
      all_online_and_downloaded_cases.value = currentAllOnlineAndDownloadedCases; // Update the state

//      final all_online_cases = await CaseDisplayDetails.fromOnlineCases();
//
//      var current_all_online_and_downloaded_cases = all_online_and_downloaded_cases.value;
//      var current_all_online_and_downloaded_cases_ = all_online_and_downloaded_cases.value;
//      for (CaseDisplayDetails online_case in all_online_cases) {
//        if (all_online_and_downloaded_cases.value.isEmpty) {
//          current_all_online_and_downloaded_cases.add(online_case);
//        } else {
//          for (CaseDisplayDetails online_and_downloaded_case in current_all_online_and_downloaded_cases_) {
//            if (online_and_downloaded_case.caseId != online_case.caseId) {
//              current_all_online_and_downloaded_cases.add(online_case);
//            }
//          }
//        }
//      }
//
//      debugPrint("WAS ADDDDDDDDDEDDDdd-2");
//      all_online_and_downloaded_cases.value = [...current_all_online_and_downloaded_cases];
    }

    /// download a case using it's  case id
    Future<int?> downloadCase(int caseId) async {
      Directory appDirectory = await getApplicationDocumentsDirectory();

      var current_all_online_and_downloaded_cases = all_online_and_downloaded_cases.value;

      int indexOfItemToUpdate = current_all_online_and_downloaded_cases.indexWhere((item) => item.caseId == caseId);
      current_all_online_and_downloaded_cases[indexOfItemToUpdate].downloadStatus = DownloadStatus.downloading;

      current_all_online_and_downloaded_cases = [...current_all_online_and_downloaded_cases];
      all_online_and_downloaded_cases.value = current_all_online_and_downloaded_cases;

      var currentCaseDisplay = current_all_online_and_downloaded_cases[indexOfItemToUpdate];

      Directory annotatedImageDirectory = Directory(join(appDirectory.path, "$caseId", "annotatedImage"));
      await annotatedImageDirectory.create(recursive: true);

      debugPrint("${currentCaseDisplay.annotated_image_zip_file_url}");
      // Download annoated image zip file
      List<int> zipData = await downloadFile(currentCaseDisplay.annotated_image_zip_file_url);
      File zipFile = await File(join(appDirectory.path, "annotatedImage.zip")).create();
      await zipFile.writeAsBytes(zipData);

      try {
        await ZipFile.extractToDirectory(zipFile: zipFile, destinationDir: annotatedImageDirectory);
        //await zipFile.delete();
      } catch (e) {
        debugPrint("Error in decompression");
      }

      // Store through BoxStorage
      CaseStorage caseData =
          CaseStorage(caseId, currentCaseDisplay.caseTitle, currentCaseDisplay.description, annotatedImageDirectory.path);

      for (PlaneDisplayDetail planeDisplayDetail in currentCaseDisplay.planeDisplayDetails) {
        PlaneStorage planeStorage = PlaneStorage(planeDisplayDetail.planeType);
        Directory planeDirectory = Directory(join(appDirectory.path, "$caseId", planeDisplayDetail.planeType));
        await planeDirectory.create(recursive: true);

        for (WindowDisplayDetail windowDisplayDetail in planeDisplayDetail.windowDisplayDetails) {
          Directory windowDirectory = Directory(join(planeDirectory.path, windowDisplayDetail.windowType));
          await windowDirectory.create(recursive: true);

          String imagesZipFileLink = windowDisplayDetail.imagesZipFileLink;

          List<int> zipData = await downloadFile(imagesZipFileLink);
          File zipFile = await File(join(appDirectory.path, "${planeStorage.id}.zip")).create();
          await zipFile.writeAsBytes(zipData);

          try {
            await ZipFile.extractToDirectory(zipFile: zipFile, destinationDir: windowDirectory);
            //await zipFile.delete();
            debugPrint("${windowDirectory.listSync().length}");
          } catch (e) {
            debugPrint("Error in decompression");
          }

          WindowStorage windowStorage = WindowStorage(windowDisplayDetail.windowType, windowDirectory.path);
          planeStorage.windows.add(windowStorage);
        }
        caseData.planes.add(planeStorage);
      }

      current_all_online_and_downloaded_cases[indexOfItemToUpdate].downloadStatus = DownloadStatus.downloaded;

      current_all_online_and_downloaded_cases = [...current_all_online_and_downloaded_cases];
      all_online_and_downloaded_cases.value = current_all_online_and_downloaded_cases;

      objectbox.Store store = context.read<objectbox.Store>();
      store.box<CaseStorage>().put(caseData);
    }

    /// Get the details of downloaded cases
    void getDownloadedCases() {
      objectbox.Store store = context.read<objectbox.Store>();
      List<CaseStorage> all_downloaded_cases = store.box<CaseStorage>().getAll();

      var current_all_online_and_downloaded_cases = all_online_and_downloaded_cases.value;
      for (CaseStorage downloaded_case in all_downloaded_cases) {
        current_all_online_and_downloaded_cases.add(CaseDisplayDetails(
            description: downloaded_case.description,
            caseId: downloaded_case.caseId,
            caseTitle: downloaded_case.caseTitle,
            downloadStatus: DownloadStatus.downloaded,
            planeDisplayDetails: List.empty(growable: true),
            annotated_image_zip_file_url: ""));
      }

      all_online_and_downloaded_cases.value = [...current_all_online_and_downloaded_cases];
    }

    debugPrint("OUTSIDE BRO");
    useEffect(() {
      //var store = context.read<objectbox.Store>();
      getDownloadedCases();
      getOnlineCases();
      debugPrint("GOT BOTH BRo");
      return null;
    }, []);

    return Scaffold(
        drawer: Drawer(child: Drawerr()),
        appBar: AppBar(
          title: Text("Cases List"),
          centerTitle: true,
        ),
        body: all_online_and_downloaded_cases.value.isEmpty
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: <Widget>[
                  for (int i = 0; i < all_online_and_downloaded_cases.value.length; i++)
                    Column(
                      children: [
                        CaseListItem(
                          caseId: all_online_and_downloaded_cases.value[i].caseId,
                          caseTitle: all_online_and_downloaded_cases.value[i].caseTitle,
                          onTap: (caseId) {
                            debugPrint("aldfjasj");
                            objectbox.Store store = context.read<objectbox.Store>();
                            Query<CaseStorage> query = store.box<CaseStorage>().query(CaseStorage_.caseId.equals(caseId)).build();

                            List<CaseStorage> data = query.find();
                            if (data.isNotEmpty) {
                              goToCase(context, data[0]);
                            }
                          },
                          onDownloadTap: (caseId) {
                            downloadCase(caseId);
                          },
                          downloadStatus: all_online_and_downloaded_cases.value[i].downloadStatus,
                        ),
                        Divider(
                          thickness: 1,
                        ),
                      ],
                    ),
                ],
              ));
  }
}

// The DownloadStatus of the case
enum DownloadStatus {
  downloading,
  downloaded,
  notDownloaded,
}

class CaseListItem extends HookWidget {
  int caseId;
  String caseTitle;
  void Function(int) onTap;
  void Function(int)? onDownloadTap;
  DownloadStatus downloadStatus;

  CaseListItem({required this.caseId, required this.caseTitle, required this.onTap, required this.downloadStatus, this.onDownloadTap});

  @override
  Widget build(BuildContext context) {
    debugPrint("alsjfasljfsladj");
    Widget trailingWidget;
    switch (downloadStatus) {
      case DownloadStatus.downloaded:
        trailingWidget = Text("");
        break;
      case DownloadStatus.downloading:
        trailingWidget = CircularProgressIndicator();
        break;
      case DownloadStatus.notDownloaded:
        trailingWidget = IconButton(
          icon: Icon(Icons.arrow_downward),
          color: Colors.black,
          onPressed: () {
            onDownloadTap!(caseId);
          },
        );
        break;
    }

    return ListTile(
      enabled: downloadStatus == DownloadStatus.downloaded,
      onTap: () => onTap(caseId),
      title: Text(
        "Case no ${caseId}",
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: trailingWidget,
      subtitle: Text(caseTitle),
    );
  }
}

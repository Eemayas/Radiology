// ignore_for_file: implementation_imports, prefer_const_constructors, use_key_in_widget_constructors, non_constant_identifier_names, unnecessary_brace_in_string_interps, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:radiology/Pages/Drawer/drawer.dart';

class Home extends HookWidget {
  var solutions = false;
  List<Text> cases = [
    Text("case 1"),
  ];

  void goToCase(BuildContext context, int case_no) {
    context.go("/case/${case_no}");
  }

  void getAllCases() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(child: Drawerr()),
        appBar: AppBar(
          title: Text("Cases List"),
          centerTitle: true,
        ),
        body: ListView(
          children: <Widget>[
            for (int i = 1; i <= cases.length; i++)
              Column(
                children: [
                  CaseListItem(
                    case_no: i,
                    case_details: "This is a case about good and bad things",
                    downloaded: false,
                    onTap: () {
                      goToCase(context, i);
                    },
                  ),
                  Divider(
                    thickness: 2,
                  ),
                ],
              ),
          ],
        ));
  }
}

class CaseListItem extends HookWidget {
  int case_no;
  String case_details;
  bool downloaded;
  bool show_case_details;
  void Function() onTap;

  CaseListItem(
      {required this.case_no, required this.case_details, required this.downloaded, this.show_case_details = false, required this.onTap});

  void download() {}

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        "Case no $case_no",
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(case_details),
    );
  }
}

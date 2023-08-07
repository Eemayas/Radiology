import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const defaultSensitivity = 10;
const defaultResolve = 20;

class SensitivityValue with ChangeNotifier {
  int svalue;

  SensitivityValue(this.svalue);

  // Update sensitivity value and notify the listeners
  void schange(int v) {
    svalue = v;
    setSensitivitySharedPref(v).then((_) => {notifyListeners()});
  }

  static Future<SensitivityValue> fromSharedPref() async {
    var svalue = await SensitivityValue.getSensitivitySharedPref();
    return SensitivityValue(svalue);
  }

  // Set sensitivity value into the SharedPreferences
  static Future<void> setSensitivitySharedPref(int svalue) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt("sensitivity", svalue);
  }

  // Get sensitivity value from SharedPreferences if it already exists
  // and if it doesn't then create one new key with default value
  static Future<int> getSensitivitySharedPref() async {
    var pref = await SharedPreferences.getInstance();

    if (pref.containsKey("sensitivity")) {
      debugPrint("CONTAINS KEY");
      return pref.getInt("sensitivity")!;
    } else {
      debugPrint("HAS NO KEY");
      pref.setInt("sensitivity", defaultSensitivity);
      return defaultSensitivity;
    }
  }
}

class ResolveValue with ChangeNotifier {
  int rvalue;
  ResolveValue(this.rvalue);

  // Update resolve value and notify the listeners
  void rchange(int v) {
    rvalue = v;
    setResolveSharedPref(v).then((_) => {notifyListeners()});
  }

  static Future<ResolveValue> fromSharedPref() async {
    var rvalue = await ResolveValue.getResolveSharedPref();
    return ResolveValue(rvalue);
  }

  // Set resolve value into the SharedPreferences
  static Future<void> setResolveSharedPref(int svalue) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt("sensitivity", svalue);
  }

  // Get resolve value from SharedPreferences if it already exists
  // and if it doesn't then create one new key with default value
  static Future<int> getResolveSharedPref() async {
    var pref = await SharedPreferences.getInstance();

    if (pref.containsKey("resolve")) {
      return pref.getInt("resolve")!;
    } else {
      pref.setInt("resolve", defaultSensitivity);
      return defaultSensitivity;
    }
  }
}

class LesolveValue with ChangeNotifier {
/*  int rvalue;*/
  /*ResolveValue(this.rvalue);*/

  /*// Update resolve value and notify the listeners*/
  /*void rchange(int v) {*/
  /*rvalue = v;*/
  /*setResolveSharedPref(v).then((_) => {notifyListeners()});*/
  /*}*/

  /*static Future<ResolveValue> fromSharedPref() async {*/
  /*var rvalue = await ResolveValue.getResolveSharedPref();*/
  /*return ResolveValue(rvalue);*/
  /*}*/

  /*// Set resolve value into the SharedPreferences*/
  /*static Future<void> setResolveSharedPref(int svalue) async {*/
  /*var prefs = await SharedPreferences.getInstance();*/
  /*prefs.setInt("sensitivity", svalue);*/
  /*}*/

  /*// Get resolve value from SharedPreferences if it already exists*/
  /*// and if it doesn't then create one new key with default value*/
  /*static Future<int> getResolveSharedPref() async {*/
  /*var pref = await SharedPreferences.getInstance();*/

  /*if (pref.containsKey("resolve")) {*/
  /*return pref.getInt("resolve")!;*/
  /*} else {*/
  /*pref.setInt("resolve", defaultSensitivity);*/
  /*return defaultSensitivity;*/
  /*}*/
  /*}*/
}

class loadValue with ChangeNotifier {
  int _lvalue = 1;
  int get lvalue => _lvalue;
  void lchange(int value) {
    _lvalue = value;
    notifyListeners();
  }
}

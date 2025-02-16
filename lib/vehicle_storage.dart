import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'vehicle.dart';

class VehicleStorage {
  static const String _key = 'vehicles';

  static Future<void> saveVehicles(List<Vehicle> vehicles) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = json.encode(vehicles.map((v) => v.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  static Future<List<Vehicle>> loadVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    return _decodeVehicles(jsonString);
  }

  static List<Vehicle> _decodeVehicles(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Vehicle.fromJson(json)).toList();
  }

  static Future<void> importFromJson(String filePath) async {
    final file = File(filePath);
    final jsonString = await file.readAsString();
    final vehicles = _decodeVehicles(jsonString);
    await saveVehicles(vehicles);
  }

  static Future<String> exportToJson(String filePath) async {
    final vehicles = await loadVehicles();
    final jsonString = json.encode(vehicles.map((v) => v.toJson()).toList());
    final file = File(filePath);
    await file.writeAsString(jsonString);
    return filePath;
  }

  static Future<void> importFromJsonString(String jsonString) async {
    final List<dynamic> jsonData = json.decode(jsonString);
    for (var vehicleData in jsonData) {
      await Vehicle.fromJson(vehicleData).save();
    }
  }
}

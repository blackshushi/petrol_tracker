import 'dart:convert';
import 'dart:io';
import 'vehicle_record.dart';
import 'vehicle_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class Vehicle {
  final String vehicleId;
  final String model;
  final String name;
  final String plateNumber;
  List<VehicleRecord> records;
  int? latestMileage;

  Vehicle({
    required this.vehicleId,
    required this.model,
    required this.name,
    required this.plateNumber,
    List<VehicleRecord>? records,
    this.latestMileage,
  }) : records = records ?? [];

  List<VehicleRecord> get sortedRecords {
    final sorted = List<VehicleRecord>.from(records);
    sorted.sort((a, b) => b.mileage.compareTo(a.mileage));
    return sorted;
  }

  Map<String, dynamic> toJson() => {
    'vehicleId': vehicleId,
    'model': model,
    'name': name,
    'plateNumber': plateNumber,
    'records': records.map((r) => r.toJson()).toList(),
    'latestMileage': latestMileage,
  };

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleId: json['vehicleId'].toString(),
      model: json['model'].toString(),
      name: json['name'].toString(),
      plateNumber: json['plateNumber'].toString(),
      records: (json['records'] as List?)
          ?.map((r) => VehicleRecord.fromJson(r))
          .toList() ?? [],
      latestMileage: json['latestMileage'] != null ? int.parse(json['latestMileage'].toString()) : null,
    );
  }

  void updateLatestMileage() {
    if (records.isNotEmpty) {
      latestMileage = records.map((r) => r.mileage).reduce((a, b) => a > b ? a : b);
    }
  }

  static Future<List<Vehicle>> loadAllVehicles() async {
    // Implement this method to load all vehicles from storage
    // This could involve reading from a file or using a database
    // For example:
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/vehicles.json');
    
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Vehicle.fromJson(json)).toList();
    }
    
    return [];
  }

  static Future<void> saveAllVehicles(List<Vehicle> vehicles) async {
    // Implement this method to save all vehicles to storage
    // This could involve writing to a file or using a database
    // For example:
    final jsonList = vehicles.map((v) => v.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/vehicles.json');
    await file.writeAsString(jsonString);
  }

  Future<void> addRecord(VehicleRecord newRecord) async {
    records.add(newRecord);
    updateLatestMileage();
    final allVehicles = await loadAllVehicles();
    final index = allVehicles.indexWhere((v) => v.vehicleId == vehicleId);
    if (index != -1) {
      allVehicles[index] = this;
      await saveAllVehicles(allVehicles);
    } else {
      throw Exception('Vehicle not found');
    }
  }

  Future<void> deleteRecord(VehicleRecord record) async {
    records.remove(record);
    updateLatestMileage();

    final allVehicles = await loadAllVehicles();
    final index = allVehicles.indexWhere((v) => v.vehicleId == vehicleId);
    if (index != -1) {
      allVehicles[index] = this;
      await saveAllVehicles(allVehicles);
    } else {
      throw Exception('Vehicle not found');
    }
  }

  static Future<int> getNextVehicleId() async {
    final allVehicles = await loadAllVehicles();
    return allVehicles.length + 1;
  }

  static Future<void> addNewVehicle(Vehicle newVehicle) async {
    final allVehicles = await loadAllVehicles();
    allVehicles.add(newVehicle);
    await saveAllVehicles(allVehicles);
  }

  double get averageKmPerMoney {
    if (records.isEmpty) {
      print('No records for vehicle $plateNumber');
      return 0;
    }
    
    // Sort records by mileage in descending order
    final sortedRecords = List<VehicleRecord>.from(records)
      ..sort((a, b) => b.mileage.compareTo(a.mileage));
    
    final latestMileage = sortedRecords.first.mileage;
    final firstMileage = sortedRecords.last.mileage;
    final totalDistance = latestMileage - firstMileage;
    
    double totalMoney = records.fold(0, (sum, record) => sum + record.moneyToFill);
    
    if (totalDistance == 0) {
      return 0;
    }
    
    return totalDistance/totalMoney  ;
  }

  static Future<void> deleteVehicle(String vehicleId) async {
    final allVehicles = await loadAllVehicles();
    final index = allVehicles.indexWhere((v) => v.vehicleId == vehicleId);
    if (index != -1) {
      allVehicles.removeAt(index);
      await saveAllVehicles(allVehicles);
    } else {
      throw Exception('Vehicle not found');
    }
  }

  Future<void> save() async {
    List<Vehicle> vehicles = await VehicleStorage.loadVehicles();
    vehicles.add(this);
    await VehicleStorage.saveVehicles(vehicles);
  }

  static Future<void> exportAllData() async {
    List<Vehicle> allVehicles = await loadAllVehicles();
    List<Map<String, dynamic>> vehiclesData = allVehicles.map((v) => v.toJson()).toList();

    final Map<String, dynamic> allData = {
      'vehicles': vehiclesData,
    };

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/all_vehicles_data.json');
    
    await file.writeAsString(jsonEncode(allData));
    print('All data exported to: ${file.path}');
  }

  static Future<void> importData() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      final file = File(filePath);
      if (await file.exists()) {
        String contents = await file.readAsString();
        final data = jsonDecode(contents);
        
        List<Vehicle> allVehicles = await loadAllVehicles();
        List<Vehicle> newVehicles = [];

        for (var vehicleData in data['vehicles']) {
          Vehicle vehicle = Vehicle.fromJson(vehicleData);
          
          int existingIndex = allVehicles.indexWhere((v) => v.vehicleId == vehicle.vehicleId);
          if (existingIndex != -1) {
            // Update existing vehicle
            allVehicles[existingIndex] = vehicle;
          } else {
            // Add new vehicle
            newVehicles.add(vehicle);
          }
        }

        // Add all new vehicles
        allVehicles.addAll(newVehicles);

        // Save all vehicles
        await saveAllVehicles(allVehicles);
        print('Data imported successfully');
      }
    } else {
      // User canceled the picker
    }
  }
}

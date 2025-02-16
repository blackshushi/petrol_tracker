import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'vehicle.dart';
import 'vehicle_details_page.dart';
import 'add_record_page.dart';
import 'vehicle_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.storage.request(); // Request storage permission on startup
  try {
    await Vehicle.loadAllVehicles();
  } catch (e) {
    print('Error initializing sample data: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehicle Storage Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Vehicle>> _vehiclesFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _vehiclesFuture = Vehicle.loadAllVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Mileage Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportData,
          ),
        ],
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: _vehiclesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final vehicles = snapshot.data ?? [];
          return ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VehicleDetailPage(vehicle: vehicle),
                    ),
                  );
                  _refreshData(); // Refresh data after returning from detail page
                },
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8), // Re-added margin
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'vehicle-icon-${vehicle.vehicleId}',
                          child: CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: Icon(Icons.directions_car, color: Colors.blue[800]),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${vehicle.plateNumber} (${vehicle.model})',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(vehicle.name),
                              const SizedBox(height: 4),
                              Text(
                                'Last record: ${vehicle.records.isNotEmpty ? vehicle.records.last.timestamp.toString().split(' ')[0] : 'N/A'}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              Text(
                                'Latest Mileage: ${vehicle.records.isNotEmpty ? vehicle.records.last.mileage.toString() : 'N/A'}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              vehicle.averageKmPerMoney.toStringAsFixed(2),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const Text('\$/km', style: TextStyle(fontSize: 12)),
                            Text('Records: ${vehicle.records.length}', style: const TextStyle(fontSize: 10)),
                          ],
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, vehicle),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRecordPage()),
          );
          if (result == true) {
            _refreshData(); // Refresh data only if a record was added
          }
        },
        tooltip: 'Add Record',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete ${vehicle.name} and all its records?"),
          actions: <Widget>[
            TextButton(
              child: const Text("CANCEL"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("DELETE"),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteVehicle(vehicle);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteVehicle(Vehicle vehicle) {
    Vehicle.deleteVehicle(vehicle.vehicleId).then((_) {
      _refreshData(); // Refresh data after deleting a vehicle
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${vehicle.name} and its records have been deleted')),
      );
    });
  }

  // Update this method for exporting data
  void _exportData() async {
    try {
      await Vehicle.exportAllData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data exported successfully')),
      );
      _refreshData(); // Refresh data after exporting
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export data: $e')),
      );
    }
  }
}

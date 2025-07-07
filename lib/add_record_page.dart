import 'package:flutter/material.dart';
import 'vehicle.dart';
import 'vehicle_record.dart';
import 'vehicle_details_page.dart';

class AddRecordPage extends StatefulWidget {
  const AddRecordPage({super.key, this.vehicle}); // Made vehicle optional

  final Vehicle? vehicle; // Added a field to store the optional vehicle

  @override
  _AddRecordPageState createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  Vehicle? selectedVehicle;
  List<Vehicle> vehicles = [];
  final _formKey = GlobalKey<FormState>();
  final _mileageController = TextEditingController();
  final _moneyToFillController = TextEditingController();
  final _newVehicleNameController = TextEditingController();
  final _newVehicleModelController = TextEditingController();
  final _newVehiclePlateController = TextEditingController();
  
  bool _isAddingNewVehicle = false;
  DateTime _selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      selectedVehicle = widget.vehicle; // Initialize with provided vehicle
    }
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    final loadedVehicles = await Vehicle.loadAllVehicles();
    setState(() {
      vehicles = List<Vehicle>.from(loadedVehicles); // Create a modifiable copy
      if (selectedVehicle == null && vehicles.isNotEmpty) {
        selectedVehicle = vehicles.first; // Default to the first vehicle if none is selected
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Record'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: _importData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Latest Mileage Display
              if (selectedVehicle != null)
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VehicleDetailPage(vehicle: selectedVehicle!)
                        ),
                      );  
                    },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.directions_car_rounded, // Replace with any symbol/icon you prefer
                            size: 48,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            selectedVehicle!.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Latest Mileage: ${selectedVehicle!.latestMileage ?? "N/A"}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date and Time Picker Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        "${_selectedDateTime.year}-${_selectedDateTime.month.toString().padLeft(2, '0')}-${_selectedDateTime.day.toString().padLeft(2, '0')}",
                      ),
                      onPressed: _selectDate,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        "${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}",
                      ),
                      onPressed: _selectTime,
                    ),
                  ),
                ],
              ),
              // Existing dropdown and form fields
              if (!_isAddingNewVehicle) ...[
                DropdownButtonFormField<String>(
                  value: vehicles.map((v) => v.vehicleId).contains(selectedVehicle?.vehicleId)
                      ? selectedVehicle?.vehicleId
                      : null,
                  items: [
                    ...vehicles.map((vehicle) {
                      return DropdownMenuItem<String>(
                        value: vehicle.vehicleId,
                        child: Text(vehicle.name),
                      );
                    }),
                    const DropdownMenuItem<String>(
                      value: 'new_vehicle',
                      child: Text('Add New Vehicle'),
                    ),
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      if (value == 'new_vehicle') {
                        _isAddingNewVehicle = true;
                        selectedVehicle = null;
                      } else {
                        selectedVehicle = vehicles.firstWhere((v) => v.vehicleId == value);
                      }
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Select Vehicle'),
                ),
              ] else ...[
                TextFormField(
                  controller: _newVehicleNameController,
                  decoration: const InputDecoration(labelText: 'New Vehicle Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the vehicle name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _newVehicleModelController,
                  decoration: const InputDecoration(labelText: 'New Vehicle Model'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the vehicle model';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _newVehiclePlateController,
                  decoration: const InputDecoration(labelText: 'New Vehicle Plate Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the vehicle plate number';
                    }
                    return null;
                  },
                ),
              ],
              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(labelText: 'New Mileage'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the new mileage';
                  }
                  final newMileage = int.tryParse(value);
                  if (newMileage == null) {
                    return 'Please enter a valid number';
                  }
                  if (!_isAddingNewVehicle && selectedVehicle != null && 
                      selectedVehicle!.latestMileage != null &&
                      newMileage <= selectedVehicle!.latestMileage!) {
                    print(selectedVehicle!.name);
                    return 'New mileage must be greater than the current mileage';
                  }
                  return null;
                },
              ),
              if(!_isAddingNewVehicle) ...[
                TextFormField(
                  controller: _moneyToFillController,
                  decoration:const InputDecoration(labelText: 'Paid Money'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the money to fill';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Record'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (_isAddingNewVehicle) {
          // Get the next vehicle ID
          int nextId = await Vehicle.getNextVehicleId();
          
          // Create a new vehicle
          final newVehicle = Vehicle(
            vehicleId: nextId.toString(),
            name: _newVehicleNameController.text,
            model: _newVehicleModelController.text,
            plateNumber: _newVehiclePlateController.text,
          );
          await Vehicle.addNewVehicle(newVehicle);
          setState(() {
            vehicles.add(newVehicle); // Add the new vehicle to the list
            selectedVehicle = newVehicle;
            _isAddingNewVehicle = false;
          });
        }

        if (selectedVehicle != null) {
          final newRecord = VehicleRecord(
            mileage: int.parse(_mileageController.text),
            moneyToFill: _moneyToFillController.text.isNotEmpty 
                ? double.parse(_moneyToFillController.text) 
                : 0.0, // Return 0.0 if the text is empty
            timestamp: _selectedDateTime,
          );
          await selectedVehicle!.addRecord(newRecord);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Record added successfully')),
          );
          Navigator.pop(context, true);
        }
      } catch (e, stackTrace) {
        print('Error adding record: $e');
        print('Stack trace: $stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add record: $e')),
        );
      }
    }
  }

  void _importData() async {
    try {
      await Vehicle.importData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data imported successfully')),
      );
      await _loadVehicles(); // Refresh the vehicle list
    } catch (e) {
      print('Error importing data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import data: $e')),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDateTime) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  void dispose() {
    _mileageController.dispose();
    _moneyToFillController.dispose();
    _newVehicleNameController.dispose();
    _newVehicleModelController.dispose();
    _newVehiclePlateController.dispose();
    super.dispose();
  }
}

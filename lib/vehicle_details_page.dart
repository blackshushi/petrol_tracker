import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'vehicle.dart';
import 'vehicle_record.dart';

class VehicleDetailPage extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailPage({Key? key, required this.vehicle}) : super(key: key);

  @override
  _VehicleDetailPageState createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends State<VehicleDetailPage> {
  late List<VehicleRecord> records;

  @override
  void initState() {
    super.initState();
    records = List.from(widget.vehicle.sortedRecords);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle.name),
      ),
      body: records.isEmpty
          ? Center(child: Text('No records found'))
          : ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                final previousRecord = index < records.length - 1 ? records[index + 1] : null;
                final distance = record.distanceSinceLast(previousRecord);
                final efficiency = previousRecord != null
                    ? (distance / record.moneyToFill).toStringAsFixed(2)
                    : 'N/A';

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mileage: ${record.mileage} km',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              SizedBox(height: 8),
                              Text('Money to fill: \$${record.moneyToFill.toStringAsFixed(2)}'),
                              Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(record.timestamp ?? DateTime.now())}'),
                              Text('Distance since last: $distance km'),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Efficiency',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('$efficiency km/\$',
                                style: TextStyle(fontSize: 18, color: Colors.green)),
                            if (index < 2) // Only show delete button for the last two records
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDeleteRecord(context, record),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _confirmDeleteRecord(BuildContext context, VehicleRecord record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this record?"),
          actions: <Widget>[
            TextButton(
              child: Text("CANCEL"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("DELETE"),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteRecord(record);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteRecord(VehicleRecord record) {
    setState(() {
      records.remove(record);
    });
    widget.vehicle.deleteRecord(record).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Record deleted')),
      );
    });
  }
}

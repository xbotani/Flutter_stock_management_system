import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_responsive_dashboard/providers/client_provider.dart';
import 'dart:io';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Client> _filteredClients = [];
  int? _selectedYear;
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _initializeClientData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeClientData() {
    // Ensure the client data is initialized when the page loads
    Provider.of<ClientProvider>(context, listen: false).initializeClients().then((_) {
      setState(() {
        _filteredClients = Provider.of<ClientProvider>(context, listen: false).clients;
      });
    });
  }

  void _deleteClient(Client client) async {
    // Confirm before deletion
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: Text('Do you really want to delete this client?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Call the provider method to delete the client from the database or list
                  await Provider.of<ClientProvider>(context, listen: false).removeClient(client);
                  
                  // Now remove the client from the local list as well
                  setState(() {
                    _filteredClients.remove(client);  // Remove client directly by object reference
                  });
                  Navigator.of(context).pop(); // Close dialog
                } catch (e) {
                  print("Error removing client: $e");
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(  // Wrapping the whole content in a scrollable view
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clients History',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // Years Table
              _selectedYear == null
                  ? _buildYearsTable()
                  : _buildMonthsTable(),
              SizedBox(height: 20),
              // Display Clients for selected Year and Month
              _selectedMonth != null
                  ? _buildClientsForMonth()
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearsTable() {
    final years = _getAvailableYears();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Year:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var year in years)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () => _onYearClicked(year),
                    child: Text('$year'),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<int> _getAvailableYears() {
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    final clients = clientProvider.clients;
    final years = clients
        .map((client) => client.receiptDate.year)
        .toSet()
        .toList()
      ..sort();
    return years;
  }

  void _onYearClicked(int year) {
    setState(() {
      _selectedYear = year;
      _selectedMonth = null; // Reset selected month when a new year is chosen
    });
  }

  Widget _buildMonthsTable() {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Month:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        // Add a back button to navigate back to the years section
        ElevatedButton(
          onPressed: () {
            setState(() {
              _selectedYear = null;
              _selectedMonth = null;
            });
          },
          child: Text('Back to Year Selection'),
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          child: Column(
            children: [
              for (var month in months)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () => _onMonthClicked(month),
                    child: Text(month),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _onMonthClicked(String month) {
    setState(() {
      _selectedMonth = month;
    });
  }

  Widget _buildClientsForMonth() {
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    final clients = clientProvider.clients;

    final monthIndex = _getMonthIndex(_selectedMonth!);
    final filteredClients = clients.where((client) {
      return client.receiptDate.year == _selectedYear &&
          client.receiptDate.month == monthIndex;
    }).toList();

    return filteredClients.isEmpty
        ? Center(child: Text('No clients found for this month.'))
        : SizedBox(
            height: 400, // Adjust the height of the ListView for better layout control
            child: SingleChildScrollView( // Scrollable table
              scrollDirection: Axis.vertical,
              child: Table(
                border: TableBorder.all(),
                columnWidths: {
                  0: FixedColumnWidth(200),
                  1: FixedColumnWidth(200),
                  2: FixedColumnWidth(100),
                  3: FixedColumnWidth(100), // Added column for delete button
                },
                children: [
                  // Header Row
                  TableRow(
                    children: [
                      TableCell(child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
                      )),
                      TableCell(child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Phone", style: TextStyle(fontWeight: FontWeight.bold)),
                      )),
                      TableCell(child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Receipt", style: TextStyle(fontWeight: FontWeight.bold)),
                      )),
                      TableCell(child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold)),
                      )),
                    ],
                  ),
                  // Client Rows
                  for (var client in filteredClients)
                    TableRow(
                      children: [
                        TableCell(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(client.name),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(client.phoneNumber),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () => _viewClientReceipt(client),
                            child: Text("View Receipt"),
                          ),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteClient(client),
                          ),
                        )),
                      ],
                    ),
                ],
              ),
            ),
          );
  }

  int _getMonthIndex(String month) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months.indexOf(month) + 1;
  }

  void _viewClientReceipt(Client client) {
    // Logic to show receipt details or PDF view
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientDetailPage(client: client),
      ),
    );
  }
}

class ClientDetailPage extends StatelessWidget {
  final Client client;

  ClientDetailPage({required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${client.name} Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Client Name: ${client.name}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Phone Number: ${client.phoneNumber}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              'Receipt Date: ${client.receiptDate.toLocal().toString().split(' ')[0]}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Receipt:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            client.receiptPdfPath.isNotEmpty
                ? ElevatedButton(
                    onPressed: () {
                      _openPdfFile(client.receiptPdfPath);
                    },
                    child: Text('View Receipt PDF'),
                  )
                : Text('No receipt available.'),
          ],
        ),
      ),
    );
  }

  void _openPdfFile(String path) {
    // Logic to open the PDF file on Windows desktop
    final file = File(path);
    if (file.existsSync()) {
      // Open the PDF with the default viewer
      Process.run('start', [path], runInShell: true);
    } else {
      print('PDF file not found.');
    }
  }
}

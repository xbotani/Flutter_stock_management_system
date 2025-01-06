import 'package:flutter/material.dart';
import 'package:store_responsive_dashboard/database/database_helper.dart';

/// Updated Client class with an `id` field to match DB 'id'
class Client {
  /// The integer DB primary key id
  final int? id; 

  final String name;
  final String phoneNumber;
  final String receiptPdfPath; // Store PDF path
  final DateTime receiptDate;

  Client({
    this.id,
    required this.name,
    required this.phoneNumber,
    required this.receiptPdfPath, // Ensure receipt path is included
    required this.receiptDate,
  });

  // CopyWith method: so we can create a new Client with a new id
  Client copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? receiptPdfPath,
    DateTime? receiptDate,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      receiptPdfPath: receiptPdfPath ?? this.receiptPdfPath,
      receiptDate: receiptDate ?? this.receiptDate,
    );
  }

  // Convert Client instance to Map for storing in SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Now we include the 'id'
      'name': name,
      'phoneNumber': phoneNumber,
      'receiptPdfPath': receiptPdfPath, // Include PDF path
      'receiptDate': receiptDate.toIso8601String(),
    };
  }

  // Factory method to create Client instance from Map
  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'] as int?, // Parse the integer ID (could be null)
      name: map['name'] as String,
      phoneNumber: map['phoneNumber'] as String,
      receiptPdfPath: map['receiptPdfPath'] as String, 
      receiptDate: DateTime.parse(map['receiptDate'] as String),
    );
  }
}

/// Provider that manages all your Client records
class ClientProvider extends ChangeNotifier {
  List<Client> _clients = [];
  List<Client> get clients => _clients;

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Initialize the client list by loading existing data from the database
  Future<void> initializeClients() async {
    try {
      List<Map<String, dynamic>> clientMaps = await _databaseHelper.getAllClients();
      _clients = clientMaps.map((map) => Client.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      print('Error initializing clients: $e');
    }
  }

  // Method to get all clients
  List<Client> getAllClients() {
    return List<Client>.from(_clients);
  }

  // Add client to the provider and the database
  Future<void> addClient(Client client) async {
    try {
      // Insert into DB:
      int insertedId = await _databaseHelper.insertClient(client.toMap());

      if (insertedId != -1) {
        // We have a real DB ID now, so create a new client with that ID
        final realClient = client.copyWith(id: insertedId);
        _clients.add(realClient);
        notifyListeners();
      }
    } catch (e) {
      print('Error adding client: $e');
    }
  }

  // Remove client from the provider and the database
  Future<void> removeClient(Client client) async {
    try {
      if (client.id == null) {
        // Means we never had a valid ID from the database
        print('Error removing client: client.id is null');
        return;
      }

      int deletedRows = await _databaseHelper.deleteClient(client.id!);
      // If successful, remove from our in-memory list too
      if (deletedRows > 0) {
        // Remove by matching `id` in memory
        _clients.removeWhere((c) => c.id == client.id);
        notifyListeners();
      }
    } catch (e) {
      print('Error removing client: $e');
    }
  }
}

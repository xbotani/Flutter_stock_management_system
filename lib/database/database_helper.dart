import 'package:sqlite3/sqlite3.dart';
import 'dart:io';
import 'package:intl/intl.dart'; // For date formatting

class DatabaseHelper {
  // Singleton pattern: ensures a single instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  Database? _database;

  DatabaseHelper._internal();

  // Getter for the database; initializes if not available
  Database get database {
    if (_database != null) return _database!;
    return _database = _initDatabaseForCurrentDate();
  }

  // Function to get the database file path based on the current date
  String _getDatabasePathForDate(DateTime date) {
    final year = DateFormat('yyyy').format(date);
    final month = DateFormat('MM').format(date);
    final day = DateFormat('dd').format(date);
    final basePath = Directory.current.path;

    // Create nested directories for year and month if they do not exist
    final yearPath = '$basePath\\databases\\$year';
    final monthPath = '$yearPath\\$month';

    if (!Directory(yearPath).existsSync()) {
      Directory(yearPath).createSync(recursive: true);
    }
    if (!Directory(monthPath).existsSync()) {
      Directory(monthPath).createSync(recursive: true);
    }

    // Return the full path to the database file for the specific day
    return '$monthPath\\$day.db';
  }

  Database _initDatabaseForCurrentDate() {
    String dbPath;
    try {
      final currentDate = DateTime.now();
      dbPath = _getDatabasePathForDate(currentDate);
      print("Database path: $dbPath");
      final db = sqlite3.open(dbPath);
      createTables(db);
      return db;
    } catch (e) {
      throw Exception("Failed to initialize database: $e");
    }
  }

  void createTables(Database db) {
    try {
      // Create stockItems table with the new millimeter field
      db.execute('''
        CREATE TABLE IF NOT EXISTS stockItems (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          length REAL,
          width TEXT,
          price REAL,
          quantity INTEGER,
          millimeter TEXT, -- This ensures the millimeter field is present
          unitType TEXT NOT NULL
        )
      ''');

      // Create clients table with receiptPdfPath without dropping existing data
      db.execute('''
        CREATE TABLE IF NOT EXISTS clients (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phoneNumber TEXT NOT NULL,
          receiptPdfPath TEXT NOT NULL,
          receiptDate TEXT NOT NULL
        )
      ''');

      // NEW: Create sales table to record each sale
      db.execute('''
        CREATE TABLE IF NOT EXISTS sales (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          itemId INTEGER,         -- Reference to stockItems.id
          itemName TEXT NOT NULL, -- Store item name for easy access
          quantitySold INTEGER,
          saleAmount REAL,
          saleDate TEXT NOT NULL,
          FOREIGN KEY(itemId) REFERENCES stockItems(id)
        )
      ''');

      print("Tables created successfully or already exist.");
    } catch (e) {
      throw Exception("Failed to create tables: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // STOCK ITEMS CRUD
  // ---------------------------------------------------------------------------

  int insertStockItem(Map<String, dynamic> item) {
    final db = database;
    try {
      final stmt = db.prepare('''
        INSERT INTO stockItems (name, length, width, price, quantity, millimeter, unitType) 
        VALUES (?, ?, ?, ?, ?, ?, ?)
      ''');
      stmt.execute([
        item['name'],
        item['length'],
        item['width'],
        item['price'],
        item['quantity'],
        item['millimeter'], // Include the millimeter field
        item['unitType'],
      ]);
      stmt.dispose();
      return db.lastInsertRowId;
    } catch (e) {
      print("Insert failed: $e");
      return -1; // Indicating failure
    }
  }

  List<Map<String, dynamic>> getAllStockItems() {
    final db = database;
    try {
      final result = db.select('SELECT * FROM stockItems');
      return result
          .map((row) => {
                'id': row['id'],
                'name': row['name'],
                'length': row['length'],
                'width': row['width'],
                'price': row['price'],
                'quantity': row['quantity'],
                'millimeter': row['millimeter'], // Include millimeter field
                'unitType': row['unitType'],
              })
          .toList();
    } catch (e) {
      print("Failed to fetch stock items: $e");
      return []; // Return empty list on failure
    }
  }

  int updateStockItem(Map<String, dynamic> item, int id) {
    final db = database;
    try {
      final stmt = db.prepare('''
        UPDATE stockItems
        SET name = ?, length = ?, width = ?, price = ?, quantity = ?, millimeter = ?, unitType = ?
        WHERE id = ?
      ''');
      stmt.execute([
        item['name'],
        item['length'],
        item['width'],
        item['price'],
        item['quantity'],
        item['millimeter'],
        item['unitType'],
        id,
      ]);
      stmt.dispose();
      return db.getUpdatedRows();
    } catch (e) {
      print("Update failed: $e");
      return -1; // Indicating failure
    }
  }

  int updateStockQuantity(int id, int newQuantity) {
    final db = database;
    try {
      final stmt = db.prepare('UPDATE stockItems SET quantity = ? WHERE id = ?');
      stmt.execute([newQuantity, id]);
      stmt.dispose();
      return db.getUpdatedRows();
    } catch (e) {
      print("Update quantity failed: $e");
      return -1; // Indicating failure
    }
  }

  int deleteStockItem(int id) {
    final db = database;
    try {
      final stmt = db.prepare('DELETE FROM stockItems WHERE id = ?');
      stmt.execute([id]);
      stmt.dispose();
      return db.getUpdatedRows();
    } catch (e) {
      print("Delete failed: $e");
      return -1; // Indicating failure
    }
  }

  // ---------------------------------------------------------------------------
  // CLIENT CRUD
  // ---------------------------------------------------------------------------

  int insertClient(Map<String, dynamic> client) {
    final db = database;
    try {
      final stmt = db.prepare('''
        INSERT INTO clients (name, phoneNumber, receiptPdfPath, receiptDate)
        VALUES (?, ?, ?, ?)
      ''');
      stmt.execute([
        client['name'],
        client['phoneNumber'],
        client['receiptPdfPath'],
        client['receiptDate'],
      ]);
      stmt.dispose();
      return db.lastInsertRowId;
    } catch (e) {
      print("Insert client failed: $e");
      return -1; // Indicating failure
    }
  }

  List<Map<String, dynamic>> getAllClients() {
    final db = database;
    try {
      final result = db.select('SELECT * FROM clients');
      return result
          .map((row) => {
                'id': row['id'],
                'name': row['name'],
                'phoneNumber': row['phoneNumber'],
                'receiptPdfPath': row['receiptPdfPath'],
                'receiptDate': row['receiptDate'],
              })
          .toList();
    } catch (e) {
      print("Failed to fetch clients: $e");
      return [];
    }
  }

  int deleteClient(int id) {
    final db = database;
    try {
      final stmt = db.prepare('DELETE FROM clients WHERE id = ?');
      stmt.execute([id]);
      stmt.dispose();
      return db.getUpdatedRows();
    } catch (e) {
      print("Delete client failed: $e");
      return -1; // Indicating failure
    }
  }

  void deleteAllClients() {}

  // ---------------------------------------------------------------------------
  // SALES TABLE METHODS
  // ---------------------------------------------------------------------------

  // Insert a sale record
  int insertSale(Map<String, dynamic> sale) {
    final db = database;
    try {
      final stmt = db.prepare('''
        INSERT INTO sales (itemId, itemName, quantitySold, saleAmount, saleDate)
        VALUES (?, ?, ?, ?, ?)
      ''');
      stmt.execute([
        sale['itemId'],
        sale['itemName'],
        sale['quantitySold'],
        sale['saleAmount'],
        sale['saleDate'],
      ]);
      stmt.dispose();
      return db.lastInsertRowId;
    } catch (e) {
      print("Insert sale failed: $e");
      return -1;
    }
  }

  // Get all sales records
  List<Map<String, dynamic>> getAllSales() {
    final db = database;
    try {
      // Retrieve all sales, ordered by saleDate descending
      final result = db.select('''
        SELECT
          s.id AS saleId,
          s.itemId,
          s.itemName,
          s.quantitySold,
          s.saleAmount,
          s.saleDate
        FROM sales s
        ORDER BY s.saleDate DESC
      ''');

      return result.map((row) => {
            'saleId': row['saleId'],
            'itemId': row['itemId'],
            'itemName': row['itemName'] ?? 'Unknown Item',
            'quantitySold': row['quantitySold'],
            'saleAmount': row['saleAmount'],
            'saleDate': row['saleDate'],
          }).toList();
    } catch (e) {
      print("Failed to fetch sales: $e");
      return [];
    }
  }

  // Delete a sale record by ID
  int deleteSale(int saleId) {
    final db = database;
    try {
      final stmt = db.prepare('DELETE FROM sales WHERE id = ?');
      stmt.execute([saleId]);
      stmt.dispose();
      return db.getUpdatedRows();
    } catch (e) {
      print("Delete sale failed: $e");
      return -1; 
    }
  }
}

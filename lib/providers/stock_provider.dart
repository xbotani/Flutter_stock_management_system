import 'package:flutter/material.dart';
import '../database/database_helper.dart';

/// A class representing an item in stock.
class StockItem {
  int? id;
  final String name;
  double length;  
  String width;   
  double price;   
  int quantity;   
  String unitType;
  DateTime? saleDate;
  String millimeter;

  StockItem({
    this.id,
    required this.name,
    required this.length,   // double
    required this.width,    // String (e.g. "2*2")
    required this.price,    // double
    required this.quantity, // int
    required this.unitType,
    this.saleDate,
    required this.millimeter,
  });

  StockItem copyWith({
    int? id,
    String? name,
    double? length,
    String? width,
    double? price,
    int? quantity,
    String? unitType,
    DateTime? saleDate,
    String? millimeter,
  }) {
    return StockItem(
      id: id ?? this.id,
      name: name ?? this.name,
      length: length ?? this.length,
      width: width ?? this.width,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unitType: unitType ?? this.unitType,
      saleDate: saleDate ?? this.saleDate,
      millimeter: millimeter ?? this.millimeter,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'length': length,
      'width': width,
      'price': price,
      'quantity': quantity,
      'unitType': unitType,
      'saleDate': saleDate?.toIso8601String(),
      'millimeter': millimeter,
    };
  }

  factory StockItem.fromMap(Map<String, dynamic> map) {
    return StockItem(
      id: map['id'],
      name: map['name'],
      length: (map['length'] is double)
          ? map['length'] as double
          : double.tryParse(map['length'].toString()) ?? 0.0,
      width: map['width']?.toString() ?? '',
      price: (map['price'] is double)
          ? map['price'] as double
          : double.tryParse(map['price'].toString()) ?? 0.0,
      quantity: (map['quantity'] is int)
          ? map['quantity'] as int
          : int.tryParse(map['quantity'].toString()) ?? 0,
      unitType: map['unitType'],
      saleDate: map['saleDate'] != null
          ? DateTime.parse(map['saleDate'])
          : null,
      millimeter: map['millimeter']?.toString() ?? '',
    );
  }
}

/// The provider that tracks stock items, total sales, etc.
class StockProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<StockItem> _stockItems = [];
  double _totalSales = 0.0;
  List<Map<String, dynamic>> _recentActivities = [];

  /// Public getters
  List<StockItem> get stockItems => _stockItems;
  double get totalSales => _totalSales;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;

  /// Fetch stock items from DB.
  Future<void> fetchStockItems() async {
    try {
      final allItems = await _databaseHelper.getAllStockItems();
      _stockItems = allItems.map((map) => StockItem.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      print("Failed to fetch stock items: $e");
    }
  }

  /// (Optional) The old approach for decreasing stock & logging a sale.
  /// If you prefer an explicit method, see `recordSale()` below.
  Future<void> decreaseStockQuantityAfterSale(String name, int soldQuantity) async {
    final itemIndex = _stockItems.indexWhere((item) => item.name == name);
    if (itemIndex != -1) {
      StockItem item = _stockItems[itemIndex];
      final currentQuantity = item.quantity;

      if (currentQuantity >= soldQuantity) {
        final updatedQuantity = currentQuantity - soldQuantity;

        // Add to total sales
        _totalSales += (item.price * soldQuantity);

        // Update saleDate & reduce quantity
        item = item.copyWith(
          quantity: updatedQuantity,
          saleDate: DateTime.now(),
        );

        // Update DB for the stock item
        await _updateStockItem(itemIndex, item);

        // Insert a row in 'sales' table
        final saleRowId = _databaseHelper.insertSale({
          'itemId': item.id,
          'itemName': item.name,
          'quantitySold': soldQuantity,
          'saleAmount': item.price * soldQuantity,
          'saleDate': DateTime.now().toIso8601String(),
        });
        if (saleRowId == -1) {
          print("Insert sale failed from decreaseStockQuantityAfterSale(...)");
        }

        // Add activity
        addActivity('Sold $soldQuantity units of ${item.name}', 'Sale');
      }
    }
  }

  /// **Explicit** method to record a sale (recommended):
  /// 1. Validates item & quantity
  /// 2. Updates totalSales
  /// 3. Reduces item quantity
  /// 4. Writes a 'sales' record
  /// 5. Logs the activity
  Future<void> recordSale({
    required String itemName,
    required int quantitySold,
  }) async {
    final itemIndex = _stockItems.indexWhere((i) => i.name == itemName);
    if (itemIndex == -1) {
      print("recordSale: Item $itemName not found in stock.");
      return;
    }

    final stockItem = _stockItems[itemIndex];

    // Check if enough quantity
    if (stockItem.quantity < quantitySold) {
      print("recordSale: Not enough stock to sell $quantitySold of ${stockItem.name}");
      return;
    }

    // 1) Update total sales
    _totalSales += (stockItem.price * quantitySold);

    // 2) Reduce item quantity, set saleDate
    final updatedQuantity = stockItem.quantity - quantitySold;
    final updatedItem = stockItem.copyWith(
      quantity: updatedQuantity,
      saleDate: DateTime.now(),
    );

    // 3) Update stock item in DB if we have a valid item.id
    if (updatedItem.id != null) {
      await _databaseHelper.updateStockItem(updatedItem.toMap(), updatedItem.id!);
    }

    // 4) Insert a new row in 'sales' table
    final saleId = _databaseHelper.insertSale({
      'itemId': stockItem.id,
      'itemName': stockItem.name,
      'quantitySold': quantitySold,
      'saleAmount': stockItem.price * quantitySold,
      'saleDate': DateTime.now().toIso8601String(),
    });
    if (saleId == -1) {
      print("recordSale: Insert sale failed for $itemName (Q=$quantitySold).");
    } else {
      print("recordSale: Inserted sale with ID=$saleId");
    }

    // 5) Reflect changes in local list
    _stockItems[itemIndex] = updatedItem;
    addActivity('Sold $quantitySold units of ${stockItem.name}', 'Sale');

    notifyListeners();
  }

  /// Update a single stock item in DB by index.
  Future<void> _updateStockItem(int index, StockItem updatedItem) async {
    if (updatedItem.id != null) {
      await _databaseHelper.updateStockItem(updatedItem.toMap(), updatedItem.id!);
      // re-fetch to keep local list in sync
      await fetchStockItems();
      notifyListeners();
    }
  }

  /// Return a list of items considered "low stock"
  List<StockItem> lowStockItems() {
    return _stockItems.where((item) => item.quantity < 5).toList();
  }

  /// Add a text-based activity to the feed
  void addActivity(String description, String movementType) {
    _recentActivities.insert(0, {
      'description': description,
      'date': DateTime.now().toString(),
      'movementType': movementType,
    });
    notifyListeners();
  }

  /// Return the total value of all stock (price * quantity)
  double getTotalStockValue() {
    return _stockItems.fold<double>(0.0, (sum, item) {
      return sum + (item.price * item.quantity);
    });
  }

  /// Example toggling kg <-> lbs
  void toggleUnit(int itemId) {
    final itemIndex = _stockItems.indexWhere((item) => item.id == itemId);
    if (itemIndex != -1) {
      StockItem item = _stockItems[itemIndex];
      final newUnitType = item.unitType == 'kg' ? 'lbs' : 'kg';
      _stockItems[itemIndex] = item.copyWith(unitType: newUnitType);
      notifyListeners();
    }
  }
}

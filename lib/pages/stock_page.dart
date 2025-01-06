import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_responsive_dashboard/constaints.dart';
import 'package:store_responsive_dashboard/providers/stock_provider.dart';
import 'package:store_responsive_dashboard/database/database_helper.dart';

class StockPage extends StatefulWidget {
  const StockPage({Key? key}) : super(key: key);

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController(); 
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _millimeterController = TextEditingController(); // Added controller for millimeters
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Provider.of<StockProvider>(context, listen: false).fetchStockItems();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _millimeterController.dispose(); // Dispose the millimeter controller
    super.dispose();
  }

  Future<void> _addNewItem() async {
    _clearControllers();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(_nameController, 'Item Name'),
                _buildTextField(_lengthController, 'Length (meters)', isNumeric: false),
                _buildTextField(_widthController, 'Width (meters)', isNumeric: false),
                _buildTextField(_millimeterController, 'Length (millimeters)', isNumeric: false),
                _buildTextField(_priceController, 'Price (USD)', isNumeric: false),
                _buildTextField(_quantityController, 'Quantity', isNumeric: false),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_validateInputs()) {
                  try {
                    // Here we assume length, price as double; quantity as int; width, millimeter as string
                    final newItem = StockItem(
                      name: _nameController.text,
                      length: double.tryParse(_lengthController.text) ?? 0.0,  // <-- changed here (parse to double)
                      width: _widthController.text,                             // keep as string
                      price: double.tryParse(_priceController.text) ?? 0.0,    // <-- changed here (parse to double)
                      quantity: int.tryParse(_quantityController.text) ?? 0,   // <-- changed here (parse to int)
                      millimeter: _millimeterController.text,
                      unitType: 'metric',
                    );
                    await _databaseHelper.insertStockItem(newItem.toMap());
                    await Provider.of<StockProvider>(context, listen: false).fetchStockItems();
                    Navigator.of(context).pop();
                  } catch (e) {
                    _showErrorMessage('Failed to add item. Please try again.');
                  }
                } else {
                  _showValidationMessage();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editItem(int index) async {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    final item = stockProvider.stockItems[index];

    _nameController.text = item.name;
    _lengthController.text = item.length.toString();       // <-- changed here (.toString())
    _widthController.text = item.width;
    _priceController.text = item.price.toString();        // <-- changed here (.toString())
    _quantityController.text = item.quantity.toString();  // <-- changed here (.toString())
    _millimeterController.text = item.millimeter;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(_nameController, 'Item Name'),
                _buildTextField(_lengthController, 'Length (meters)', isNumeric: false),
                _buildTextField(_widthController, 'Width (meters)', isNumeric: false),
                _buildTextField(_priceController, 'Price (USD)', isNumeric: false),
                _buildTextField(_quantityController, 'Quantity', isNumeric: false),
                _buildTextField(_millimeterController, 'Length (millimeters)', isNumeric: false),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_validateInputs()) {
                  try {
                    final updatedItem = StockItem(
                      id: item.id,
                      name: _nameController.text,
                      length: double.tryParse(_lengthController.text) ?? 0.0,  // <-- parse to double
                      width: _widthController.text, 
                      price: double.tryParse(_priceController.text) ?? 0.0,    // <-- parse to double
                      quantity: int.tryParse(_quantityController.text) ?? 0,   // <-- parse to int
                      millimeter: _millimeterController.text,
                      unitType: item.unitType,
                    );
                    await _databaseHelper.updateStockItem(updatedItem.toMap(), item.id!);
                    await stockProvider.fetchStockItems();
                    Navigator.of(context).pop();
                  } catch (e) {
                    _showErrorMessage('Failed to update item. Please try again.');
                  }
                } else {
                  _showValidationMessage();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteItem(int index) async {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    final item = stockProvider.stockItems[index];

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: Text('Are you sure you want to delete ${item.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  if (item.id != null) {
                    await _databaseHelper.deleteStockItem(item.id!);
                    await stockProvider.fetchStockItems();
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  _showErrorMessage('Failed to delete item. Please try again.');
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stockProvider = Provider.of<StockProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Management'),
        backgroundColor: primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.warning, color: Colors.red),
            onPressed: _showLowStockItems,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(componentPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Stock Levels Overview',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: componentPadding),
            Wrap(
              spacing: componentPadding,
              runSpacing: componentPadding,
              children: [
                GestureDetector(
                  onTap: _showTotalItems,
                  child: _buildStockSummaryCard(
                    title: 'Total Items',
                    content: '${stockProvider.stockItems.length}',
                    icon: Icons.inventory,
                    color: Colors.blue.shade100,
                  ),
                ),
                GestureDetector(
                  onTap: _showLowStockItems,
                  child: _buildStockSummaryCard(
                    title: 'Low Stock',
                    content: '${stockProvider.lowStockItems().length}',
                    icon: Icons.warning,
                    color: Colors.red.shade100,
                  ),
                ),
              ],
            ),
            SizedBox(height: componentPadding),
            Expanded(
              child: ListView.builder(
                itemCount: stockProvider.stockItems.length,
                itemBuilder: (context, index) {
                  final item = stockProvider.stockItems[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Length: ${item.length} '
                              '${item.unitType == 'metric' ? 'meters' : ''}'),
                          Text('Width: ${item.width} '
                              '${item.unitType == 'metric' ? 'meters' : ''}'),
                          Text('Price: \$${item.price} per unit'),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Quantity in Stock: ${item.quantity}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _editItem(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteItem(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewItem,
        child: const Icon(Icons.add),
        backgroundColor: primary,
      ),
    );
  }

  Widget _buildStockSummaryCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.black54),
          SizedBox(width: componentPadding),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                content,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLowStockItems() {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    final lowStock = stockProvider.lowStockItems();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Low Stock Items'),
          content: lowStock.isEmpty
              ? const Text('No items are running low on stock.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: lowStock
                      .map((item) => Text('${item.name}: ${item.quantity} left'))
                      .toList(),
                ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showTotalItems() {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Total Items in Stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: stockProvider.stockItems
                .map((item) => Text('${item.name}: ${item.quantity} units'))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _clearControllers() {
    _nameController.clear();
    _lengthController.clear();
    _widthController.clear();
    _priceController.clear();
    _quantityController.clear();
    _millimeterController.clear(); // Clear the millimeter controller
  }

  bool _validateInputs() {
    // Ensure each field is non-empty
    return _nameController.text.isNotEmpty &&
        _lengthController.text.isNotEmpty &&
        _widthController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _quantityController.text.isNotEmpty;
  }

  void _showValidationMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please fill all the fields with valid values.'),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText, {
    bool isNumeric = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      // length, width can be text, price, quantity are numeric but we parse later
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
    );
  }
}

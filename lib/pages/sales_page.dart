import 'package:flutter/material.dart';
import 'package:store_responsive_dashboard/constaints.dart';
import 'package:store_responsive_dashboard/database/database_helper.dart';
import 'package:intl/intl.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({Key? key}) : super(key: key);

  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _allSales = [];
  bool _isLoading = true;

  /// Which year the user selected (null if not yet picked)
  int? _selectedYear;

  /// Which month the user selected (null if not yet picked)
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _loadAllSalesData();
  }

  /// Loads *all* sales from the DB and puts them in `_allSales`.
  /// We'll then let the user pick the year, then the month, then see
  /// the final table of sales for that month.
  Future<void> _loadAllSalesData() async {
    try {
      final allSales = _dbHelper.getAllSales();
      setState(() {
        _allSales = allSales;
        _isLoading = false;
      });
    } catch (e) {
      print("Failed to fetch sales data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// If the user wants to refresh the data
  Future<void> _refreshSalesData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadAllSalesData();
  }

  /// Called when the user picks a Year
  void _onYearSelected(int year) {
    setState(() {
      _selectedYear = year;
      _selectedMonth = null; // Reset month when new year is chosen
    });
  }

  /// Called when the user picks a Month name
  void _onMonthSelected(String month) {
    setState(() {
      _selectedMonth = month;
    });
  }

  /// Helper: Return list of unique years from `_allSales`
  List<int> _getAvailableYears() {
    // Parse each saleDate from the DB row, gather the year, dedupe
    final years = <int>{};

    for (var sale in _allSales) {
      final rawDate = sale['saleDate'] ?? '';
      DateTime? parsed;
      try {
        parsed = DateTime.parse(rawDate);
      } catch (_) {
        parsed = null;
      }
      if (parsed != null) {
        years.add(parsed.year);
      }
    }

    // Sort ascending
    final yearList = years.toList()..sort();
    return yearList;
  }

  /// The months we’ll display in order
  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  /// Show a "Select Year" layout if `_selectedYear` is not chosen yet
  /// else show "Select Month" layout. Then if `_selectedMonth` is chosen,
  /// show the actual sales table for that month.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Records'),
        backgroundColor: primary, // from your constaints.dart
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    // If no sales at all
    if (_allSales.isEmpty) {
      return const Center(
        child: Text('No sales have been recorded yet.'),
      );
    }

    // If not selected a year
    if (_selectedYear == null) {
      return _buildYearSelection();
    }

    // If the user selected a year but not a month
    if (_selectedMonth == null) {
      return _buildMonthSelection();
    }

    // If the user picked both year & month
    return _buildSalesForMonth();
  }

  /// Step 1) Display a row of buttons (or a list) of all available years
  Widget _buildYearSelection() {
    final years = _getAvailableYears();
    if (years.isEmpty) {
      return const Center(
        child: Text('No sales data found for any year.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(componentPadding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Year:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: years.map((year) {
                return ElevatedButton(
                  onPressed: () => _onYearSelected(year),
                  child: Text('$year'),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Step 2) After user picks a year, show a "Back" button + list of months.
  Widget _buildMonthSelection() {
    return Padding(
      padding: const EdgeInsets.all(componentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Back to Years" button
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedYear = null; // go back to year selection
                _selectedMonth = null;
              });
            },
            child: const Text('Back to Year Selection'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select Month:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _monthNames.map((month) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ElevatedButton(
                      onPressed: () => _onMonthSelected(month),
                      child: Text(month),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Step 3) Display the actual sales for the chosen year & month in a scrollable table
  Widget _buildSalesForMonth() {
    // If we’re here, both `_selectedYear` and `_selectedMonth` are non-null
    // figure out the month index
    final monthIndex = _monthNames.indexOf(_selectedMonth!) + 1;

    // Filter `_allSales` for matching year/month
    final filtered = _allSales.where((sale) {
      final rawDate = sale['saleDate'] ?? '';
      DateTime? parsed;
      try {
        parsed = DateTime.parse(rawDate);
      } catch (_) {
        parsed = null;
      }
      if (parsed == null) return false;

      return (parsed.year == _selectedYear) && (parsed.month == monthIndex);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(componentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Back to Month" button
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedMonth = null; // go back to month selection
              });
            },
            child: const Text('Back to Month Selection'),
          ),
          const SizedBox(height: 16),
          Text(
            'Sales for $_selectedMonth $_selectedYear',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          filtered.isEmpty
              ? const Text('No sales recorded for this month.')
              : Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshSalesData,
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final sale = filtered[index];
                        final saleId      = sale['saleId'] ?? '';
                        final itemName    = sale['itemName'] ?? 'Unknown Item';
                        final quantity    = sale['quantitySold'] ?? 0;
                        final saleAmount  = sale['saleAmount'] ?? 0.0;
                        final rawDate     = sale['saleDate'] ?? '';

                        // parse date
                        DateTime? parsed;
                        try {
                          parsed = DateTime.parse(rawDate);
                        } catch (_) {
                          parsed = null;
                        }
                        final dateString = parsed != null
                            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(parsed)
                            : 'Unknown Date';

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade50,
                              child: const Icon(
                                Icons.receipt_long,
                                color: Colors.blueAccent,
                              ),
                            ),
                            title: Text(
                              'Sale #$saleId - $itemName',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Quantity Sold: $quantity'),
                                Text('Amount: \$${saleAmount.toStringAsFixed(2)}'),
                                Text('Date & Time: $dateString'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDeleteSale(saleId),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  /// Confirm before deleting a sale
  void _confirmDeleteSale(dynamic saleId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Sale'),
        content: const Text('Are you sure you want to delete this sale record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _deleteSale(saleId);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSale(dynamic saleId) async {
    try {
      final result = _dbHelper.deleteSale(saleId);
      if (result != -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sale deleted successfully')),
        );
        await _refreshSalesData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete sale')),
        );
      }
    } catch (e) {
      print("Error deleting sale: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while deleting the sale')),
      );
    }
  }
}

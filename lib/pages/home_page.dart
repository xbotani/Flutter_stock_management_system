import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_responsive_dashboard/providers/stock_provider.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:store_responsive_dashboard/providers/client_provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
// This import requires you to have added `pdf_google_fonts` in your pubspec.yaml:

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KOREK STEEL',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSans',
                ),
              ),
              SizedBox(height: 20),
              CustomerInformationForm(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomerInformationForm extends StatefulWidget {
  @override
  _CustomerInformationFormState createState() =>
      _CustomerInformationFormState();
}

class _CustomerInformationFormState extends State<CustomerInformationForm> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  int _quantity = 1; // quantity is int
  String? _selectedItem; // We'll store the chosen dropdown item here
  final List<Item> _addedItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch stock items after the first frame
      Provider.of<StockProvider>(context, listen: false).fetchStockItems();
    });
  }

  void _addItem() {
    if (_selectedItem != null) {
      final stockProvider = Provider.of<StockProvider>(context, listen: false);
      // Find the chosen stock item by name
      final item = stockProvider.stockItems.firstWhere(
        (element) => element.name == _selectedItem,
      );

      setState(() {
        _addedItems.add(
          Item(
            name: item.name,
            length: item.length.toString(),  // Convert double -> String
            width: item.width,               // Already String
            price: item.price.toString(),    // Convert double -> String
            millimeter: item.millimeter,     // String
            quantity: _quantity,             // int
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an item to add.'),
        ),
      );
    }
  }

  Future<String> _saveClientAndReceipt() async {
    final clientName = _fullNameController.text;
    final phoneNumber = _phoneNumberController.text;
    final receiptPath = await _captureReceiptImage();

    final client = Client(
      name: clientName,
      phoneNumber: phoneNumber,
      receiptPdfPath: receiptPath,
      receiptDate: DateTime.now(),
    );

    // Add the new client to the provider
    await Provider.of<ClientProvider>(context, listen: false).addClient(client);
    return receiptPath;
  }

  Future<String> _captureReceiptImage() async {
    try {
      final pdf = pw.Document();

      // Use PdfGoogleFonts to load Kurdish & Latin fonts
      final kurdishFont = await PdfGoogleFonts.notoNaskhArabicRegular();
      final kurdishBold = await PdfGoogleFonts.notoNaskhArabicBold();
      final regularFont = await PdfGoogleFonts.robotoRegular();
      final boldFont = await PdfGoogleFonts.robotoBold();

      final pageFormat = PdfPageFormat.a4.copyWith(
        marginLeft: 40,
        marginRight: 40,
        marginTop: 40,
        marginBottom: 40,
      );

      final now = DateTime.now();
      final receiptNumber = 'R${now.millisecondsSinceEpoch}';

      pdf.addPage(
        pw.MultiPage(
          pageFormat: pageFormat,
          maxPages: 1,
          build: (pw.Context context) {
            return [
              // Main container for the entire PDF page
              pw.Container(
                width: pageFormat.availableWidth,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    // Company Title
                    pw.Center(
                      child: pw.Column(
                        children: [
                          pw.Text(
                            'KOREK STEEL',
                            style: pw.TextStyle(
                              font: boldFont,
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'کۆرەک ستیل',
                            textDirection: pw.TextDirection.rtl,
                            style: pw.TextStyle(
                              font: kurdishBold,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 20),

                    // Some top-level info (phone, receipt #, date)
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Phone: +9647504456524',
                          style: pw.TextStyle(font: regularFont),
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              'Receipt #: $receiptNumber',
                              style: pw.TextStyle(font: boldFont),
                            ),
                            pw.Text(
                              'Date: ${now.toString()}',
                              style: pw.TextStyle(font: regularFont),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    pw.Divider(),
                    pw.SizedBox(height: 10),

                    // Customer Information Section
                    pw.Text(
                      'Customer Name:',
                      style: pw.TextStyle(font: boldFont),
                    ),
                    pw.Text(
                      'ناوی کڕیار',
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(font: kurdishFont),
                    ),
                    // Customer's name from input
                    pw.Text(
                      _fullNameController.text,
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(font: kurdishFont),
                    ),

                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Phone Number:',
                      style: pw.TextStyle(font: boldFont),
                    ),
                    pw.Text(
                      'ژمارەی پەیوەندی',
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(font: kurdishFont),
                    ),
                    // Phone number from input
                    pw.Text(
                      _phoneNumberController.text,
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(font: kurdishFont),
                    ),

                    pw.SizedBox(height: 20),

                    // Table for Items
                    pw.Table(
                      border: pw.TableBorder.all(),
                      children: [
                        // Header Row
                        pw.TableRow(
                          children: [
                            pw.Column(
                              children: [
                                pw.Text(
                                  'Item',
                                  style: pw.TextStyle(font: boldFont),
                                ),
                                pw.Text(
                                  'کاڵا',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(font: kurdishFont),
                                ),
                              ],
                            ),
                            pw.Column(
                              children: [
                                pw.Text(
                                  'Millimeter',
                                  style: pw.TextStyle(font: boldFont),
                                ),
                                pw.Text(
                                  'ملم',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(font: kurdishFont),
                                ),
                              ],
                            ),
                            pw.Column(
                              children: [
                                pw.Text(
                                  'Qty',
                                  style: pw.TextStyle(font: boldFont),
                                ),
                                pw.Text(
                                  'بڕ',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(font: kurdishFont),
                                ),
                              ],
                            ),
                            pw.Column(
                              children: [
                                pw.Text(
                                  'Dimension',
                                  style: pw.TextStyle(font: boldFont),
                                ),
                                pw.Text(
                                  'قەبارە',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(font: kurdishFont),
                                ),
                              ],
                            ),
                            pw.Column(
                              children: [
                                pw.Text(
                                  'Unit Price',
                                  style: pw.TextStyle(font: boldFont),
                                ),
                                pw.Text(
                                  'نرخی یەکە',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(font: kurdishFont),
                                ),
                              ],
                            ),
                            pw.Column(
                              children: [
                                pw.Text(
                                  'Total Price',
                                  style: pw.TextStyle(font: boldFont),
                                ),
                                pw.Text(
                                  'نرخی گشتی',
                                  textDirection: pw.TextDirection.rtl,
                                  style: pw.TextStyle(font: kurdishFont),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Rows for each item in _addedItems
                        ..._addedItems.map(
                          (item) => pw.TableRow(
                            children: [
                              pw.Text(
                                item.name,
                                textAlign: pw.TextAlign.center,
                                textDirection: pw.TextDirection.rtl,
                                style: pw.TextStyle(font: kurdishFont),
                              ),
                              pw.Text(
                                item.millimeter,
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(font: regularFont),
                              ),
                              pw.Text(
                                '${item.quantity}',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(font: regularFont),
                              ),
                              pw.Text(
                                '${item.length} x ${item.width}',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(font: regularFont),
                              ),
                              pw.Text(
                                // String price
                                '${item.price}',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(font: regularFont),
                              ),
                              pw.Text(
                                // Convert string price to double
                                '${(double.tryParse(item.price) ?? 0.0) * item.quantity}',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(font: regularFont),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 20),

                    // Summation of item prices
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Total Price: \$${_addedItems.fold<double>(
                            0.0,
                            (sum, item) =>
                                sum +
                                ((double.tryParse(item.price) ?? 0.0) *
                                    item.quantity),
                          )}',
                          style: pw.TextStyle(font: boldFont),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Text(
                          'نرخی گشتی',
                          textDirection: pw.TextDirection.rtl,
                          style: pw.TextStyle(font: kurdishFont),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 30),

                    // Signature
                    pw.Align(
                      alignment: pw.Alignment.topLeft,
                      child: pw.Column(
                        children: [
                          pw.Text(
                            'Signature and Stamp',
                            style: pw.TextStyle(font: boldFont),
                          ),
                          pw.Text(
                            'واژۆ و مۆر',
                            textDirection: pw.TextDirection.rtl,
                            style: pw.TextStyle(font: kurdishFont),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      // Save final PDF to a local file
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/receipt_${now.millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    } catch (e) {
      print("Error saving receipt: $e");
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StockProvider>(
      builder: (context, stockProvider, child) {
        final _items = stockProvider.stockItems;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              SizedBox(height: 4),
              TextField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixText: '+964 ',
                ),
                maxLength: 11,
              ),
              SizedBox(height: 16),

              // Items dropdown
              _items.isEmpty
                  ? const CircularProgressIndicator()
                  : DropdownButton<String>(
                      value: _selectedItem,
                      hint: const Text('Select Item'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedItem = newValue;
                        });
                      },
                      items: _items.map((StockItem item) {
                        return DropdownMenuItem<String>(
                          value: item.name,
                          child: Text(item.name),
                        );
                      }).toList(),
                    ),
              SizedBox(height: 8),

              // Quantity
              Container(
                width: 100,
                child: Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_drop_up),
                      onPressed: () {
                        setState(() {
                          _quantity++;
                        });
                      },
                    ),
                    TextField(
                      controller: TextEditingController(text: '$_quantity'),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _quantity = int.tryParse(value) ?? 1;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_drop_down),
                      onPressed: () {
                        setState(() {
                          if (_quantity > 1) _quantity--;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),

              // Add item button
              ElevatedButton(
                onPressed: _addItem,
                child: const Text('Add Item'),
              ),

              // List of added items
              if (_addedItems.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _addedItems.map((item) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.name} - ${item.quantity} units, '
                            'Dimensions: ${item.length}m x ${item.width}m, '
                            '\$${item.price}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => setState(() {
                            _addedItems.remove(item);
                          }),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              SizedBox(height: 16),

              // Save & Print Button
              ElevatedButton(
                onPressed: _addedItems.isEmpty
                    ? null
                    : () async {
                        // 1) Generate & store PDF for client
                        final filePath = await _saveClientAndReceipt();
                        _navigateToReceipt(context, filePath);

                        // 2) Record the sale in the DB for each item
                        final stockProvider =
                            Provider.of<StockProvider>(context, listen: false);
                        for (var item in _addedItems) {
                          /// Instead of "decreaseStockQuantityAfterSale", we explicitly call
                          /// something like `recordSale(...)`:
                          await stockProvider.recordSale(
                            itemName: item.name,
                            quantitySold: item.quantity,
                          );
                        }

                        // Clear local items
                        setState(() {
                          _addedItems.clear();
                        });
                      },
                child: const Text('Save and Print Receipt'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToReceipt(BuildContext context, String filePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptPreviewPage(filePath: filePath),
      ),
    );
  }
}

// For PDF preview
class ReceiptPreviewPage extends StatelessWidget {
  final String filePath;

  ReceiptPreviewPage({required this.filePath});

  Future<Uint8List> _getPdfBytes() async {
    final file = File(filePath);
    return await file.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Receipt Preview"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<Uint8List>(
        future: _getPdfBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading receipt"));
          } else {
            final pdfBytes = snapshot.data!;
            return PdfPreview(
              build: (format) => pdfBytes,
              maxPageWidth: 700,
            );
          }
        },
      ),
    );
  }
}

// The Item class uses string-based length/width/price for freedom of input
class Item {
  final String name;
  final String length;
  final String width;
  final String price;
  final String millimeter;
  final int quantity;

  Item({
    required this.name,
    required this.length,
    required this.width,
    required this.price,
    required this.millimeter,
    this.quantity = 1,
  });
}

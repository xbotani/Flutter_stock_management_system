import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_responsive_dashboard/providers/stock_provider.dart';
import '../constaints.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(componentPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Key Metrics Section
              _buildKeyMetrics(),

              SizedBox(height: componentPadding),

              // Recently Added Items
              _buildRecentlyAddedItems(),

              SizedBox(height: componentPadding),

              // Recent Activity Feed
              _buildRecentActivityFeed(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return Consumer<StockProvider>(
      builder: (context, stockProvider, child) {
        final totalItems = stockProvider.stockItems.length;
        final lowStockItems = stockProvider.lowStockItems().length;
        final totalSales = stockProvider.totalSales; // total sales calculation from StockProvider
        final stockValue = stockProvider.getTotalStockValue(); // total stock value from StockProvider

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMetricCard(
              title: 'Total Items',
              value: totalItems.toString(),
              icon: Icons.inventory,
              color: Colors.blueAccent,
            ),
            _buildMetricCard(
              title: 'Low Stock',
              value: lowStockItems.toString(),
              icon: Icons.warning_amber_rounded,
              color: Colors.redAccent,
            ),
            _buildMetricCard(
              title: 'Total Sales',
              value: '\$${totalSales.toStringAsFixed(2)}',
              icon: Icons.show_chart,
              color: Colors.purpleAccent,
            ),
            _buildMetricCard(
              title: 'Stock Value',
              value: '\$${stockValue.toStringAsFixed(2)}',
              icon: Icons.attach_money,
              color: Colors.greenAccent,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.15),
                  color.withOpacity(0.05),
                ],
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 36, color: color),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentlyAddedItems() {
    return Consumer<StockProvider>(
      builder: (context, stockProvider, child) {
        // show the 5 most recently added items
        final recentlyAdded = stockProvider.stockItems.take(5).toList();

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recently Added Items',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 10),
                if (recentlyAdded.isEmpty)
                  const Text('No items have been added yet.')
                else
                  Column(
                    children: recentlyAdded.map((item) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Icon(
                            Icons.inventory_2,
                            color: Colors.green.shade700,
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'In Stock: ${item.quantity}, Price: \$${item.price}',
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivityFeed() {
    return Consumer<StockProvider>(
      builder: (context, stockProvider, child) {
        final recentActivities = stockProvider.recentActivities;

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Activity Feed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 10),
                if (recentActivities.isEmpty)
                  const Text('No recent activity available.')
                else
                  Column(
                    children: recentActivities.map((activity) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.fiber_manual_record_rounded,
                          size: 16,
                          color: Colors.green.shade400,
                        ),
                        title: Text(
                          activity['description'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'Date: ${activity['date'] ?? 'N/A'}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

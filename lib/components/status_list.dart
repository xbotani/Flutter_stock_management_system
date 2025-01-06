import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:store_responsive_dashboard/model.dart';
import 'package:store_responsive_dashboard/widgets/status_card.dart';
import '../constaints.dart';

// Define a list of business statuses
final List<BusinessStatus> statusList = [
  BusinessStatus(
    name: 'Total Sales',
    value: '1,123,456 \$',
    icon: Icons.show_chart_outlined,
  ),
  BusinessStatus(
    name: 'Total Profit',
    value: '11,234 \$',
    icon: Icons.attach_money_outlined,
  ),
  BusinessStatus(
    name: 'Orders',
    value: '1,236',
    icon: Icons.shopping_cart_outlined,
  ),
  BusinessStatus(
    name: 'Customers',
    value: '11,234',
    icon: Icons.people_outline_outlined,
  ),
];

class StatusList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display selection options (Weekly, Monthly, Yearly)
        Row(
          children: const [
            Text(
              'Weekly',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(width: 14),
            Text(
              'Monthly',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 14),
            Text(
              'Yearly',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: componentPadding),
        // Display the status list in a staggered grid view
        StaggeredGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: componentPadding,
          crossAxisSpacing: componentPadding,
          children: List.generate(
            statusList.length,
            (index) => StatusCard(data: statusList[index]),
          ),
        ),
      ],
    );
  }
}

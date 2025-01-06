import 'package:flutter/material.dart';
import 'package:store_responsive_dashboard/constaints.dart';
import '../model.dart';

// Define the orders list
final List<Order> orders = [
  Order(
    icon: Icons.checkroom_outlined,
    name: 'Black T-shirt',
    packs: 2,
    status: 'Delivered',
    date: '12/09/2021',
  ),
  Order(
    icon: Icons.pool_outlined,
    name: 'Swimwear',
    packs: 3,
    status: 'Delivered',
    date: '15/09/2021',
  ),
  Order(
    icon: Icons.dry_cleaning_outlined,
    name: 'Jacket',
    packs: 4,
    status: 'Shipped',
    date: '20/09/2021',
  ),
  Order(
    icon: Icons.beach_access_outlined,
    name: 'Sunglasses',
    packs: 1,
    status: 'In Transit',
    date: '25/09/2021',
  ),
  Order(
    icon: Icons.checkroom_outlined,
    name: 'Jeans',
    packs: 2,
    status: 'Delivered',
    date: '30/09/2021',
  ),
];

// Define column names
final List<String> columnNames = ['', '', 'Time', ''];

class OrderTable extends StatelessWidget {
  const OrderTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: DataTable(
        dataRowHeight: 70,
        columnSpacing: 6,
        headingRowHeight: 0,
        dividerThickness: 0,
        columns: columnNames.map((e) => DataColumn(label: Text(e))).toList(),
        rows: orders.map((order) => _buildDataRow(context, order)).toList(),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, Order order) {
    return DataRow(
      cells: [
        DataCell(Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 14,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                    color: const Color.fromRGBO(147, 198, 176, 0.2),
                  )
                ],
              ),
              child: Icon(
                order.icon,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                order.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ],
        )),
        DataCell(Text(
          '${order.packs} Packs',
        )),
        DataCell(Text(
          order.date,
          style: const TextStyle(fontStyle: FontStyle.italic),
        )),
        DataCell(Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              width: 1,
              color: Theme.of(context).primaryColor,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Text(
              order.status,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 12,
              ),
            ),
          ),
        )),
      ],
    );
  }
}

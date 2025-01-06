// sidebar.dart

import 'package:flutter/material.dart';
import 'package:store_responsive_dashboard/constaints.dart';
import 'package:store_responsive_dashboard/widgets/sidebar_menu_item.dart';
import 'package:store_responsive_dashboard/model.dart';

// Import the actual pages referenced in the menu items:
import 'package:store_responsive_dashboard/pages/home_page.dart';
import 'package:store_responsive_dashboard/pages/dashboard.dart';
import 'package:store_responsive_dashboard/pages/stock_page.dart';
import 'package:store_responsive_dashboard/pages/contact_page.dart';
import 'package:store_responsive_dashboard/pages/info_page.dart';
import 'package:store_responsive_dashboard/pages/sales_page.dart';
// NEW: Import your CalculatorPage so it can be one of the MenuItem pages
import 'package:store_responsive_dashboard/pages/calculator_page.dart';

// The list of menu items, each specifying 'name', 'icon', AND 'page:' 
// to match your original approach of direct references.
final List<MenuItem> menuItems = [
  MenuItem(
    name: 'Home',
    icon: Icons.home_outlined,
    page: HomePage(),
  ),
  MenuItem(
    name: 'Dashboard',
    icon: Icons.dashboard_outlined,
    page: DashboardPage(),
  ),
  MenuItem(
    name: 'Stock',
    icon: Icons.store,
    page: StockPage(),
  ),
  MenuItem(
    name: 'Contact',
    icon: Icons.contact_mail,
    page: ContactPage(),
  ),
  MenuItem(
    name: 'Sales History',        // Our existing new item
    icon: Icons.receipt_long,
    page: SalesPage(),            // The SalesPage
  ),
  MenuItem(
    name: 'Calculator',           // NEW item for conversions
    icon: Icons.calculate,
    page: CalculatorPage(),       // The new CalculatorPage
  ),
];

class SideBar extends StatelessWidget {
  final Function(int) onMenuItemSelected;

  const SideBar({Key? key, required this.onMenuItemSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isDesktop = size.width >= screenLg;

    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 137, 181, 152),
      ),
      width: isDesktop ? sideBarDesktopWidth : sideBarMobileWidth,
      padding: EdgeInsets.symmetric(
        vertical: 24,
        horizontal: isDesktop ? 24 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branding or Logo
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: primaryAncient,
            ),
            width: 45,
            height: 45,
            child: const Center(
              child: Text(
                'KS',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Main menu items
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return InkWell(
                  // onTap calls back to MainScreen via onMenuItemSelected
                  onTap: () => onMenuItemSelected(index),
                  child: SideBarMenuItem(item, isDesktop),
                );
              },
            ),
          ),

          // Info icon at the bottom, referencing InfoPage as before
          InkWell(
            // We pass 'menuItems.length' as the index => triggers the InfoPage in MainScreen
            onTap: () => onMenuItemSelected(menuItems.length),
            child: SideBarMenuItem(
              // Here we define an item with empty name but an Info icon
              MenuItem(
                name: '', 
                icon: Icons.info_outline,
                page: InfoPage(), // referencing InfoPage directly
              ),
              isDesktop,
              showText: false, // Only icon, no text
            ),
          ),
        ],
      ),
    );
  }
}

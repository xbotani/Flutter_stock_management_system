import 'package:flutter/material.dart';
import 'package:store_responsive_dashboard/layout/sidebar.dart';
import 'package:store_responsive_dashboard/layout/topbar.dart';
import 'package:store_responsive_dashboard/pages/home_page.dart';
import 'package:store_responsive_dashboard/pages/dashboard.dart';
import 'package:store_responsive_dashboard/pages/stock_page.dart';
import 'package:store_responsive_dashboard/pages/contact_page.dart';
import 'package:store_responsive_dashboard/pages/info_page.dart';
import '../constaints.dart';

class MainLayout extends StatefulWidget {
  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // List of pages corresponding to sidebar items
  final List<Widget> _pages = [
    HomePage(),
    DashboardPage(),
    StockPage(), // Updated to StockPage instead of UserPage
    ContactPage(),
    InfoPage(), // Added Info Page
  ];

  void _onMenuItemSelected(int index) {
    // Update selected index to change displayed page
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final showDesktop = size.width >= screenXxl;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            SideBar(
              onMenuItemSelected: _onMenuItemSelected, // Pass callback to sidebar
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages, // Display the selected page using IndexedStack
              ),
            ),
            // Removed the NewsList part
          ],
        ),
      ),
    );
  }
}

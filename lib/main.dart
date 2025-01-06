import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Existing pages
import 'package:store_responsive_dashboard/pages/dashboard.dart';
import 'package:store_responsive_dashboard/pages/home_page.dart';
import 'package:store_responsive_dashboard/pages/stock_page.dart';
import 'package:store_responsive_dashboard/pages/contact_page.dart';
import 'package:store_responsive_dashboard/pages/sales_page.dart'; 
import 'package:store_responsive_dashboard/pages/calculator_page.dart';
import 'package:store_responsive_dashboard/pages/info_page.dart';
import 'package:store_responsive_dashboard/pages/login_page.dart';

import 'package:store_responsive_dashboard/layout/sidebar.dart';
import 'package:store_responsive_dashboard/constaints.dart';
import 'package:store_responsive_dashboard/providers/stock_provider.dart';
import 'package:store_responsive_dashboard/providers/client_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key); // not const because we reference Theme.of(context)

  @override
  Widget build(BuildContext context) {
    var apply = Theme.of(context).textTheme.apply(
          bodyColor: textColor ?? Colors.black,
        );

    var themeData = ThemeData(
      fontFamily: 'Nunito',
      primaryColor: primary ?? Colors.blue,
      textTheme: apply,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primary ?? Colors.blue,
        onPrimary: Colors.white,
        secondary: Colors.teal,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        background: Colors.white,
        onBackground: Colors.black,
        surface: Colors.grey[200] ?? Colors.grey,
        onSurface: Colors.black,
      ),
    );

    return MaterialApp(
      title: 'Store Dashboard',
      theme: themeData,
      initialRoute: '/login',
      routes: {
        '/': (context) => MainScreen(),
        '/login': (context) => LoginPage(),
        '/dashboard': (context) => MainScreen(),
        '/stock': (context) => StockPage(),
        '/sales': (context) => SalesPage(),
        '/calculator': (context) => CalculatorPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; 

  /// We have 7 pages total:
  ///   0 -> HomePage
  ///   1 -> DashboardPage
  ///   2 -> StockPage
  ///   3 -> ContactPage
  ///   4 -> SalesPage
  ///   5 -> CalculatorPage
  ///   6 -> InfoPage   (the bottom icon in the sidebar calls index = menuItems.length)
  final List<Widget> _pages = [
    HomePage(),       
    DashboardPage(),  
    StockPage(),      
    ContactPage(),    
    SalesPage(),      
    CalculatorPage(), 
    InfoPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientProvider>(context, listen: false).initializeClients();
    });
  }

  void _onMenuItemSelected(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() => _selectedIndex = index);
    } else {
      print('Invalid index selected: $index');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideBar(onMenuItemSelected: _onMenuItemSelected),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}

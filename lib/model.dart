// model.dart

import 'package:flutter/material.dart';

class MenuItem {
  final String name;
  final IconData icon;
  final Widget page; // Page for navigation

  // We keep 'page' as a required named parameter:
  MenuItem({
    required this.name,
    required this.icon,
    required this.page,
  });
}

class Order {
  final IconData icon;
  final String name;
  final int packs;
  final String status;
  final String date;

  Order({
    required this.icon,
    required this.name,
    required this.packs,
    required this.status,
    required this.date,
  });
}

class News {
  final String title;
  final String imgUrl;
  final String time;
  final String description;

  News({
    required this.title,
    required this.imgUrl,
    required this.time,
    this.description = '',
  });
}

class BusinessStatus {
  final String name;
  final String value;
  final IconData icon;

  BusinessStatus({
    required this.name,
    required this.value,
    required this.icon,
  });
}

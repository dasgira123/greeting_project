import 'package:flutter/material.dart';

class CategoryHelper {
  static Color getColor(String category) {
    switch (category.toLowerCase()) {
      case 'gia đình': 
        return Colors.orange;
      case 'đồng nghiệp': 
        return Colors.purple;
      case 'bạn bè': 
        return Colors.blue;
      case 'chưa phân loại': 
        return Colors.grey;
      default:
        final colors = [
          Colors.teal,
          Colors.pink,
          Colors.indigo,
          Colors.amber,
          Colors.cyan,
          Colors.brown,
          Colors.deepOrange,
          Colors.lightGreen,
        ];
        return colors[category.hashCode.abs() % colors.length];
    }
  }

  static bool isDefaultCategory(String category) {
    final defaultCategories = ['Gia đình', 'Đồng nghiệp', 'Bạn bè', 'Chưa phân loại'];
    return defaultCategories.contains(category);
  }

  static IconData getIcon(String category) {
    switch (category.toLowerCase()) {
      case 'gia đình': 
        return Icons.family_restroom;
      case 'đồng nghiệp': 
        return Icons.work;
      case 'bạn bè': 
        return Icons.group;
      case 'chưa phân loại': 
        return Icons.help_outline;
      default:
        final icons = [
          Icons.label,
          Icons.bookmark,
          Icons.star,
          Icons.local_play,
          Icons.flag,
          Icons.workspaces,
          Icons.category,
        ];
        return icons[category.hashCode.abs() % icons.length];
    }
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';

class Tile extends StatelessWidget {
  const Tile({super.key, required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: Icon(icon, color: color),
    title: Text(label, style: TextStyle(
        color: color, fontSize: AppSizes.fontMd, fontWeight: FontWeight.w500)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
  );
}

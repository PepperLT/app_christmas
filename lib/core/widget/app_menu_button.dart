import 'package:flutter/material.dart';

class AppMenuButton extends StatelessWidget {
  const AppMenuButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: 'Mở menu',
      icon: const Icon(Icons.menu_rounded),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF9E3546),
        minimumSize: const Size(48, 48),
      ),
    );
  }
}

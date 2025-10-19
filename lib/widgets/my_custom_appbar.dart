import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
  });


  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF9D6550),
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFd7eaff), // Mantém o texto visível com o fundo castanho i hope
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: actions,
    );
  }


  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

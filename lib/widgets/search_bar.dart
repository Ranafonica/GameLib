import 'package:flutter/material.dart';

class GameSearchBar extends StatelessWidget {
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final TextEditingController controller;
  final FocusNode focusNode;

  const GameSearchBar({
    super.key,
    required this.onSubmitted,
    required this.onClear,
    required this.controller,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          hintText: 'Buscar juegos...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              controller.clear();
              onClear();
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}
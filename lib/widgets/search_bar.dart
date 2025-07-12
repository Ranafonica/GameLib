import 'package:flutter/material.dart';

class GameSearchBar extends StatefulWidget {
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<Map<String, dynamic>> genres;
  final ValueChanged<int> onGenreSelected;
  final int? selectedGenreId;

  const GameSearchBar({
    super.key,
    required this.onSubmitted,
    required this.onClear,
    required this.controller,
    required this.focusNode,
    required this.genres,
    required this.onGenreSelected,
    this.selectedGenreId,
  });

  @override
  State<GameSearchBar> createState() => _GameSearchBarState();
}

class _GameSearchBarState extends State<GameSearchBar> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            decoration: InputDecoration(
              hintText: 'Buscar juegos...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  widget.controller.clear();
                  widget.onClear();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              filled: true,
              fillColor: colorScheme.surface,
            ),
            onSubmitted: widget.onSubmitted,
          ),
        ),
        if (widget.genres.isNotEmpty)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.genres.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: const Text('Todos'),
                      selected: widget.selectedGenreId == null,
                      onSelected: (selected) {
                        widget.onGenreSelected(-1);
                      },
                      selectedColor: colorScheme.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: widget.selectedGenreId == null 
                            ? colorScheme.onPrimary 
                            : colorScheme.onSurface,
                      ),
                    ),
                  );
                }
                final genre = widget.genres[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(genre['name']),
                    selected: widget.selectedGenreId == genre['id'],
                    onSelected: (selected) {
                      widget.onGenreSelected(genre['id']);
                    },
                    selectedColor: colorScheme.primary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: widget.selectedGenreId == genre['id']
                          ? colorScheme.onPrimary 
                          : colorScheme.onSurface,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
import 'package:flutter/material.dart';

/// A list tile for picking a color role override.
///
/// Displays the current color (or default), label, and description.
/// Tapping opens a color picker dialog.
class ColorRolePicker extends StatelessWidget {
  const ColorRolePicker({
    super.key,
    required this.label,
    required this.description,
    required this.currentColor,
    required this.defaultColor,
    required this.onColorChanged,
  });

  /// Display label for this color role.
  final String label;

  /// Description of what this color role affects.
  final String description;

  /// Currently selected color, or null if using default.
  final Color? currentColor;

  /// Default color from the base pack.
  final Color defaultColor;

  /// Callback when the color is changed. Null means reset to default.
  final ValueChanged<Color?> onColorChanged;

  /// Color to display (current override or default).
  Color get displayColor => currentColor ?? defaultColor;

  /// Whether this role has a custom override.
  bool get hasOverride => currentColor != null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: GestureDetector(
        onTap: () => _showColorPicker(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: displayColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outline, width: 1),
          ),
          child: hasOverride ? const Icon(Icons.edit, size: 16, color: Colors.white) : null,
        ),
      ),
      title: Text(label),
      subtitle: Text(description),
      trailing: hasOverride
          ? IconButton(
              icon: const Icon(Icons.restore),
              tooltip: 'Reset to default',
              onPressed: () => onColorChanged(null),
            )
          : null,
      onTap: () => _showColorPicker(context),
    );
  }

  Future<void> _showColorPicker(BuildContext context) async {
    final result = await showDialog<Color>(
      context: context,
      builder: (context) =>
          _ColorPickerDialog(initialColor: displayColor, defaultColor: defaultColor),
    );

    if (result != null) {
      onColorChanged(result);
    }
  }
}

/// Simple color picker dialog with preset colors and custom input.
class _ColorPickerDialog extends StatefulWidget {
  const _ColorPickerDialog({required this.initialColor, required this.defaultColor});

  final Color initialColor;
  final Color defaultColor;

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color _selectedColor;
  final _hexController = TextEditingController();

  static const _presetColors = [
    Color(0xFF0085FF), // Blue
    Color(0xFF78A9FF), // Light Blue
    Color(0xFF33B1FF), // Cyan
    Color(0xFFEE5396), // Pink
    Color(0xFFFF7EB6), // Light Pink
    Color(0xFF42BE65), // Green
    Color(0xFFFF832B), // Orange
    Color(0xFFF1C21B), // Yellow
    Color(0xFFBE95FF), // Purple
    Color(0xFF161616), // Dark
    Color(0xFF262626), // Dark Gray
    Color(0xFF393939), // Gray
    Color(0xFF525252), // Medium Gray
    Color(0xFF8D8D8D), // Light Gray
    Color(0xFFF2F4F8), // Light
    Color(0xFFFFFFFF), // White
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    _updateHexField();
  }

  void _updateHexField() {
    final hex = _selectedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2);
    _hexController.text = hex.toUpperCase();
  }

  void _parseHexField() {
    final hex = _hexController.text.replaceFirst('#', '');
    if (hex.length == 6) {
      final intValue = int.tryParse(hex, radix: 16);
      if (intValue != null) {
        setState(() {
          _selectedColor = Color(0xFF000000 | intValue);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Select Color'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _hexController,
              decoration: const InputDecoration(
                labelText: 'Hex Code',
                prefixText: '#',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _parseHexField(),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final color in _presetColors)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                        _updateHexField();
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedColor == color
                              ? colorScheme.primary
                              : colorScheme.outline,
                          width: _selectedColor == color ? 2 : 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selectedColor),
          child: const Text('Select'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }
}

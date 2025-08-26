import 'package:flutter/material.dart';

import '../../../../features/vault/domain/entities/custom_field.dart';

/// Editable section for managing custom fields on a vault item.
///
/// Supports three field types (per D-12, D-13):
/// - text: plain text key-value
/// - hidden: obscured value with reveal toggle
/// - boolean: name with switch toggle
class CustomFieldsSection extends StatefulWidget {
  const CustomFieldsSection({
    super.key,
    required this.fields,
    required this.onChanged,
  });

  final List<CustomField> fields;
  final ValueChanged<List<CustomField>> onChanged;

  @override
  State<CustomFieldsSection> createState() => _CustomFieldsSectionState();
}

class _CustomFieldsSectionState extends State<CustomFieldsSection> {
  late List<CustomField> _fields;
  final Set<int> _revealedIndices = {};

  @override
  void initState() {
    super.initState();
    _fields = List.of(widget.fields);
  }

  @override
  void didUpdateWidget(CustomFieldsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fields != widget.fields) {
      _fields = List.of(widget.fields);
    }
  }

  void _updateField(int index, CustomField field) {
    _fields[index] = field;
    widget.onChanged(List.of(_fields));
  }

  void _removeField(int index) {
    _fields.removeAt(index);
    _revealedIndices.remove(index);
    widget.onChanged(List.of(_fields));
    setState(() {});
  }

  void _addField() {
    _showAddFieldDialog();
  }

  Future<void> _showAddFieldDialog() async {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    CustomFieldType selectedType = CustomFieldType.text;

    final result = await showDialog<CustomField>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Add Custom Field',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Field Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<CustomFieldType>(
                    initialValue: selectedType,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: CustomFieldType.text,
                        child: Text('Text'),
                      ),
                      DropdownMenuItem(
                        value: CustomFieldType.hidden,
                        child: Text('Hidden / Password'),
                      ),
                      DropdownMenuItem(
                        value: CustomFieldType.boolean,
                        child: Text('Boolean'),
                      ),
                    ],
                    onChanged: (type) {
                      if (type != null) {
                        setDialogState(() => selectedType = type);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  if (selectedType != CustomFieldType.boolean)
                    TextField(
                      controller: valueController,
                      obscureText: selectedType == CustomFieldType.hidden,
                      decoration: InputDecoration(
                        labelText: selectedType == CustomFieldType.hidden
                            ? 'Secret Value'
                            : 'Value',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;
                    final value = selectedType == CustomFieldType.boolean
                        ? 'false'
                        : valueController.text;
                    Navigator.pop(
                      ctx,
                      CustomField(
                        name: nameController.text.trim(),
                        value: value,
                        type: selectedType,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4D4DCD),
                  ),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _fields.add(result);
      });
      widget.onChanged(List.of(_fields));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Fields',
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        ..._fields.asMap().entries.map((entry) {
          final index = entry.key;
          final field = entry.value;
          return _buildFieldTile(context, index, field);
        }),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addField,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Field'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF4D4DCD),
            side: const BorderSide(color: Color(0xFF4D4DCD)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldTile(BuildContext context, int index, CustomField field) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(child: _buildFieldContent(context, index, field)),
            IconButton(
              onPressed: () => _removeField(index),
              icon: Icon(
                Icons.delete_outline,
                size: 20,
                color: theme.colorScheme.error,
              ),
              tooltip: 'Remove field',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldContent(
      BuildContext context, int index, CustomField field) {
    switch (field.type) {
      case CustomFieldType.text:
        return _TextFieldEntry(
          field: field,
          onChanged: (updated) => _updateField(index, updated),
        );
      case CustomFieldType.hidden:
        final isRevealed = _revealedIndices.contains(index);
        return _HiddenFieldEntry(
          field: field,
          isRevealed: isRevealed,
          onToggleReveal: () {
            setState(() {
              if (isRevealed) {
                _revealedIndices.remove(index);
              } else {
                _revealedIndices.add(index);
              }
            });
          },
          onChanged: (updated) => _updateField(index, updated),
        );
      case CustomFieldType.boolean:
        return _BooleanFieldEntry(
          field: field,
          onChanged: (updated) => _updateField(index, updated),
        );
    }
  }
}

class _TextFieldEntry extends StatelessWidget {
  const _TextFieldEntry({required this.field, required this.onChanged});

  final CustomField field;
  final ValueChanged<CustomField> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.name,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: field.value,
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (val) => onChanged(field.copyWith(value: val)),
        ),
      ],
    );
  }
}

class _HiddenFieldEntry extends StatelessWidget {
  const _HiddenFieldEntry({
    required this.field,
    required this.isRevealed,
    required this.onToggleReveal,
    required this.onChanged,
  });

  final CustomField field;
  final bool isRevealed;
  final VoidCallback onToggleReveal;
  final ValueChanged<CustomField> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                field.name,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
            ),
            GestureDetector(
              onTap: onToggleReveal,
              child: Icon(
                isRevealed
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 18,
                color: const Color(0xFF4D4DCD),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: field.value,
          obscureText: !isRevealed,
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (val) => onChanged(field.copyWith(value: val)),
        ),
      ],
    );
  }
}

class _BooleanFieldEntry extends StatelessWidget {
  const _BooleanFieldEntry({required this.field, required this.onChanged});

  final CustomField field;
  final ValueChanged<CustomField> onChanged;

  @override
  Widget build(BuildContext context) {
    final isOn = field.value.toLowerCase() == 'true';
    return Row(
      children: [
        Expanded(
          child: Text(
            field.name,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Switch(
          value: isOn,
          activeThumbColor: const Color(0xFF4D4DCD),
          onChanged: (val) {
            onChanged(field.copyWith(value: val.toString()));
          },
        ),
      ],
    );
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';

import 'package:bluesky/app_bsky_graph_defs.dart' show KnownListPurpose;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateEditListResult {
  const CreateEditListResult({
    required this.name,
    required this.purpose,
    this.description,
    this.avatarBytes,
    this.avatarMimeType = 'image/jpeg',
  });

  final String name;
  final String purpose;
  final String? description;
  final Uint8List? avatarBytes;
  final String avatarMimeType;
}

/// A dialog for creating a new list or editing an existing one.
///
/// Returns a [CreateEditListResult] on save, or null on cancel.
class CreateEditListDialog extends StatefulWidget {
  const CreateEditListDialog({
    super.key,
    this.initialName,
    this.initialDescription,
    this.initialAvatarUrl,
    this.initialPurpose,
    this.fixedPurpose,
  });

  final String? initialName;
  final String? initialDescription;
  final String? initialAvatarUrl;

  /// Pre-selected purpose for a new list.
  final KnownListPurpose? initialPurpose;

  /// When non-null, purpose cannot be changed (edit mode).
  final String? fixedPurpose;

  @override
  State<CreateEditListDialog> createState() => _CreateEditListDialogState();
}

class _CreateEditListDialogState extends State<CreateEditListDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late KnownListPurpose _purpose;

  Uint8List? _avatarBytes;
  String _avatarMimeType = 'image/jpeg';
  bool _isPicking = false;

  final ImagePicker _picker = ImagePicker();

  bool get _isEditing => widget.fixedPurpose != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _descController = TextEditingController(text: widget.initialDescription ?? '');
    _purpose = widget.initialPurpose ?? KnownListPurpose.appBskyGraphDefsCuratelist;
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (file != null && mounted) {
        final bytes = await File(file.path).readAsBytes();
        final ext = file.path.toLowerCase().split('.').last;
        setState(() {
          _avatarBytes = bytes;
          _avatarMimeType = ext == 'png' ? 'image/png' : 'image/jpeg';
        });
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final purposeStr =
        widget.fixedPurpose ??
        (_purpose == KnownListPurpose.appBskyGraphDefsModlist
            ? 'app.bsky.graph.defs#modlist'
            : 'app.bsky.graph.defs#curatelist');

    Navigator.pop(
      context,
      CreateEditListResult(
        name: name,
        purpose: purposeStr,
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        avatarBytes: _avatarBytes,
        avatarMimeType: _avatarMimeType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final hasAvatar = _avatarBytes != null || widget.initialAvatarUrl != null;

    return AlertDialog(
      title: Text(_isEditing ? context.l10n.labelEditList : context.l10n.labelCreateList),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        backgroundImage: _avatarBytes != null
                            ? MemoryImage(_avatarBytes!)
                            : (widget.initialAvatarUrl != null ? NetworkImage(widget.initialAvatarUrl!) : null),
                        child: !hasAvatar ? Icon(Icons.list, size: 32, color: colorScheme.onSurfaceVariant) : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: colorScheme.primaryContainer,
                          child: _isPicking
                              ? SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                )
                              : Icon(Icons.camera_alt, size: 16, color: colorScheme.onPrimaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: context.l10n.labelName, border: const OutlineInputBorder()),
                maxLength: 64,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: context.l10n.labelDescriptionOptional,
                  border: const OutlineInputBorder(),
                ),
                maxLength: 300,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              if (!_isEditing) ...[
                const SizedBox(height: 12),
                Text(context.l10n.labelType, style: context.textTheme.labelLarge),
                const SizedBox(height: 8),
                SegmentedButton<KnownListPurpose>(
                  segments: [
                    ButtonSegment(
                      value: KnownListPurpose.appBskyGraphDefsCuratelist,
                      label: Text(context.l10n.labelFeed),
                      icon: const Icon(Icons.dynamic_feed_outlined),
                    ),
                    ButtonSegment(
                      value: KnownListPurpose.appBskyGraphDefsModlist,
                      label: Text(context.l10n.labelModeration),
                      icon: const Icon(Icons.shield_outlined),
                    ),
                  ],
                  selected: {_purpose},
                  onSelectionChanged: (selection) => setState(() => _purpose = selection.first),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.buttonCancel)),
        FilledButton(
          onPressed: _nameController.text.trim().isEmpty ? null : _save,
          child: Text(_isEditing ? context.l10n.buttonSave : context.l10n.buttonCreate),
        ),
      ],
    );
  }
}

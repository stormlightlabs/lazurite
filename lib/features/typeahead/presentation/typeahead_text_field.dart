import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lazurite/features/typeahead/cubit/typeahead_cubit.dart';
import 'package:lazurite/features/typeahead/cubit/typeahead_state.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';
import 'package:lazurite/features/typeahead/data/typeahead_result.dart';

class TypeaheadTextField extends StatefulWidget {
  const TypeaheadTextField({
    required this.controller,
    required this.repository,
    required this.onSelected,
    this.decoration,
    this.debounceMs = 300,
    this.minChars = 2,
    this.limit = 10,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    this.enabled = true,
    this.autocorrect = false,
    this.focusNode,
    super.key,
  });

  final TextEditingController controller;
  final TypeaheadRepository repository;
  final ValueChanged<TypeaheadResult> onSelected;
  final InputDecoration? decoration;
  final int debounceMs;
  final int minChars;
  final int limit;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool autocorrect;
  final FocusNode? focusNode;

  @override
  State<TypeaheadTextField> createState() => _TypeaheadTextFieldState();
}

class _TypeaheadTextFieldState extends State<TypeaheadTextField> with WidgetsBindingObserver {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  late FocusNode _focusNode;
  late bool _ownsFocusNode;
  final Object _tapRegionGroup = Object();

  TypeaheadCubit? _cubit;
  StreamSubscription<TypeaheadState>? _stateSubscription;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    WidgetsBinding.instance.addObserver(this);
    _focusNode.addListener(_handleFocusChange);
    _createCubit();
  }

  @override
  void didUpdateWidget(TypeaheadTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_handleFocusChange);
      if (_ownsFocusNode) {
        _focusNode.dispose();
      }
      _ownsFocusNode = widget.focusNode == null;
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_handleFocusChange);
    }

    final shouldRecreateCubit =
        oldWidget.repository != widget.repository ||
        oldWidget.debounceMs != widget.debounceMs ||
        oldWidget.limit != widget.limit;

    if (shouldRecreateCubit) {
      _stateSubscription?.cancel();
      _cubit?.close();
      _createCubit();
      _runQuery(widget.controller.text);
    }

    if (_overlayEntry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _overlayEntry?.markNeedsBuild();
      });
    }
  }

  @override
  void didChangeMetrics() {
    _overlayEntry?.markNeedsBuild();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }

    _removeOverlay();
    _stateSubscription?.cancel();
    _cubit?.close();
    super.dispose();
  }

  void _createCubit() {
    final cubit = TypeaheadCubit(
      repository: widget.repository,
      debounceDuration: Duration(milliseconds: widget.debounceMs),
      searchLimit: widget.limit,
    );

    _cubit = cubit;
    _stateSubscription = cubit.stream.listen(_onStateChanged);
  }

  void _onStateChanged(TypeaheadState state) {
    if (!mounted) {
      return;
    }

    if (!_focusNode.hasFocus || widget.controller.text.trim().length < widget.minChars) {
      _removeOverlay();
      return;
    }

    if (state.isLoading || state.error != null || state.results.isNotEmpty) {
      _showOrUpdateOverlay();
      return;
    }

    _removeOverlay();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _dismissSuggestions();
      return;
    }

    final cubit = _cubit;
    if (cubit == null) {
      return;
    }

    final state = cubit.state;
    if (state.isLoading || state.error != null || state.results.isNotEmpty) {
      _showOrUpdateOverlay();
    }
  }

  void _runQuery(String value) {
    final normalizedQuery = value.trim();
    final cubit = _cubit;
    if (cubit == null) {
      return;
    }

    if (normalizedQuery.length < widget.minChars) {
      cubit.clear();
      return;
    }

    cubit.onQueryChanged(normalizedQuery);
  }

  void _onTapOutside(PointerDownEvent _) {
    _dismissSuggestions();
  }

  void _dismissSuggestions() {
    _removeOverlay();
    _cubit?.clear();
  }

  void _showOrUpdateOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(builder: (context) => _buildOverlay(context));
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildOverlay(BuildContext context) {
    final fieldContext = _fieldKey.currentContext;
    if (fieldContext == null) {
      return const SizedBox.shrink();
    }

    final renderBox = fieldContext.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      return const SizedBox.shrink();
    }

    final fieldSize = renderBox.size;
    final state = _cubit?.state ?? const TypeaheadState();

    return Positioned.fill(
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: Offset(0, fieldSize.height + 4),
        child: Align(
          alignment: Alignment.topLeft,
          child: TapRegion(
            groupId: _tapRegionGroup,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: fieldSize.width,
                child: _SuggestionList(
                  state: state,
                  onSelected: (result) {
                    widget.onSelected(result);
                    _dismissSuggestions();
                    _focusNode.unfocus();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: _tapRegionGroup,
      onTapOutside: _onTapOutside,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: TextFormField(
          key: _fieldKey,
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: widget.decoration,
          validator: widget.validator,
          textInputAction: widget.textInputAction,
          enabled: widget.enabled,
          autocorrect: widget.autocorrect,
          onFieldSubmitted: widget.onFieldSubmitted,
          onChanged: (value) {
            _runQuery(value);
            widget.onChanged?.call(value);
          },
        ),
      ),
    );
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({required this.state, required this.onSelected});

  final TypeaheadState state;
  final ValueChanged<TypeaheadResult> onSelected;

  @override
  Widget build(BuildContext context) {
    if (state.error != null) {
      return ListTile(dense: true, leading: const Icon(Icons.error_outline), title: Text(state.error!));
    }

    if (state.isLoading && state.results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 280),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: state.results.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final result = state.results[index];
          return ListTile(
            key: ValueKey<String>('typeahead-result-${result.did}'),
            dense: true,
            leading: CircleAvatar(
              backgroundImage: result.avatarUrl != null ? NetworkImage(result.avatarUrl!) : null,
              child: result.avatarUrl == null ? Text(_avatarInitial(result.displayName ?? result.handle)) : null,
            ),
            title: Text(result.displayName ?? result.handle, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('@${result.handle}', maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () => onSelected(result),
          );
        },
      ),
    );
  }

  static String _avatarInitial(String value) {
    if (value.isEmpty) {
      return '?';
    }

    return value.substring(0, 1).toUpperCase();
  }
}

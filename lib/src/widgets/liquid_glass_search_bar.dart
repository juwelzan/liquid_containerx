import 'package:flutter/material.dart';

import '../core/liquid_glass_settings.dart';
import '../presets/liquid_glass_presets.dart';
import '../shapes/liquid_glass_shape.dart';
import 'liquid_glass_container.dart';

/// A sleek liquid glass search input field with responsive icons, clear button,
/// and keyboard focus management.
class LiquidGlassSearchBar extends StatefulWidget {
  const LiquidGlassSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText = 'Search...',
    this.leading,
    this.trailing,
    this.settings,
    this.shape = const LiquidGlassShape.capsule(),
    this.focusNode,
    this.autofocus = false,
  });

  /// The text editing controller.
  final TextEditingController? controller;

  /// Callback when text changes.
  final ValueChanged<String>? onChanged;

  /// Callback when keyboard submits the search query.
  final ValueChanged<String>? onSubmitted;

  /// Placeholder hint text.
  final String hintText;

  /// Prefix widget (defaults to search magnifying glass icon).
  final Widget? leading;

  /// Suffix widget (defaults to clear icon when text is non-empty).
  final Widget? trailing;

  /// Optical settings for the glass search bar. Defaults to [LiquidGlassPresets.iosMaps].
  final LiquidGlassSettings? settings;

  /// Boundary shape for the search bar. Defaults to pill capsule.
  final LiquidGlassShape shape;

  /// Optional focus node.
  final FocusNode? focusNode;

  /// Whether to autofocus this search field.
  final bool autofocus;

  @override
  State<LiquidGlassSearchBar> createState() => _LiquidGlassSearchBarState();
}

class _LiquidGlassSearchBarState extends State<LiquidGlassSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isInternalController = false;
  bool _isInternalFocusNode = false;
  bool _hasText = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _isInternalController = true;
    }

    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _isInternalFocusNode = true;
    }

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    if (_isInternalController) _controller.dispose();
    if (_isInternalFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final has = _controller.text.isNotEmpty;
    if (has != _hasText) {
      setState(() => _hasText = has);
    }
  }

  void _onFocusChanged() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSettings = (widget.settings ?? LiquidGlassPresets.iosMaps)
        .copyWith(
          borderWidth: _isFocused ? 1.5 : null,
          borderGradient: _isFocused
              ? const LinearGradient(colors: [Colors.white, Colors.cyanAccent])
              : null,
        );

    return SizedBox(
      height: 48,
      child: LiquidGlassContainer(
        settings: effectiveSettings,
        shape: widget.shape,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            widget.leading ??
                const Icon(Icons.search, size: 20, color: Colors.white70),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(
                    color: Colors.white54,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (widget.trailing != null)
              widget.trailing!
            else if (_hasText)
              GestureDetector(
                onTap: () {
                  _controller.clear();
                  widget.onChanged?.call('');
                },
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.cancel, size: 18, color: Colors.white60),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

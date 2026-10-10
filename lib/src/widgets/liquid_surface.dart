import 'package:flutter/widgets.dart';

/// A liquid surface widget.
class LiquidSurface extends StatelessWidget {
  final Widget child;
  const LiquidSurface({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

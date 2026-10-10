import 'package:flutter/widgets.dart';

/// A widget that groups multiple liquid surfaces.
class LiquidGroup extends StatelessWidget {
  final Widget child;
  const LiquidGroup({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

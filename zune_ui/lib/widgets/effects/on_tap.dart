import 'package:flutter/widgets.dart';

class OnTap extends StatefulWidget {
  final Widget Function(bool isFocused) builder;

  const OnTap({
    super.key,
    required this.builder,
  });

  @override
  State<OnTap> createState() => _OnTapState();
}

class _OnTapState extends State<OnTap> {
  bool isFocused = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onFocused(true),
      child: widget.builder(isFocused),
    );
  }

  void onFocused(bool isFocused) => setState(() {
        this.isFocused = isFocused;
      });
}

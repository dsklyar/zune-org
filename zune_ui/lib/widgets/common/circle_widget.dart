part of common;

class CircleWidget extends StatelessWidget {
  final double size;
  final void Function()? cb;
  final Widget? child;
  final double borderWidth;
  final Color? borderColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const CircleWidget({
    super.key,
    required this.size,
    this.cb,
    this.child,
    this.borderWidth = 2,
    this.padding,
    this.margin,
    this.borderColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: cb,
      child: Container(
        height: size,
        width: size,
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            width: borderWidth,
            color: borderColor!,
          ),
        ),
        child: child,
      ),
    );
  }
}

part of controls_page;

enum VolumeControlTypeEnum { up, down }

class VolumeControl extends StatelessWidget {
  final void Function(TapDownDetails) onTapDown;
  final void Function(TapUpDetails) onTapUp;
  final bool isActive;
  final bool hasVolumeLabel;
  final VolumeControlTypeEnum type;

  const VolumeControl({
    super.key,
    required this.type,
    required this.onTapDown,
    required this.onTapUp,
    required this.isActive,
    this.hasVolumeLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            Icon(
              shadows: [
                if (isActive)
                  const Shadow(
                    blurRadius: 10.0,
                    color: Colors.white,
                  ),
              ],
              type == VolumeControlTypeEnum.up ? Icons.add : Icons.remove,
              color: Colors.white,
              size: 56,
            ),
            if (hasVolumeLabel)
              Text(
                "volume".toUpperCase(),
                style: Styles.volumeTag,
              ),
          ],
        ),
      ),
    );
  }
}

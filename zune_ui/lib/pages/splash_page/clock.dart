part of splash_page;

class Clock extends StatefulWidget {
  const Clock({
    super.key,
  });

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  late final Timer _timer;

  late String displayTime;

  @override
  void initState() {
    super.initState();

    displayTime = formatTime(DateTime.now());

    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        setState(() {
          displayTime = formatTime(DateTime.now());
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  String formatTime(DateTime dt) {
    final minute = dt.minute < 10 ? "0${dt.minute}" : "${dt.minute}";
    return "${dt.hour}:$minute";
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      displayTime,
      style: Styles.clockFont,
    );
  }
}

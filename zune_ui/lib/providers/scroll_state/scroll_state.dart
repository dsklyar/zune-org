import 'package:flutter/widgets.dart';

class ScrollStateModel extends ChangeNotifier {
  Key getSupportKey() {
    return const Key('support_key');
  }

  Key getMainKey() {
    return const Key('main_key');
  }
}

import 'package:flutter/widgets.dart';

class Disposition extends InheritedWidget {
  const Disposition({super.key, required this.etendue, required super.child});

  final bool etendue;

  static bool etendueDe(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Disposition>()?.etendue ??
      false;

  @override
  bool updateShouldNotify(Disposition oldWidget) =>
      etendue != oldWidget.etendue;
}

import 'package:flutter/widgets.dart';

class Resolver extends StatelessWidget {
  const Resolver({
    super.key,
    required this.child,
    this.resolves,
  });

  final List? resolves;
  final Widget child;

  static T? resolve<T>(BuildContext context) {
    final resolver = context.findAncestorWidgetOfExactType<Resolver>();
    final resolved = resolver?.resolves?.firstWhere(
      (e) => e is T,
      orElse: () => null,
    ) as T?;
    assert(
      (resolver?.resolves?.whereType<T>().length ?? 0) < 2,
      'can not have multiple objects of the same type',
    );
    return resolved;
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

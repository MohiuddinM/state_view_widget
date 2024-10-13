import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

mixin AutoDispose<T extends StatefulWidget> on State<T> {
  final _disposables = <_Disposable>[];

  @nonVirtual
  @protected
  R autoDispose<R>(
    R resource, {
    VoidCallback? dispose,
    VoidCallback? onDispose,
  }) {
    try {
      _disposables.add(
        _Disposable(
          resource,
          dispose ?? (resource as dynamic).dispose,
          onDispose,
        ),
      );
    } catch (e) {
      assert(
        e is! NoSuchMethodError,
        'dispose method not defined for ${resource.runtimeType}',
      );
    }

    return resource;
  }

  @override
  void dispose() {
    for (final disposable in _disposables) {
      disposable.dispose();
      disposable.onDispose?.call();
    }
    super.dispose();
  }
}

class _Disposable<T> {
  const _Disposable(this.resource, this.dispose, this.onDispose);

  final T resource;
  final VoidCallback dispose;
  final VoidCallback? onDispose;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is _Disposable &&
        other.resource == resource &&
        other.dispose == dispose &&
        other.onDispose == onDispose;
  }

  @override
  int get hashCode => Object.hash(resource, dispose, onDispose);
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'auto_dispose.dart';
import 'proxy_navigator.dart';
import 'resolver.dart';

abstract class StateViewWidget<T extends StateViewWidget<T>>
    extends StatefulWidget {
  const StateViewWidget({super.key});

  ViewOf<T, StateOf<T>> get view;

  StateOf<T> get state;

  @override
  @nonVirtual
  // ignore: no_logic_in_create_state
  StateOf<T> createState() => state;
}

abstract class StateOf<T extends StateViewWidget<dynamic>> extends State<T>
    with ChangeNotifier, AutoDispose
    implements ValueListenable<StateOf<T>> {
  late final _parentNavigator = Navigator.of(context);

  StateOf<T>? _injectedState;

  @visibleForTesting
  set injectedState(StateOf<T>? c) => setState(() => _injectedState = c);

  Widget? _injectedView;

  @visibleForTesting
  set injectedView(c) => setState(() => _injectedView = c);

  @protected
  bool get isDisposed => !mounted;

  @protected
  BuildContext? get contextOrNull => mounted ? super.context : null;

  @override
  @protected
  BuildContext get context => super.context;

  @override
  @protected
  @nonVirtual
  bool get mounted => super.mounted;

  @override
  @protected
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }

  @override
  @protected
  DiagnosticsNode toDiagnosticsNode({
    String? name,
    DiagnosticsTreeStyle? style,
  }) {
    return super.toDiagnosticsNode(name: name, style: style);
  }

  void setProperty(VoidCallback fn) => setState(fn);

  @override
  @protected
  @nonVirtual
  void setState(VoidCallback fn) {
    if (mounted) {
      notifyListeners();
      super.setState(fn);
    }
  }

  @mustCallSuper
  @override
  @protected
  void dispose() {
    super.dispose();
  }

  @override
  @nonVirtual
  @protected
  StateOf<T> get value => _injectedState ?? this;

  @override
  @protected
  void addListener(VoidCallback listener) {
    super.addListener(listener);
  }

  @override
  @protected
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
  }

  @override
  @protected
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString(minLevel: minLevel);
  }

  @override
  @protected
  String toStringShort() {
    return super.toStringShort();
  }

  @override
  @nonVirtual
  @protected
  Widget build(BuildContext context) {
    return ProxyNavigator(
      parentNavigator: _parentNavigator,
      childBuilder: (context, child) {
        return Resolver(
          resolves: [value],
          child: _injectedView ?? child,
        );
      },
      onInitialRoute: (settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => Resolver(
            resolves: [value],
            child: _injectedView ?? widget.view,
          ),
        );
      },
    );
  }
}

abstract class ViewOf<S extends StateViewWidget<S>, T extends StateOf<S>>
    extends StatelessWidget {
  const ViewOf({super.key});

  T _valueOf(BuildContext context) {
    return Resolver.resolve<StateOf<S>>(context)! as T;
  }

  Widget buildView(BuildContext context, T state);

  @override
  @nonVirtual
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _valueOf(context),
      builder: (context, v, _) {
        return buildView(context, v as T);
      },
    );
  }
}

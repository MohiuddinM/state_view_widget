import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef ChildBuilder<T> = Widget Function(BuildContext context, Widget route);

class ProxyNavigator extends Navigator {
  const ProxyNavigator({
    required this.parentNavigator,
    super.key,
    super.observers,
    required this.childBuilder,
    required this.onInitialRoute,
    super.initialRoute = '/',
  });

  final NavigatorState parentNavigator;
  final ChildBuilder childBuilder;
  final RouteFactory onInitialRoute;

  @override
  RouteFactory? get onUnknownRoute {
    return parentNavigator.widget.onUnknownRoute;
  }

  @override
  RouteFactory? get onGenerateRoute => (settings) {
        if (settings.name == initialRoute) {
          return onInitialRoute(settings);
        }

        return parentNavigator.widget.onGenerateRoute!(settings);
      };

  @override
  NavigatorState createState() => ProxyNavigatorState();
}

class ProxyNavigatorState extends NavigatorState {
  NavigatorState get _parentNavigator => widget.parentNavigator;

  @override
  ProxyNavigator get widget => super.widget as ProxyNavigator;

  @override
  Future<T?> push<T extends Object?>(Route<T> route) {
    return _parentNavigator.push(_wrapRoute(route));
  }

  @override
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return push<T?>(_routeNamed<T>(routeName, arguments: arguments)!);
  }

  @override
  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    Route<T> newRoute, {
    TO? result,
  }) {
    return _parentNavigator.pushReplacement(
      _wrapRoute(newRoute),
      result: result,
    );
  }

  @override
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return pushReplacement<T?, TO>(
      _routeNamed<T>(routeName, arguments: arguments)!,
      result: result,
    );
  }

  @override
  Future<T?> pushAndRemoveUntil<T extends Object?>(
    Route<T> newRoute,
    RoutePredicate predicate,
  ) {
    return _parentNavigator.pushAndRemoveUntil(_wrapRoute(newRoute), predicate);
  }

  @override
  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String newRouteName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    return pushAndRemoveUntil<T?>(
      _routeNamed<T>(newRouteName, arguments: arguments)!,
      predicate,
    );
  }

  @override
  Future<T?> popAndPushNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    pop<TO>(result);
    return pushNamed<T>(routeName, arguments: arguments);
  }

  @override
  void pop<T extends Object?>([T? result]) {
    return _parentNavigator.pop(result);
  }

  @override
  Future<bool> maybePop<T extends Object?>([T? result]) {
    return _parentNavigator.maybePop(result);
  }

  @override
  bool canPop() {
    return _parentNavigator.canPop();
  }

  @override
  void popUntil(RoutePredicate predicate) {
    return _parentNavigator.popUntil(predicate);
  }

  Route<T?>? _routeNamed<T>(
    String name, {
    required Object? arguments,
    bool allowNull = false,
  }) {
    if (allowNull && widget.onGenerateRoute == null) {
      return null;
    }
    assert(() {
      if (widget.onGenerateRoute == null) {
        throw FlutterError(
          'Navigator.onGenerateRoute was null, but the route named "$name" was referenced.\n'
          'To use the Navigator API with named routes (pushNamed, pushReplacementNamed, or '
          'pushNamedAndRemoveUntil), the Navigator must be provided with an '
          'onGenerateRoute handler.\n'
          'The Navigator was:\n'
          '  $this',
        );
      }
      return true;
    }());
    final RouteSettings settings = RouteSettings(
      name: name,
      arguments: arguments,
    );
    Route<T?>? route = widget.onGenerateRoute!(settings) as Route<T?>?;
    if (route == null && !allowNull) {
      assert(() {
        if (widget.onUnknownRoute == null) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary(
                'Navigator.onGenerateRoute returned null when requested to build route "$name".'),
            ErrorDescription(
              'The onGenerateRoute callback must never return null, unless an onUnknownRoute '
              'callback is provided as well.',
            ),
            DiagnosticsProperty<NavigatorState>('The Navigator was', this,
                style: DiagnosticsTreeStyle.errorProperty),
          ]);
        }
        return true;
      }());
      route = widget.onUnknownRoute!(settings) as Route<T?>?;
      assert(() {
        if (route == null) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary(
                'Navigator.onUnknownRoute returned null when requested to build route "$name".'),
            ErrorDescription(
                'The onUnknownRoute callback must never return null.'),
            DiagnosticsProperty<NavigatorState>('The Navigator was', this,
                style: DiagnosticsTreeStyle.errorProperty),
          ]);
        }
        return true;
      }());
    }
    assert(route != null || allowNull);
    return route;
  }

  Route<T> _wrapRoute<T>(Route<T> route) {
    return switch (route) {
      MaterialPageRoute<T>() => MaterialPageRoute<T>(
          allowSnapshotting: route.allowSnapshotting,
          settings: route.settings,
          requestFocus: route.requestFocus,
          maintainState: route.maintainState,
          fullscreenDialog: route.fullscreenDialog,
          barrierDismissible: route.barrierDismissible,
          builder: (context) {
            return widget.childBuilder(
              context,
              route.builder(context),
            );
          },
        ),
      DialogRoute<T>() => RawDialogRoute<T>(
          pageBuilder: (context, a, sa) {
            return widget.childBuilder(
              context,
              route.buildPage(context, a, sa),
            );
          },
          settings: route.settings,
          barrierDismissible: route.barrierDismissible,
          barrierColor: route.barrierColor,
          barrierLabel: route.barrierLabel,
          transitionDuration: route.transitionDuration,
          traversalEdgeBehavior: route.traversalEdgeBehavior,
          anchorPoint: route.anchorPoint,
          requestFocus: route.requestFocus,
        ),
      CupertinoPageRoute<T>() => CupertinoPageRoute<T>(
          title: route.title,
          allowSnapshotting: route.allowSnapshotting,
          settings: route.settings,
          requestFocus: route.requestFocus,
          maintainState: route.maintainState,
          fullscreenDialog: route.fullscreenDialog,
          barrierDismissible: route.barrierDismissible,
          builder: (context) {
            return widget.childBuilder(
              context,
              route.builder(context),
            );
          },
        ),
      _ => route,
    };
  }
}

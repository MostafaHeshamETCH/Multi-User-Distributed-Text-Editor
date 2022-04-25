import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class PageTransition {
  const PageTransition();

  PageTransitionsBuilder get transitionsBuilder;
  Duration get duration;

  static const PageTransition none = _NoPageTransition();
  static const PageTransition fadeUpwards = _FadeUpwardsPageTransition();
  static const PageTransition cupertino = _CupertinoPageTransition();
  static const PageTransition zoom = _ZoomPageTransition();

  static PageTransition platformDefault(TargetPlatform platform) {
    if (kIsWeb) {
      return PageTransition.none;
    }

    switch (platform) {
      case TargetPlatform.android:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
        return PageTransition.fadeUpwards;

      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return PageTransition.cupertino;
    }
  }
}

class _NoPageTransition extends PageTransition {
  const _NoPageTransition();

  @override
  final Duration duration = const Duration(microseconds: 1);

  @override
  final PageTransitionsBuilder transitionsBuilder =
      const _NoPageTransitionBuilder();
}

class _NoPageTransitionBuilder extends PageTransitionsBuilder {
  const _NoPageTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class _CupertinoPageTransition extends PageTransition {
  const _CupertinoPageTransition();

  @override
  final Duration duration = const Duration(milliseconds: 400);

  @override
  final PageTransitionsBuilder transitionsBuilder =
      const CupertinoPageTransitionsBuilder();
}

class _FadeUpwardsPageTransition extends PageTransition {
  const _FadeUpwardsPageTransition();

  @override
  final Duration duration = const Duration(milliseconds: 300);

  @override
  final PageTransitionsBuilder transitionsBuilder =
      const FadeUpwardsPageTransitionsBuilder();
}

class _ZoomPageTransition extends PageTransition {
  const _ZoomPageTransition();

  @override
  final Duration duration = const Duration(milliseconds: 300);

  @override
  final PageTransitionsBuilder transitionsBuilder =
      const ZoomPageTransitionsBuilder();
}

class TransitionPage<T> extends TransitionBuilderPage<T> {
  const TransitionPage({
    required this.child,
    this.pushTransition,
    this.popTransition,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.opaque = true,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) : super(
          child: child,
          key: key,
          name: name,
          arguments: arguments,
          restorationId: restorationId,
        );
  final PageTransition? pushTransition;

  final PageTransition? popTransition;

  @override
  PageTransition buildPushTransition(BuildContext context) {
    if (pushTransition == null) {
      return PageTransition.platformDefault(Theme.of(context).platform);
    }

    return pushTransition!;
  }

  @override
  PageTransition buildPopTransition(BuildContext context) {
    if (popTransition == null) {
      return PageTransition.platformDefault(Theme.of(context).platform);
    }

    return popTransition!;
  }

  @override
  final Widget child;

  @override
  final bool maintainState;

  @override
  final bool fullscreenDialog;

  @override
  final bool opaque;
}

/// A page that can be subclassed to provide push and pop animations.
///
/// When a page is pushed, [buildPushTransition] is called, and the returned
/// transition is used to animate the page onto the screen.
///
/// When a page is popped, [buildPopTransition] is called, and the returned
/// transition is used to animate the page off the screen.
abstract class TransitionBuilderPage<T> extends Page<T> {
  /// Initialize a page that provides separate push and pop animations.
  const TransitionBuilderPage({
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.opaque = true,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) : super(
          key: key,
          name: name,
          arguments: arguments,
          restorationId: restorationId,
        );

  /// Called when this page is pushed, returns a [PageTransition] to configure
  /// the push animation.
  ///
  /// Return `PageTransition.none` for an immediate push with no animation.
  PageTransition buildPushTransition(BuildContext context);

  /// Called when this page is popped, returns a [PageTransition] to configure
  /// the pop animation.
  ///
  /// Return `PageTransition.none` for an immediate pop with no animation.
  PageTransition buildPopTransition(BuildContext context);

  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  final bool fullscreenDialog;

  /// {@macro flutter.widgets.TransitionRoute.opaque}
  final bool opaque;

  @override
  Route<T> createRoute(BuildContext context) {
    return TransitionBuilderPageRoute<T>(page: this);
  }
}

/// The route created by by [TransitionBuilderPage], which delegates push and
/// pop transition animations to that page.
class TransitionBuilderPageRoute<T> extends PageRoute<T> {
  /// Initialize a route which delegates push and pop transition animations to
  /// the provided [page].
  TransitionBuilderPageRoute({
    required TransitionBuilderPage<T> page,
  }) : super(settings: page);

  TransitionBuilderPage<T> get _page => settings as TransitionBuilderPage<T>;

  /// This value is not used.
  ///
  /// The actual durations are provides by the [PageTransition] objects.
  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: _page.child,
    );
  }

  @override
  bool didPop(T? result) {
    final transition = _page.buildPopTransition(navigator!.context);
    controller!.reverseDuration = transition.duration;
    return super.didPop(result);
  }

  @override
  TickerFuture didPush() {
    final transition = _page.buildPushTransition(navigator!.context);
    controller!.duration = transition.duration;
    return super.didPush();
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final isPopping = controller!.status == AnimationStatus.reverse;

    // If the push is complete we build the pop transition.
    // This is so cupertino back user gesture will work, even if a cupertino
    // transition wasn't used to show this page.
    final pushIsComplete = controller!.status == AnimationStatus.completed;

    final transition =
        (isPopping || pushIsComplete || navigator!.userGestureInProgress)
            ? _page.buildPopTransition(navigator!.context)
            : _page.buildPushTransition(navigator!.context);

    return transition.transitionsBuilder
        .buildTransitions(this, context, animation, secondaryAnimation, child);
  }

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  bool get opaque => _page.opaque;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
}
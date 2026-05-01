import 'dart:ui';

import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AppLoadingOverlay extends StatefulWidget {
  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  State<AppLoadingOverlay> createState() => _AppLoadingOverlayState();
}

class _AppLoadingOverlayState extends State<AppLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0,
      upperBound: 3,
    );
    if (widget.isLoading) _controller.forward();
  }

  @override
  void didUpdateWidget(AppLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isLoading && widget.isLoading) {
      _controller.forward();
    } else if (oldWidget.isLoading && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: AbsorbPointer(
            absorbing: widget.isLoading,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final value = _controller.value;
                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: value, sigmaY: value),
                  child: Container(
                    alignment: Alignment.center,
                    child: widget.isLoading
                        ? LoadingAnimationWidget.discreteCircle(
                            color: t.primary,
                            size: 70,
                            secondRingColor: t.darkPrimary,
                            thirdRingColor: t.light,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

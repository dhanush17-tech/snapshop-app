import 'package:flutter/material.dart';

class FadedEdges extends StatelessWidget {
  const FadedEdges(
      {Key? key,
      required this.child,
      this.colors,
      this.stops,
      this.isHorizontal = false})
      : super(key: key);
  final Widget child;
  final List<Color>? colors;
  final List<double>? stops;
  final bool isHorizontal;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
        blendMode: BlendMode.dstOut,
        shaderCallback: (Rect rect) => LinearGradient(
                colors: colors ??
                    [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.white.withOpacity(1)
                    ],
                stops: stops ?? const [0.15, 0.85, 1.0],
                begin:
                    !isHorizontal ? Alignment.topCenter : Alignment.centerLeft,
                end: !isHorizontal
                    ? Alignment.bottomCenter
                    : Alignment.centerRight)
            .createShader(rect),
        child: child);
  }
}

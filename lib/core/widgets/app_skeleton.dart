import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/core/widgets/base/app_stateless.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppSkeleton extends AppStateless {
  const AppSkeleton({super.key, this.width, this.child, this.height, this.margin});

  final double? width;
  final double? height;
  final Widget? child;
  final EdgeInsets? margin;

  @override
  Widget builder(BuildContext context, AppTheme theme) {
    return Shimmer.fromColors(
      baseColor: theme.bg,
      highlightColor: theme.gray.withOpacity(0.01),
      child: child ?? Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
        ),
      ),
    );
  }
}
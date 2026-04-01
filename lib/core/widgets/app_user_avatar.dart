import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.photoUrl, this.radius = 23});

  final String? photoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: t.lightGray, width: 1),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: t.lightGray,
        backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
            ? NetworkImage(photoUrl!)
            : null,
        child: photoUrl == null || photoUrl!.isEmpty
            ? Icon(Icons.person, color: t.gray, size: 25)
            : null,
      ),
    );
  }
}

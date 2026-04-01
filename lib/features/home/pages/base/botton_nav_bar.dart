import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({
    Key? key,
    required this.page,
    required this.onChanged,
  }) : super(key: key);

  final int page;
  final Function(int) onChanged;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    final AppTheme t = context.watch();

    final w = (MediaQuery.sizeOf(context).width - (5 * 48)) / 6;

    const labels = ['Início', 'Agenda', 'Novo', 'Notificações', 'Perfil'];

    return SafeArea(
      top: false,
      child: SizedBox(
        height: 88,
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(36),
                  bottom: Radius.circular(36),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    top: 10,
                    left: w * (widget.page + 1) + widget.page * 48,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: 48,
                      height: 42,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: t.primary.withOpacity(0.13)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int i = 0; i < 5; i++)
                          GestureDetector(
                            onTap: i != 2
                                ? () {
                                    widget.onChanged(i);
                                  }
                                : null,
                            child: SizedBox(
                              width: 48,
                              height: 44,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    [
                                      Icons.home,
                                      Icons.calendar_month,
                                      Icons.add,
                                      Icons.notifications_none,
                                      Icons.account_circle_outlined
                                    ][i],
                                    size: 24,
                                    color: widget.page == i ? t.primary : t.textSubtitle,
                                  ),
                                  //const SizedBox(height: 2),
                                  //  Text(
                                  //  labels[i],
                                  //  style: TextStyle(
                                  //   fontSize: 10,
                                  //   color: widget.page == i
                                  //      ? t.primary
                                  //      : t.textSubtitle,
                                  //   ),
                                  //   ),
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: () {
                  widget.onChanged(2);
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.primary,
                  ),
                  child: const Icon(
                    Icons.apps,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

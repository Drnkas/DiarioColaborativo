import 'package:diario_colaborativo/features/auth/session/session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppSessionObserver extends StatefulWidget {
  const AppSessionObserver({Key? key, required this.child, required this.listener}) : super(key: key);

  final Widget child;
  final Function(SessionState) listener;

  @override
  State<AppSessionObserver> createState() => _AppSessionObserverState();
}

class _AppSessionObserverState extends State<AppSessionObserver> {

  @override
  void initState() {
    super.initState();

    final SessionCubit sessionCubit = context.read();
    widget.listener(sessionCubit.state);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionCubit, SessionState>(
      listener: (context, state) {
        widget.listener(state);
      },
      child: widget.child,
    );
  }
}

import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/features/auth/session/session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeHeaderSection extends StatelessWidget {
  const HomeHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AppTheme t = context.watch();

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                final sessionCubit = context.read<SessionCubit>();
                if (sessionCubit.state.loggedUser != null) {
                  sessionCubit.logout();
                } else {
                  sessionCubit.login(email: 'teste@teste.com', password: '123456789');
                }
              },
              color: t.black,
              icon: const Icon(Icons.menu),
            ),
            const SizedBox(width: 8),
            BlocBuilder<SessionCubit, SessionState>(
              builder: (context, state) {
                return Text(
                  'Olá, ${state.loggedUser?.name ?? 'visitante'}',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

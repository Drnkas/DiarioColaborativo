import 'package:diario_colaborativo/core/route/app_routes.dart';
import 'package:diario_colaborativo/core/widgets/app_base_page.dart';
import 'package:diario_colaborativo/core/widgets/app_button.dart';
import 'package:diario_colaborativo/core/widgets/app_outlined_button.dart';
import 'package:diario_colaborativo/core/widgets/app_social_button.dart';
import 'package:diario_colaborativo/core/widgets/app_text_button.dart';
import 'package:diario_colaborativo/core/widgets/app_text_field.dart';
import 'package:diario_colaborativo/features/auth/models/email.dart';
import 'package:diario_colaborativo/features/auth/models/password.dart';
import 'package:diario_colaborativo/features/auth/pages/login/login_page_actions.dart';
import 'package:diario_colaborativo/features/auth/pages/login/login_page_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> implements LoginPageActions {
  @override
  Widget build(BuildContext context) {
    final AppTheme t = context.watch();

    return BlocProvider(
      create: (context) => LoginPageCubit(this),
      child: BlocBuilder<LoginPageCubit, LoginPageState>(
          builder: (context, state) {
        return AppBasePage(
          isLoading: state.isLoading,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo_rosa.png',
                ),
              ),

              AppTextField(
                title: 'E-mail',
                hint: 'Informe seu e-mail',
                textInputType: TextInputType.emailAddress,
                onChanged: context.read<LoginPageCubit>().onEmailChanged,
                error: switch (state.email.displayError) {
                  EmailValidationError.empty => 'Campo obrigatório',
                  EmailValidationError.invalid => 'E-mail inválido',
                  _ => null,
                },
              ),
              const SizedBox(height: 24),
              AppTextField(
                title: 'Senha',
                hint: '********',
                obscure: true,
                onChanged: context.read<LoginPageCubit>().onPasswordChanged,
                error: switch (state.password.displayError) {
                  PasswordValidationError.empty => 'Campo obrigatório',
                  PasswordValidationError.tooShort => 'Senha muito curta',
                  _ => null,
                },
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Entrar',
                onPressed: state.isValid
                    ? () {
                        FocusScope.of(context).unfocus();
                        context.read<LoginPageCubit>().onLoginPressed();
                      }
                    : null,
              ),
              const SizedBox(height: 24),

              // Divisor "OU"
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Ou',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
                ],
              ),
              const SizedBox(height: 24),
              // Botões sociais
              AppGoogleButton(
                onPressed: state.isLoading
                    ? null
                    : () {
                        context.read<LoginPageCubit>().onGoogleLoginPressed();
                      },
                isLoading: state.isLoading,
              ),
              AppTextButton(
                label: 'Não tem uma conta? Cadastre-se',
                color: t.primary,
                onPressed: () => context.push(AppRoutes.signUp.fullPath),
              ),

              const SizedBox(height: 32),

              const SizedBox(height: 12),
            ],
          ),
        );
      }),
    );
  }

  @override
  void navToHome() {
    context.go(AppRoutes.home);
  }
}

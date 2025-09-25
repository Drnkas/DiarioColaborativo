import 'package:diario_colaborativo/core/route/app_routes.dart';
import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/core/widgets/app_base_page.dart';
import 'package:diario_colaborativo/core/widgets/app_text_field.dart';
import 'package:diario_colaborativo/features/auth/pages/sign_up/sign_up_actions.dart';
import 'package:diario_colaborativo/features/auth/pages/sign_up/signup_page_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../models/email.dart';
import '../../models/full_name.dart';
import '../../models/password.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> implements SignUpActions {
  @override
  Widget build(BuildContext context) {
    final AppTheme t = context.watch();

    return BlocProvider(
      create: (context) => SignUpCubit(this),
      child: BlocBuilder<SignUpCubit,SignUpState>(
          builder: (context, state) {
            return AppBasePage(
              title: 'Criar conta',
              isLoading: state.isLoading,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: AppLogo(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Cadastre-se',
                    textAlign: TextAlign.center,
                    style: t.heading36Bold,
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    title: 'Nome Completo',
                    hint: 'Informe seu Nome Completo',
                    textInputType: TextInputType.name,
                    onChanged: context.read<SignUpCubit>().onFullNameChanged,
                    error: switch(state.fullName.displayError) {
                      FullNameValidationError.empty => 'Campo obrigatório',
                      FullNameValidationError.incomplete => 'Informe seu nome completo',
                      _ => null,
                    },
                  ),                  
                  const SizedBox(height: 24),
                  AppTextField(
                    title: 'E-mail',
                    hint: 'Informe seu e-mail',
                    textInputType: TextInputType.emailAddress,
                    onChanged: context.read<SignUpCubit>().onEmailChanged,
                    error: switch(state.email.displayError) {
                      EmailValidationError.empty => 'Campo obrigatório',
                      EmailValidationError.invalid => 'E-mail inválido',
                      _ => null,
                    },
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    title: 'Senha',
                    hint: 'Informe uma senha forte',
                    obscure: true,
                    onChanged: context.read<SignUpCubit>().onPasswordChanged,
                    error:switch(state.password.displayError) {
                      PasswordValidationError.empty => 'Campo obrigatório',
                      PasswordValidationError.tooShort => 'Senha muito curta',
                      _ => null,
                    },
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Cadastrar',
                    onPressed: state.isValid ? () {
                      FocusScope.of(context).unfocus();
                      context.read<SignUpCubit>().onSignUpPressed();
                    }  : null,
                  )
                ],
              ),
            );
          }
      ),
    );
  }

  @override
  void navToHome() {
    context.go(AppRoutes.home);
  }
}

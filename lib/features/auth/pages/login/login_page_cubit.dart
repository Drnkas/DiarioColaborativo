import 'package:bloc/bloc.dart';
import 'package:diario_colaborativo/core/helpers/result.dart';
import 'package:diario_colaborativo/core/widgets/alert/alert_area_cubit.dart';
import 'package:diario_colaborativo/features/auth/data/results/login_failed.dart';
import 'package:diario_colaborativo/features/auth/models/password.dart';
import 'package:diario_colaborativo/features/auth/pages/login/login_page_actions.dart';
import 'package:diario_colaborativo/features/auth/session/session_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../../../../di/di.dart';
import '../../models/email.dart';

part 'login_page_state.dart';

class LoginPageCubit extends Cubit<LoginPageState> {
  LoginPageCubit(this._actions,
      {SessionCubit? sessionCubit, AlertAreaCubit? alertAreaCubit})
      : _sessionCubit = sessionCubit ?? getIt(),
        _alertAreaCubit = alertAreaCubit ?? getIt(),
        super(const LoginPageState.empty());

  final SessionCubit _sessionCubit;
  final AlertAreaCubit _alertAreaCubit;
  final LoginPageActions _actions;

  Future<void> onLoginPressed() async {
    emit(state.copyWith(isLoading: true));

    final result = await _sessionCubit.login(
        email: state.email.value, password: state.password.value);

    switch (result) {
      case Success():
        _actions.navToHome();
      case Failure(error: final error):
        _alertAreaCubit.showAlert(Alert.error(
            title: switch (error) {
          LoginFailed.invalidCredentials => 'E-mail/Senha inválidos.',
          LoginFailed.offline =>
            'Verifique sua conexão com a internet e tente novamente.',
          _ => 'Falha ao realizar o login. Por favor tente novamente.'
        }));
    }
    emit(state.copyWith(isLoading: false));
  }

  void onEmailChanged(String value) {
    emit(state.copyWith(email: Email.dirty(value)));
  }

  void onPasswordChanged(String value) {
    emit(state.copyWith(password: Password.dirty(value, false)));
  }

  Future<void> onGoogleLoginPressed() async {
    emit(state.copyWith(isLoading: true));

    final result = await _sessionCubit.signInWithGoogle();

    switch (result) {
      case Success():
        _actions.navToHome();
      case Failure(error: final error):
        if (error == LoginFailed.cancelled) return;
        _alertAreaCubit.showAlert(Alert.error(
            title: switch (error) {
          LoginFailed.accountExistsWithDifferentCredential =>
            'Este e-mail já está cadastrado com outro método. Use e-mail e senha para entrar.',
          LoginFailed.invalidCredentials => 'Falha na autenticação com Google.',
          LoginFailed.offline =>
            'Verifique sua conexão com a internet e tente novamente.',
          _ =>
            'Falha ao realizar o login com Google. Por favor tente novamente.'
        }));
    }
    emit(state.copyWith(isLoading: false));
  }

  // Future<void> onAppleLoginPressed() async {
  //   emit(state.copyWith(isLoading: true));

  //   final result = await _sessionCubit.signInWithApple();

  //   switch (result) {
  //     case Success():
  //       _actions.navToHome();
  //     case Failure(error: final error):
  //       _alertAreaCubit.showAlert(Alert.error(
  //           title: switch (error) {
  //         LoginFailed.invalidCredentials => 'Falha na autenticação com Apple.',
  //         LoginFailed.offline =>
  //           'Verifique sua conexão com a internet e tente novamente.',
  //         _ => 'Falha ao realizar o login com Apple. Por favor tente novamente.'
  //       }));
  //   }
  //   emit(state.copyWith(isLoading: false));
  // }
}

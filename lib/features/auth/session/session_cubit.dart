import 'package:bloc/bloc.dart';
import 'package:diario_colaborativo/di/di.dart';
import 'package:diario_colaborativo/features/auth/data/auth_repository.dart';
import 'package:diario_colaborativo/features/diary/diary_cubit/diary_comments_cubit.dart';
import 'package:diario_colaborativo/features/diary/diary_cubit/diary_cubit.dart';
import 'package:diario_colaborativo/features/auth/data/results/sign_up_failed.dart';
import 'package:diario_colaborativo/features/auth/models/sign_up_dto.dart';
import 'package:equatable/equatable.dart';

import '../../../core/helpers/result.dart';
import '../data/results/login_failed.dart';
import '../data/results/validate_token_failed.dart';
import '../models/user.dart';

part 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit({AuthRepository? authRepository})
      : _authRepository = authRepository ?? getIt(),
        super(const SessionState());

  final AuthRepository _authRepository;

  Future<Result<LoginFailed, AppUser>> login(
      {required String email, required String password}) async {
    final result =
        await _authRepository.login(email: email, password: password);

    if (result case Success(object: final user)) {
      emit(state.copyWith(loggedUser: user));
    }

    return result;
  }

  Future<Result<SignUpFailed, AppUser>> signUp(SignUpDto signUpDto) async {
    final result = await _authRepository.signUp(signUpDto);
    if (result case Success(object: final user)) {
      emit(state.copyWith(loggedUser: user));
    }
    return result;
  }

  Future<Result<ValidateTokenFailed, AppUser>> validateToken() async {
    final result = await _authRepository.validateToken();

    if (result case Success(object: final user)) {
      emit(state.copyWith(loggedUser: user));
    }

    return result;
  }

  Future<Result<LoginFailed, AppUser>> signInWithGoogle() async {
    final result = await _authRepository.signInWithGoogle();

    if (result case Success(object: final user)) {
      emit(state.copyWith(loggedUser: user));
    }

    return result;
  }

  // Future<Result<LoginFailed, AppUser>> signInWithApple() async {
  //   final result = await _authRepository.signInWithApple();

  //   if (result case Success(object: final user)) {
  //     emit(state.copyWith(loggedUser: user));
  //   }

  //   return result;
  // }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(const SessionState(loggedUser: null));
    getIt<DiaryCommentsCubit>().clearAllCaches();
    getIt<DiaryCubit>().clearUserCaches();
  }

  /// Atualiza os dados do usuário logado
  void updateUser(AppUser updatedUser) {
    emit(SessionState(loggedUser: updatedUser));
  }
}

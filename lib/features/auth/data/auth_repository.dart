import 'package:diario_colaborativo/core/device/app_secure_storage.dart';
import 'package:diario_colaborativo/features/auth/data/auth_datasource.dart';
import 'package:diario_colaborativo/features/auth/data/results/login_failed.dart';
import 'package:diario_colaborativo/features/auth/data/results/sign_up_failed.dart';
import 'package:diario_colaborativo/features/auth/data/results/validate_token_failed.dart';
import 'package:diario_colaborativo/features/auth/models/sign_up_dto.dart';
import 'package:diario_colaborativo/features/auth/models/user.dart';

import '../../../core/helpers/result.dart';

class AuthRepository {

  AuthRepository(this._datasource, this._appSecureStorage);

  final AuthDatasource _datasource;
  final AppSecureStorage _appSecureStorage;

  Future<Result<LoginFailed, AppUser>> login({required String email, required String password}) async {
    final result = await _datasource.login(email: email, password: password);

    if(result case Success(object: final user)){
      await _appSecureStorage.saveSessionToken(user.token);
    }

    return result;
  }

  Future<Result<SignUpFailed, AppUser>> signUp(SignUpDto signUpDto) async {
    final result = await _datasource.signUp(signUpDto);
    if(result case Success(object: final user)) {
      await _appSecureStorage.saveSessionToken(user.token);
    }
    return result;
  }

  Future<Result<ValidateTokenFailed, AppUser>> validateToken() async {
    final token = await _appSecureStorage.getSessionToken();
    if(token == null) {
      return const Failure(ValidateTokenFailed.invalidToken);
    }
    return _datasource.validateToken(token);
  }

  Future<void> logout() {
    return _appSecureStorage.deleteSessionToken();
  }

}
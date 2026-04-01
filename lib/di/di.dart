import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diario_colaborativo/core/device/app_device_settings.dart';
import 'package:diario_colaborativo/core/device/app_external_launcher.dart';
import 'package:diario_colaborativo/core/firebase/messaging/app_messaging.dart';
import 'package:diario_colaborativo/core/flavor/flavor.dart';
import 'package:diario_colaborativo/core/widgets/alert/alert_area_cubit.dart';
import 'package:diario_colaborativo/features/auth/data/auth_datasource.dart';
import 'package:diario_colaborativo/features/auth/session/session_cubit.dart';
import 'package:diario_colaborativo/features/profile/data/profile_datasource.dart';
import 'package:diario_colaborativo/features/profile/data/profile_repository.dart';
import 'package:diario_colaborativo/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/device/app_location.dart';
import '../core/device/app_package_info.dart';
import '../core/device/app_preferences.dart';
import '../core/device/app_secure_storage.dart';
import '../core/firebase/crashlytics/app_crashlytics.dart';
import '../core/remote_config/app_remote_config.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/diary/data/diary_datasource.dart';
import '../features/diary/data/diary_repository.dart';
import '../features/diary/diary_cubit/diary_cubit.dart';

final getIt = GetIt.I;

Future<void> configureDependencies(FlavorConfig config) async {
  getIt.registerSingleton(config);

  // Preferences
  final preferences = await SharedPreferences.getInstance();
  getIt.registerSingleton(preferences);
  getIt.registerFactory(() => AppPreferences(getIt()));

  // Secure Storage
  getIt.registerFactory(() => const FlutterSecureStorage());
  getIt.registerFactory(() => AppSecureStorage(getIt()));

  // Firebase Auth - REGISTRAR ANTES DOS DEPENDENTES!
  getIt.registerSingleton(FirebaseAuth.instance);
  // serverClientId (Web Client ID) é necessário para Firebase Auth no Android.
  getIt.registerFactory(() => GoogleSignIn(
        serverClientId: DefaultFirebaseOptions.webClientId,
      ));

  getIt.registerSingleton(AlertAreaCubit());

  // Auth - AGORA PODE REGISTRAR DEPOIS DAS DEPENDÊNCIAS
  getIt.registerFactory<AuthDatasource>(() => RemoteAuthDatasource(getIt(), getIt()));
  getIt.registerLazySingleton(() => AuthRepository(getIt(), getIt()));

  getIt.registerSingleton(FirebaseCrashlytics.instance);
  getIt.registerSingleton(AppCrashlytics(getIt()));

  getIt.registerSingleton(FirebaseMessaging.instance);
  getIt.registerSingleton(AppMessaging(getIt()));

  getIt.registerSingleton(FirebaseRemoteConfig.instance);
  getIt.registerSingleton(AppRemoteConfig(getIt()));

  getIt.registerSingleton(SessionCubit());

  // Diary - entradas do diário (Firestore + Storage)
  getIt.registerSingleton(FirebaseFirestore.instance);
  getIt.registerSingleton(FirebaseStorage.instance);
  getIt.registerFactory<DiaryDatasource>(
    () => RemoteDiaryDatasource(
      getIt<FirebaseFirestore>(),
      getIt<FirebaseStorage>(),
    ),
  );
  getIt.registerLazySingleton(() => DiaryRepository(
        getIt<DiaryDatasource>(),
        getIt<SessionCubit>(),
      ));
  getIt.registerLazySingleton(() => DiaryCubit());

  getIt.registerFactory<ProfileDatasource>(
    () => RemoteProfileDatasource(
      getIt<FirebaseFirestore>(),
      getIt<FirebaseStorage>(),
    ),
  );
  getIt.registerLazySingleton(() => ProfileRepository(
        getIt<ProfileDatasource>(),
        getIt<SessionCubit>(),
      ));

  getIt.registerFactory(() => AppPackageInfo());
  getIt.registerFactory(() => AppLocation());
  getIt.registerFactory(() => AppDeviceSettings());
  getIt.registerFactory(() => AppExternalLauncher());
}

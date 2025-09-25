import 'dart:ui';

import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:diario_colaborativo/core/flavor/flavor.dart';
import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/core/widgets/alert/alert_area.dart';
import 'package:diario_colaborativo/di/di.dart';
import 'package:diario_colaborativo/features/auth/session/session_cubit.dart';
import 'package:diario_colaborativo/firebase_options.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'core/route/app_routes.dart';

void bootstrap(FlavorConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = (error) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(error);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await configureDependencies(config);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => AppTheme(),
      child: BlocProvider.value(
        value: getIt<SessionCubit>(),
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          builder: (context, widget) {
            final newChild = Stack(
              children: [
                if (widget != null) widget,
                const AlertArea(),
              ],
            );

            return ResponsiveBreakpoints.builder(
              child: newChild,
              breakpoints: [
                const Breakpoint(start: 0, end: 450, name: MOBILE),
                const Breakpoint(start: 451, end: 800, name: TABLET),
                const Breakpoint(start: 801, end: 1000, name: TABLET),
                const Breakpoint(start: 1001, end: 1200, name: DESKTOP),
                const Breakpoint(start: 1201, end: 2460, name: DESKTOP),
                const Breakpoint(start: 2461, end: double.infinity, name: '4K'),
              ],
            );
          },
          locale: DevicePreview.locale(context),
          theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}

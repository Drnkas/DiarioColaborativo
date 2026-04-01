import 'package:diario_colaborativo/di/di.dart';
import 'package:diario_colaborativo/features/diary/diary_cubit/diary_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/route/app_routes.dart';
import '../../../profile/pages/profile_page.dart';
import '../home/home_page.dart';
import 'botton_nav_bar.dart';
//import '../notifications/notifications_page.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  int page = 0;

  final PageController pageController = PageController(keepPage: true);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<DiaryCubit>(),
      child: Scaffold(
        bottomNavigationBar: BottomNavBar(
        page: page,
        onChanged: (p) {
          if (p == 2) {
            context.push(AppRoutes.createpost);
            return;
          }
          setState(() {
            page = p;
          });
          pageController.animateToPage(
            page,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        },
      ),
      extendBody: true,
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const HomePage(),
          Container(
            color: Colors.red,
          ),
          Container(
            color: Colors.grey,
          ),
          Container(
            color: Colors.pink,
          ),
          //const NotificationsPage(),
          const ProfilePage(),
        ],
      ),
    ));
  }
}

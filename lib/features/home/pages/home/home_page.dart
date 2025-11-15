import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/features/home/pages/home/widgets/home_header_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    final AppTheme t = context.watch();

    return Scaffold(
      body: Column(
        children: [
          const HomeHeaderSection(),     
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

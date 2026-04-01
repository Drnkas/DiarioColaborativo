import 'package:diario_colaborativo/core/route/app_routes.dart';
import 'package:diario_colaborativo/di/di.dart';
import 'package:diario_colaborativo/features/diary/diary_cubit/diary_cubit.dart';
import 'package:diario_colaborativo/features/diary/diary_cubit/diary_state.dart';
import 'package:diario_colaborativo/features/diary/widgets/diary_card.dart';
import 'package:diario_colaborativo/features/home/pages/home/widgets/home_prompt_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {

  @override
  void initState() {
    super.initState();
    getIt<DiaryCubit>().loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<DiaryCubit, DiaryState>(
      builder: (context, state) {
        return Scaffold(
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // const HomeHeaderSection(),
                  Expanded(
                    child: state.isLoading && state.entries.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                
                                return HomePromptCard(
                                  onTap: () =>
                                      context.push(AppRoutes.createpost),
                                );
                              }

                              final post = state.entries[index - 1];
                              return DiaryCard(
                                entry: post,
                                onTap: () => context.push(
                                  '${AppRoutes.postDetail}/${post.id}',
                                  extra: post,
                                ),
                                onDelete: () =>
                                    _confirmDelete(context, post.id),
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemCount: state.entries.length + 1,
                          ),
                  ),
                ],
              ),
            ),
          );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir entrada?'),
        content: const Text(
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      getIt<DiaryCubit>().deleteEntry(id);
    }
  }

  @override
  bool get wantKeepAlive => true;
}

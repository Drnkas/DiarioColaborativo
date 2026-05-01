import 'dart:io';

import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/core/widgets/app_loading_overlay.dart';
import 'package:diario_colaborativo/di/di.dart';
import 'package:diario_colaborativo/features/auth/models/user.dart';
import 'package:diario_colaborativo/features/auth/session/session_cubit.dart';
import 'package:diario_colaborativo/features/diary/diary_cubit/diary_cubit.dart';
import 'package:diario_colaborativo/features/diary/diary_cubit/diary_state.dart';
import 'package:diario_colaborativo/features/diary/widgets/diary_card.dart';
import 'package:diario_colaborativo/features/profile/data/profile_repository.dart';
import 'package:diario_colaborativo/features/profile/pages/profile_page_cubit.dart';
import 'package:diario_colaborativo/features/profile/pages/profile_page_state.dart';
import 'package:diario_colaborativo/features/profile/widgets/edit_profile_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionCubit = context.read<SessionCubit>();

    return BlocProvider(
      create: (_) {
        final cubit = ProfilePageCubit(
          profileRepository: getIt<ProfileRepository>(),
          sessionCubit: sessionCubit,
        );

        final loggedUser = sessionCubit.state.loggedUser;

        if (loggedUser != null) cubit.setUser(loggedUser);
        cubit.loadUserProfile();

        return cubit;
      },
      child: BlocListener<ProfilePageCubit, ProfilePageState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == ProfilePageStatus.updated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil atualizado com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state.status == ProfilePageStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Erro ao atualizar perfil.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: const _ProfilePageView(),
      ),
    );
  }
}

class _ProfilePageView extends StatelessWidget {
  const _ProfilePageView();

  Future<void> _openEditProfile(BuildContext context, AppUser user) async {
    await showEditProfileModal(
      context: context,
      user: user,
      onSave: ({
        String? displayName,
        String? bio,
        File? profileImage,
        File? coverImage,
      }) async {
        if (!context.mounted) return;
        context.read<ProfilePageCubit>().updateProfile(
              displayName: displayName,
              bio: bio,
              profileImage: profileImage,
              coverImage: coverImage,
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    final state = context.watch<ProfilePageCubit>().state;
    final currentUser = state.user;

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Usuário não encontrado',
                style: t.body16Bold.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final handle = '@${currentUser.displayName.toLowerCase().replaceAll(' ', '')}';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: AppLoadingOverlay(
          isLoading: state.status == ProfilePageStatus.loading,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Capa + avatar sobreposto
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: t.primary.withOpacity(0.3),
                    image: currentUser.coverImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(currentUser.coverImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                // Avatar sobrepondo a capa
                Positioned(
                  bottom: -44,
                  left: 20,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.primary,
                      border: Border.all(color: Colors.white, width: 3),
                      image: currentUser.photoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(currentUser.photoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: currentUser.photoUrl == null
                        ? const Icon(Icons.person, color: Colors.white, size: 44)
                        : null,
                  ),
                ),
              ],
            ),
            // Espaço do avatar + botões à direita
            Padding(
              padding: const EdgeInsets.only(top: 5, right: 16, left: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _openEditProfile(context, currentUser),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: t.black,
                      side: BorderSide(color: t.black.withOpacity(0.2)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    child: const Text('Editar Perfil'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.settings_outlined, color: t.black.withOpacity(0.6), size: 22),
                    style: IconButton.styleFrom(
                      side: BorderSide(color: t.black.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ),
            // Nome, handle, bio e stats
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(currentUser.displayName, style: t.body16Bold.copyWith(fontSize: 18)),
                  const SizedBox(height: 2),
                  Text(handle,
                      style: t.label11.copyWith(color: t.black.withOpacity(0.45), fontSize: 13)),
                  if (currentUser.bio.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(currentUser.bio, style: t.body16.copyWith(height: 1.5)),
                  ],
                  const SizedBox(height: 12),
                  // Stats inline
                  Row(
                    children: [
                      _StatItem(number: '${currentUser.postsCount}', label: 'posts'),
                      const SizedBox(width: 16),
                      // _StatItem(number: '${currentUser.followersCount}', label: 'curtidas'),
                      //  const SizedBox(width: 16),
                      _StatItem(number: '${currentUser.followingCount}', label: 'salvos'),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            // Tabs
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: t.primary,
              unselectedLabelColor: t.black.withOpacity(0.4),
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
              indicatorColor: t.primary,
              indicatorWeight: 2,
              dividerColor: t.primary.withOpacity(0.15),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.grid_view_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Posts'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bookmark_border_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Salvos'),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  BlocBuilder<DiaryCubit, DiaryState>(
                    builder: (context, state) {
                      final entries =
                          state.entries.where((e) => e.userId == currentUser.uid).toList();

                      if (entries.isEmpty) {
                        return const Center(child: Text('Nenhum post ainda.'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: DiaryCard(entry: entry),
                          );
                        },
                      );
                    },
                  ),
                  Center(child: Text('Salvos')),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(number, style: t.body16Bold.copyWith(fontSize: 13)),
        const SizedBox(width: 4),
        Text(label, style: t.label11.copyWith(color: Colors.black54, fontSize: 13)),
      ],
    );
  }
}

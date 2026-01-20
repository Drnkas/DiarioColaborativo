import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/features/profile/pages/profile_page_cubit.dart';
import 'package:diario_colaborativo/features/profile/pages/profile_page_state.dart';
import 'package:diario_colaborativo/features/profile/widgets/edit_profile_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Versão da ProfilePage usando BLoC pattern
/// Para usar esta versão, você precisa fornecer o ProfilePageCubit via BlocProvider
class ProfilePageWithBloc extends StatelessWidget {
  const ProfilePageWithBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfilePageCubit, ProfilePageState>(
      listener: (context, state) {
        if (state.status == ProfilePageStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Erro desconhecido'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == ProfilePageStatus.loading && state.user == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.user == null) {
          return const Scaffold(
            body: Center(
              child: Text('Usuário não encontrado'),
            ),
          );
        }

        return _ProfileContent(
          state: state,
        );
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final ProfilePageState state;

  const _ProfileContent({
    required this.state,
  });

  void _openEditProfile(BuildContext context) {
    if (state.user == null) return;

    showEditProfileModal(
      context: context,
      user: state.user!,
      onSave: ({displayName, bio, profileImage, coverImage}) async {
        await context.read<ProfilePageCubit>().updateProfile(
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
    final AppTheme t = AppTheme();
    final user = state.user!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // Header rosa (capa)
              Stack(
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: t.primary.withOpacity(0.3),
                      image: user.coverImageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(user.coverImageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 16,
                    child: IconButton(
                      onPressed: () => _openEditProfile(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.edit,
                          color: t.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Conteúdo principal com avatar e informações
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar circular
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: t.primary,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        image: user.photoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(user.photoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: user.photoUrl == null
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 50,
                            )
                          : null,
                    ),
                    const SizedBox(width: 20),
                    // Informações do usuário
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Username
                          Text(
                            '@${user.displayName}',
                            style: t.body16Bold,
                          ),
                          const SizedBox(height: 8),
                          // Estatísticas
                          Row(
                            children: [
                              _buildStatItem('124', 'posts', t),
                              const SizedBox(width: 20),
                              _buildStatItem('${user.followersCount}', 'seguidores', t),
                              const SizedBox(width: 20),
                              _buildStatItem('${user.followingCount}', 'salvos', t),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Bio section
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    if (user.bio.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          user.bio,
                          style: t.body16,
                        ),
                      ),
                    if (user.bio.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Sem descrição',
                          style: t.body16.copyWith(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              // Conteúdo principal
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      const Spacer(),
                      // Tabs de navegação
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildTab(
                                context,
                                'Posts',
                                Icons.grid_view,
                                state.selectedTab == 0,
                                () => context.read<ProfilePageCubit>().changeTab(0),
                                t,
                              ),
                            ),
                            Expanded(
                              child: _buildTab(
                                context,
                                'Salvos',
                                Icons.bookmark_outline,
                                state.selectedTab == 1,
                                () => context.read<ProfilePageCubit>().changeTab(1),
                                t,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Loading overlay
          if (state.status == ProfilePageStatus.loading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label, AppTheme t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: t.body16Bold,
        ),
        Text(
          label,
          style: t.label11,
        ),
      ],
    );
  }

  Widget _buildTab(
    BuildContext context,
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    AppTheme t,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? t.primary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border(
                  bottom: BorderSide(
                    color: t.primary,
                    width: 2,
                  ),
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? t.primary : t.black,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? t.primary : t.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


import 'dart:io';

import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/features/auth/models/user.dart';
import 'package:diario_colaborativo/features/auth/session/session_cubit.dart';
import 'package:diario_colaborativo/features/profile/data/profile_service.dart';
import 'package:diario_colaborativo/features/profile/widgets/edit_profile_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int selectedTab = 0; // 0 = Posts, 1 = Salvos

  Future<void> _openEditProfile(AppUser user) async {
    final result = await showEditProfileModal(
      context: context,
      user: user,
      onSave: ({
        String? displayName,
        String? bio,
        File? profileImage,
        File? coverImage,
      }) async {
        // Atualiza o perfil com upload de imagens
        final service = ProfileService();
        final updatedUser = await service.updateProfileWithImages(
          currentUser: user,
          displayName: displayName,
          bio: bio,
          profileImage: profileImage,
          coverImage: coverImage,
        );

        // Atualiza o SessionState com os novos dados
        if (mounted) {
          context.read<SessionCubit>().updateUser(updatedUser);
        }
      },
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppTheme t = AppTheme();

    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        final currentUser = state.loggedUser;

        // Se não houver usuário logado
        if (currentUser == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_off_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
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

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              // Header rosa (capa)
              Stack(
                children: [
                  Container(
                    height: 120,
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
                  Positioned(
                    top: 40,
                    right: 16,
                    child: IconButton(
                      onPressed: () => _openEditProfile(currentUser),
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
                        image: currentUser.photoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(currentUser.photoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: currentUser.photoUrl == null
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
                            '@${currentUser.displayName}',
                            style: t.body16Bold,
                          ),
                          const SizedBox(height: 8),
                          // Estatísticas
                          Row(
                            children: [
                              _buildStatItem('124', 'posts'),
                              const SizedBox(width: 20),
                              _buildStatItem('${currentUser.followersCount}', 'seguidores'),
                              const SizedBox(width: 20),
                              _buildStatItem('${currentUser.followingCount}', 'salvos'),
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
                    if (currentUser.bio.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          currentUser.bio,
                          style: t.body16,
                        ),
                      ),
                    if (currentUser.bio.isEmpty)
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
                                'Posts',
                                Icons.grid_view,
                                selectedTab == 0,
                                () => setState(() => selectedTab = 0),
                                t,
                              ),
                            ),
                            Expanded(
                              child: _buildTab(
                                'Salvos',
                                Icons.bookmark_outline,
                                selectedTab == 1,
                                () => setState(() => selectedTab = 1),
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
        );
      },
    );
  }

  Widget _buildStatItem(String number, String label) {
    final AppTheme t = AppTheme();

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

  Widget _buildTab(String title, IconData icon, bool isSelected, VoidCallback onTap, AppTheme t) {
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

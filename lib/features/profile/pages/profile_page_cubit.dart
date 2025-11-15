import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:diario_colaborativo/features/auth/models/user.dart';
import 'package:diario_colaborativo/features/profile/data/profile_service.dart';
import 'package:diario_colaborativo/features/profile/pages/profile_page_state.dart';

class ProfilePageCubit extends Cubit<ProfilePageState> {
  final ProfileService _profileService;

  ProfilePageCubit({
    required ProfileService profileService,
  })  : _profileService = profileService,
        super(const ProfilePageState());

  /// Carrega o perfil do usuário
  Future<void> loadUserProfile(String uid) async {
    emit(state.copyWith(status: ProfilePageStatus.loading));

    try {
      final user = await _profileService.getUserProfile(uid);
      
      if (user != null) {
        emit(state.copyWith(
          status: ProfilePageStatus.success,
          user: user,
        ));
      } else {
        emit(state.copyWith(
          status: ProfilePageStatus.error,
          errorMessage: 'Usuário não encontrado',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ProfilePageStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Atualiza o perfil do usuário
  Future<void> updateProfile({
    String? displayName,
    String? bio,
    File? profileImage,
    File? coverImage,
  }) async {
    if (state.user == null) return;

    emit(state.copyWith(status: ProfilePageStatus.loading));

    try {
      final updatedUser = await _profileService.updateProfileWithImages(
        currentUser: state.user!,
        displayName: displayName,
        bio: bio,
        profileImage: profileImage,
        coverImage: coverImage,
      );

      emit(state.copyWith(
        status: ProfilePageStatus.success,
        user: updatedUser,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfilePageStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Muda a tab selecionada (Posts ou Salvos)
  void changeTab(int tabIndex) {
    emit(state.copyWith(selectedTab: tabIndex));
  }

  /// Define o usuário inicial (útil quando já tem o usuário em memória)
  void setUser(AppUser user) {
    emit(state.copyWith(
      status: ProfilePageStatus.success,
      user: user,
    ));
  }
}


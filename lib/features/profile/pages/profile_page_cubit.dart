import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:diario_colaborativo/core/helpers/result.dart';
import 'package:diario_colaborativo/features/auth/models/user.dart';
import 'package:diario_colaborativo/features/auth/session/session_cubit.dart';
import 'package:diario_colaborativo/features/profile/data/profile_repository.dart';
import 'package:diario_colaborativo/features/profile/pages/profile_page_state.dart';

class ProfilePageCubit extends Cubit<ProfilePageState> {
  ProfilePageCubit({
    required ProfileRepository profileRepository,
    required SessionCubit sessionCubit,
  })  : _profileRepository = profileRepository,
        _sessionCubit = sessionCubit,
        super(const ProfilePageState());

  final ProfileRepository _profileRepository;
  final SessionCubit _sessionCubit;

  Future<void> loadUserProfile() async {
    emit(state.copyWith(status: ProfilePageStatus.loading));

    final result = await _profileRepository.getUserProfile();

    switch (result) {
      case Success(object: final user):
        emit(state.copyWith(status: ProfilePageStatus.success, user: user));
      case Failure():
        emit(state.copyWith(
          status: ProfilePageStatus.error,
          errorMessage: 'Não foi possível carregar o perfil.',
        ));
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? bio,
    File? profileImage,
    File? coverImage,
  }) async {
    if (state.user == null) return;

    emit(state.copyWith(status: ProfilePageStatus.loading));

    final result = await _profileRepository.updateUserProfileWithImages(
      displayName: displayName,
      bio: bio,
      profileImage: profileImage,
      coverImage: coverImage,
    );

    switch (result) {
      case Success(object: final user):
        _sessionCubit.updateUser(user);
        emit(state.copyWith(status: ProfilePageStatus.updated, user: user));
      case Failure():
        emit(state.copyWith(
          status: ProfilePageStatus.error,
          errorMessage: 'Não foi possível atualizar o perfil.',
        ));
    }
  }

  void setUser(AppUser user) {
    emit(state.copyWith(status: ProfilePageStatus.success, user: user));
  }
}

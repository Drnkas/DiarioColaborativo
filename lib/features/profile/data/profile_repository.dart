import 'dart:io';

import 'package:diario_colaborativo/core/helpers/result.dart';
import 'package:diario_colaborativo/features/auth/models/user.dart';
import 'package:diario_colaborativo/features/auth/session/session_cubit.dart';
import 'package:diario_colaborativo/features/profile/data/profile_datasource.dart';
import 'package:diario_colaborativo/features/profile/data/results/profile_failed.dart';

class ProfileRepository {
  ProfileRepository(this._datasource, this._sessionCubit);

  final ProfileDatasource _datasource;
  final SessionCubit _sessionCubit;

  String? get _userId => _sessionCubit.state.loggedUser?.uid;

  Future<Result<ProfileFailed, AppUser>> getUserProfile() async {
    final userId = _userId;
    if (userId == null) {
      return const Failure(ProfileFailed.notAuthenticated);
    }

    return _datasource.getUserProfile(userId);
  }
  
  Future<Result<ProfileFailed, AppUser>> updateUserProfile({
    String? displayName,
    String? bio,
    String? photoUrl,
    String? coverImageUrl}) async {

    final userId = _userId;

    if (userId == null) {
      return const Failure(ProfileFailed.notAuthenticated);
    }

    return _datasource.updateUserProfile(
      userId, 
      displayName: displayName, 
      bio: bio, 
      photoUrl: photoUrl, 
      coverImageUrl: coverImageUrl);
  }

  Future<Result<ProfileFailed, AppUser>> updateUserProfileWithImages({
    String? displayName,
    String? bio,
    File? profileImage,
    File? coverImage,
  }) async {
    final currentUser = _sessionCubit.state.loggedUser;
    if (currentUser == null) {
      return const Failure(ProfileFailed.notAuthenticated);
    }
    return _datasource.updateUserProfileWithImages(
      currentUser: currentUser,
      displayName: displayName,
      bio: bio,
      profileImage: profileImage,
      coverImage: coverImage,
    );
  }
}

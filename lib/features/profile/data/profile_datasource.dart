import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diario_colaborativo/core/helpers/result.dart';
import 'package:diario_colaborativo/features/auth/models/user.dart';
import 'package:diario_colaborativo/features/profile/data/results/profile_failed.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class ProfileDatasource {
  Future<Result<ProfileFailed, AppUser>> getUserProfile(String uid);
  Future<Result<ProfileFailed, AppUser>> updateUserProfile(
    String uid, {
    String? displayName,
    String? bio,
    String? photoUrl,
    String? coverImageUrl,
  });
  Future<Result<ProfileFailed, AppUser>> updateUserProfileWithImages({
    required AppUser currentUser,
    String? displayName,
    String? bio,
    File? profileImage,
    File? coverImage,
  });

  Future<void> deleteImage(String imageUrl);
  Future<String> uploadImage(File imageFile, String path);
}

class RemoteProfileDatasource implements ProfileDatasource {
  RemoteProfileDatasource(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  /// Upload de imagem para o Firebase Storage
  @override
  Future<String> uploadImage(File imageFile, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  /// Atualiza o perfil do usuário no Firestore
  @override
  Future<Result<ProfileFailed, AppUser>> updateUserProfile(
    String uid, {
    String? displayName,
    String? bio,
    String? photoUrl,
    String? coverImageUrl,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (displayName != null) updates['displayName'] = displayName;
      if (bio != null) updates['bio'] = bio;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (coverImageUrl != null) updates['coverImageUrl'] = coverImageUrl;

      if (updates.isEmpty) return const Failure(ProfileFailed.unknown);

      final docRef = _firestore.collection('users').doc(uid);
      await docRef.update(updates);

      final snap = await docRef.get();
      if (!snap.exists) return const Failure(ProfileFailed.notFound);

      return Success(AppUser.fromMap(snap.data()!));
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseError(e));
    } catch (e) {
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        return const Failure(ProfileFailed.offline);
      }
      return const Failure(ProfileFailed.unknown);
    }
  }

  /// Busca os dados do usuário do Firestore
  @override
  Future<Result<ProfileFailed, AppUser>> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) return const Failure(ProfileFailed.notFound);

      final user = AppUser.fromMap(doc.data()!);
     
     return Success(user);
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseError(e));
    } catch (e) {
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        return const Failure(ProfileFailed.offline);
      }
      return const Failure(ProfileFailed.unknown);
    }
  }

  /// Atualiza o perfil completo incluindo upload de imagens
  @override
  Future<Result<ProfileFailed, AppUser>> updateUserProfileWithImages({
    required AppUser currentUser,
    String? displayName,
    String? bio,
    File? profileImage,
    File? coverImage,
  }) async {
    try {
      String? profileImageUrl = currentUser.photoUrl;
      String? coverImageUrl = currentUser.coverImageUrl;

      // Upload da foto de perfil se fornecida
      if (profileImage != null) {
        profileImageUrl = await uploadImage(
          profileImage,
          'profiles/${currentUser.uid}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      // Upload da imagem de capa se fornecida
      if (coverImage != null) {
        coverImageUrl = await uploadImage(
          coverImage,
          'profiles/${currentUser.uid}/cover_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      // Atualiza no Firestore
      await updateUserProfile(
        currentUser.uid,
        displayName: displayName,
        bio: bio,
        photoUrl: profileImageUrl,
        coverImageUrl: coverImageUrl,
      );

      // Retorna o usuário atualizado
     final updatedUser = currentUser.copyWith(
        displayName: displayName,
        bio: bio,
        photoUrl: profileImageUrl,
        coverImageUrl: coverImageUrl,
      );
      
      return Success(updatedUser);
    } on FirebaseException catch (e) {
      return Failure(_mapFirebaseError(e));
    } catch (e) {
      if (e.toString().contains('network') || e.toString().contains('connection')) {
        return const Failure(ProfileFailed.offline);
      }
      return const Failure(ProfileFailed.unknown);
    }
  }

  /// Deleta uma imagem do Firebase Storage
  @override
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (_) {
      // Ignora erro se a imagem não existir
    }
  }

  ProfileFailed _mapFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'unauthenticated':
      case 'permission-denied':
        return ProfileFailed.notAuthenticated;
      case 'unavailable':
      case 'network-request-failed':
        return ProfileFailed.offline;
      default:
        return ProfileFailed.unknown;
    }
  }
}

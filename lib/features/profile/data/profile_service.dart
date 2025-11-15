import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diario_colaborativo/features/auth/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload de imagem para o Firebase Storage
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
  Future<void> updateUserProfile(
    String uid, {
    String? displayName,
    String? bio,
    String? photoUrl,
    String? coverImageUrl,
  }) async {
    try {
      print('updateUserProfile: $uid');
      print('displayName: $displayName');
      print('bio: $bio');
      print('photoUrl: $photoUrl');
      print('coverImageUrl: $coverImageUrl');
      final Map<String, dynamic> updates = {};

      if (displayName != null) updates['displayName'] = displayName;
      if (bio != null) updates['bio'] = bio;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (coverImageUrl != null) updates['coverImageUrl'] = coverImageUrl;

      if (updates.isEmpty) return;

      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      throw Exception('Erro ao atualizar perfil: $e');
    }
  }

  /// Busca os dados do usuário do Firestore
  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) return null;

      return AppUser.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Erro ao buscar perfil: $e');
    }
  }

  /// Atualiza o perfil completo incluindo upload de imagens
  Future<AppUser> updateProfileWithImages({
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
      return currentUser.copyWith(
        displayName: displayName,
        bio: bio,
        photoUrl: profileImageUrl,
        coverImageUrl: coverImageUrl,
      );
    } catch (e) {
      throw Exception('Erro ao atualizar perfil com imagens: $e');
    }
  }

  /// Deleta uma imagem do Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Ignora erro se a imagem não existir
      print('Erro ao deletar imagem: $e');
    }
  }
}

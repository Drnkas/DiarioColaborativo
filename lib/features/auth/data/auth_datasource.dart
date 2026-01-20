import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diario_colaborativo/features/auth/data/results/login_failed.dart';
import 'package:diario_colaborativo/features/auth/data/results/sign_up_failed.dart';
import 'package:diario_colaborativo/features/auth/data/results/validate_token_failed.dart';
import 'package:diario_colaborativo/features/auth/models/sign_up_dto.dart';
import 'package:diario_colaborativo/features/auth/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/helpers/result.dart';

abstract class AuthDatasource {
  Future<Result<LoginFailed, AppUser>> login({required String email, required String password});
  Future<Result<ValidateTokenFailed, AppUser>> validateToken(String token);
  Future<Result<SignUpFailed, AppUser>> signUp(SignUpDto signUpDto);
  // Future<Result<LoginFailed, AppUser>> signInWithGoogle();
  Future<Result<LoginFailed, AppUser>> signInWithApple();
  Future<void> signOut();
}

class RemoteAuthDatasource implements AuthDatasource {
  RemoteAuthDatasource(this._auth, this._googleSignIn);

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Cria ou atualiza o documento do usuário no Firestore
  Future<void> _createOrUpdateUserInFirestore(AppUser user) async {
    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      final doc = await userRef.get();

      if (!doc.exists) {
        // Se o documento não existe, cria um novo
        await userRef.set(user.toFirestore());
        print('✅ Documento do usuário criado no Firestore: ${user.uid}');
      } else {
        // Se já existe, atualiza apenas alguns campos
        await userRef.set({
          'name': user.name,
          'email': user.email,
          'photoUrl': user.photoUrl,
        }, SetOptions(merge: true));
        print('✅ Documento do usuário atualizado no Firestore: ${user.uid}');
      }
    } catch (e) {
      print('❌ Erro ao criar/atualizar usuário no Firestore: $e');
      // Não lança exceção para não quebrar o fluxo de login
    }
  }

  @override
  Future<Result<LoginFailed, AppUser>> login({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (credential.user != null) {
        final user = AppUser.fromFirebaseUser(credential.user!);

        // Garante que o documento existe no Firestore
        await _createOrUpdateUserInFirestore(user);

        return Success(user);
      } else {
        return const Failure(LoginFailed.invalidCredentials);
      }
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseAuthExceptionToLoginFailed(e);
    } catch (e) {
      if (e.toString().contains('network') || e.toString().contains('connection')) {
        return const Failure(LoginFailed.offline);
      }
      return const Failure(LoginFailed.unknownError);
    }
  }

  @override
  Future<Result<SignUpFailed, AppUser>> signUp(SignUpDto signUpDto) async {
    try {
      final credential =
          await _auth.createUserWithEmailAndPassword(email: signUpDto.email, password: signUpDto.password);

      if (credential.user != null) {
        await credential.user!.updateDisplayName(signUpDto.fullName);

        final user = AppUser.fromFirebaseUser(credential.user!);

        // Cria o documento do usuário no Firestore
        await _createOrUpdateUserInFirestore(user);

        return Success(user);
      } else {
        return const Failure(SignUpFailed.unknownError);
      }
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseAuthExceptionToSignUpFailed(e);
    } catch (e) {
      return const Failure(SignUpFailed.unknownError);
    }
  }

  @override
  Future<Result<ValidateTokenFailed, AppUser>> validateToken(String token) async {
    try {
      final currentUser = _auth.currentUser;

      if (currentUser != null) {
        await currentUser.reload();

        // Tenta buscar do Firestore primeiro para ter dados atualizados
        try {
          final doc = await _firestore.collection('users').doc(currentUser.uid).get();
          if (doc.exists) {
            final user = AppUser.fromMap(doc.data()!);
            return Success(user);
          }
        } catch (e) {
          print('⚠️ Erro ao buscar usuário do Firestore: $e');
        }

        // Se não encontrar no Firestore, usa os dados do Firebase Auth
        final user = AppUser.fromFirebaseUser(currentUser);

        // Garante que o documento existe no Firestore
        await _createOrUpdateUserInFirestore(user);

        return Success(user);
      } else {
        return const Failure(ValidateTokenFailed.invalidToken);
      }
    } catch (e) {
      return const Failure(ValidateTokenFailed.unknownError);
    }
  }

  // @override
  // Future<Result<LoginFailed, AppUser>> signInWithGoogle() async {
  //   try {
  //     final googleUser = await _googleSignIn.signOut();
  //     if (googleUser == null) {
  //       return const Failure(LoginFailed.invalidCredentials);
  //     }

  //     final googleAuth = await googleUser.authentication;
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     final userCredential = await _auth.signInWithCredential(credential);

  //     if (userCredential.user != null) {
  //       final user = AppUser.fromFirebaseUser(userCredential.user!);

  //       // Cria ou atualiza o documento do usuário no Firestore
  //       await _createOrUpdateUserInFirestore(user);

  //       return Success(user);
  //     } else {
  //       return const Failure(LoginFailed.invalidCredentials);
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     return _mapFirebaseAuthExceptionToLoginFailed(e);
  //   } catch (e) {
  //     return const Failure(LoginFailed.unknownError);
  //   }
  // }

  @override
  Future<Result<LoginFailed, AppUser>> signInWithApple() async {
    try {
      final appleProvider = AppleAuthProvider();
      final userCredential = await _auth.signInWithProvider(appleProvider);

      if (userCredential.user != null) {
        final user = AppUser.fromFirebaseUser(userCredential.user!);

        // Cria ou atualiza o documento do usuário no Firestore
        await _createOrUpdateUserInFirestore(user);

        return Success(user);
      } else {
        return const Failure(LoginFailed.invalidCredentials);
      }
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseAuthExceptionToLoginFailed(e);
    } catch (e) {
      return const Failure(LoginFailed.unknownError);
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Result<LoginFailed, AppUser> _mapFirebaseAuthExceptionToLoginFailed(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const Failure(LoginFailed.invalidCredentials);
      case 'network-request-failed':
      case 'too-many-requests':
        return const Failure(LoginFailed.offline);
      default:
        return const Failure(LoginFailed.unknownError);
    }
  }

  Result<SignUpFailed, AppUser> _mapFirebaseAuthExceptionToSignUpFailed(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return const Failure(SignUpFailed.emailAlreadyExists);
      case 'weak-password':
        return const Failure(SignUpFailed.weakPassword);
      case 'invalid-email':
        return const Failure(SignUpFailed.invalidEmail);
      case 'network-request-failed':
        return const Failure(SignUpFailed.networkError);
      default:
        return const Failure(SignUpFailed.unknownError);
    }
  }
}

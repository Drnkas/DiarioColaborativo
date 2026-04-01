import 'package:equatable/equatable.dart';
import 'package:diario_colaborativo/features/auth/models/user.dart';

enum ProfilePageStatus {
  initial,
  loading,
  success,  
  updated,  
  error,
}

class ProfilePageState extends Equatable {
  final ProfilePageStatus status;
  final AppUser? user;
  final String? errorMessage;

  const ProfilePageState({
    this.status = ProfilePageStatus.initial,
    this.user,
    this.errorMessage,
  });

  ProfilePageState copyWith({
    ProfilePageStatus? status,
    AppUser? user,
    String? errorMessage,
  }) {
    return ProfilePageState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}


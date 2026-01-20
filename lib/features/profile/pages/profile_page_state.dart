import 'package:equatable/equatable.dart';
import 'package:diario_colaborativo/features/auth/models/user.dart';

enum ProfilePageStatus {
  initial,
  loading,
  success,
  error,
}

class ProfilePageState extends Equatable {
  final ProfilePageStatus status;
  final AppUser? user;
  final String? errorMessage;
  final int selectedTab; // 0 = Posts, 1 = Salvos

  const ProfilePageState({
    this.status = ProfilePageStatus.initial,
    this.user,
    this.errorMessage,
    this.selectedTab = 0,
  });

  ProfilePageState copyWith({
    ProfilePageStatus? status,
    AppUser? user,
    String? errorMessage,
    int? selectedTab,
  }) {
    return ProfilePageState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, selectedTab];
}


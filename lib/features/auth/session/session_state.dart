part of 'session_cubit.dart';

class SessionState extends Equatable {
  const SessionState({this.loggedUser});

  final AppUser? loggedUser;

  @override
  List<Object?> get props => [loggedUser];

  SessionState copyWith({
    AppUser? loggedUser,
  }) {
    return SessionState(
      loggedUser: loggedUser ?? this.loggedUser,
    );
  }
}


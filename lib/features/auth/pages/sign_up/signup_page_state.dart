part of 'signup_page_cubit.dart';

class SignUpState extends Equatable {
 const SignUpState({
  required this.fullName,
  required this.email,
  required this.password,
  required this.isLoading,
 });

 const SignUpState.empty()
     : fullName = const FullName.pure(),
      email = const Email.pure(),
      password = const Password.pure(),
      isLoading = false;

 final FullName fullName;
 final Email email;
 final Password password;

 final bool isLoading;

 bool get isValid =>
     Formz.validate([
      fullName,
      email,
      password,
     ]);

 @override
 List<Object> get props => [fullName, email, password, isLoading];

 SignUpState copyWith({
  FullName? fullName,
  Email? email,
  Password? password,
  bool? isLoading,
 }) {
  return SignUpState(
   fullName: fullName ?? this.fullName,
   email: email ?? this.email,
   password: password ?? this.password,
   isLoading: isLoading ?? this.isLoading,
  );
 }
}


import 'package:equatable/equatable.dart';

class AuthToken extends Equatable {
  const AuthToken({
    required this.access,
    required this.refresh,
  });

  final String access;
  final String refresh;

  @override
  List<Object> get props => [access, refresh];
}

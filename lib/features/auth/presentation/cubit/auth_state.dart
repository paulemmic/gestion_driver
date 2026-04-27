import 'package:flutter/material.dart';
import 'package:gestion_driver/features/auth/domain/entites/app_user.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class Authenticated extends AuthState {
  final AppUser user;
  Authenticated(this.user);
}

final class Unauthenticated extends AuthState {}

final class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

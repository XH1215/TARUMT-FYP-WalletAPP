/*
A Collaborative Creation:
CHIN KAH FUI
CHIN XUAN HONG
OLIVIA HUANG SI HAN
LIM CHU QING
*/

import 'auth_user.dart';

abstract class AuthProvider {
  Future<AuthUser> login({
    required String email,
    required String password,
  });

  Future<AuthUser> register({
    required String email,
    required String password,
  });

  //Future<void> sendEmailVerification();
  Future<void> logout();
  AuthUser? get currentUser;
  Future<void> initialize();
}

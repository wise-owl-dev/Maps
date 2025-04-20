// lib/features/auth/domain/repositories/auth_repository.dart
import '../entities/Usuario.dart';

abstract class AuthRepository {
  Future<bool> isAuthenticated();
  Future<Usuario> login(String email, String password);
  Future<Usuario> register({
    required String email,
    required String password,
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String telefono,
  });
  Future<void> logout();
  Future<Usuario?> getCurrentUser();
  Future<void> updatePassword(String email, String newPassword);
}
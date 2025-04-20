// lib/features/auth/domain/usecases/update_password_usecase.dart
import '../repositories/auth_repository.dart';

class UpdatePasswordUseCase {
  final AuthRepository repository;

  UpdatePasswordUseCase(this.repository);

  Future<void> execute(String email, String newPassword) async {
    return await repository.updatePassword(email, newPassword);
  }
}
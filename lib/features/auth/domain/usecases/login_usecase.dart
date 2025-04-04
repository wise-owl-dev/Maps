
import '../entities/Usuario.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Usuario> execute(String email, String password) async {
    // Aquí podríamos agregar lógica adicional antes de llamar al repositorio
    // Por ejemplo, validaciones, logging, etc.
    return await repository.login(email, password);
  }
}
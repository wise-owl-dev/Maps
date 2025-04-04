
import 'package:maps_app/features/auth/domain/entities/Usuario.dart';

import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Usuario?> execute() async {
    return await repository.getCurrentUser();
  }
}


import 'package:maps_app/features/auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/Usuario.dart';
import '../datasources/auth_datasource_impl.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSourceImpl _dataSource;
  
  AuthRepositoryImpl(this._dataSource);
  
  @override
  Future<bool> isAuthenticated() async {
    return await _dataSource.isAuthenticated();
  }
  
  @override
  Future<Usuario> login(String email, String password) async {
    await _dataSource.login(email, password);
    final userData = await _dataSource.getUserInfo(email);
    
    return _mapUserDataToEntity(userData);
  }
  
  @override
  Future<Usuario> register({
    required String email,
    required String password,
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String telefono,
  }) async {
    await _dataSource.register(
      email: email,
      password: password,
      nombre: nombre,
      apellidoPaterno: apellidoPaterno,
      apellidoMaterno: apellidoMaterno,
      telefono: telefono,
    );
    
    final userData = await _dataSource.getUserInfo(email);
    return _mapUserDataToEntity(userData);
  }
  
  @override
  Future<void> logout() async {
    await _dataSource.logout();
  }
  
  @override
  Future<Usuario?> getCurrentUser() async {
    final userEmail = await _dataSource.getCurrentUserEmail();
    
    if (userEmail == null) return null;
    
    final userData = await _dataSource.getUserInfo(userEmail);
    return _mapUserDataToEntity(userData);
  }
  
  @override
  Future<void> updatePassword(String email, String newPassword) async {
    await _dataSource.updatePassword(email, newPassword);
  }
  
  // Método auxiliar para mapear los datos de usuario a una entidad
  Usuario _mapUserDataToEntity(Map<String, dynamic> userData) {
    return Usuario.fromMap(userData);
  }
}
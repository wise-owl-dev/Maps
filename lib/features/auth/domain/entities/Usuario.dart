// lib/features/auth/domain/entities/usuario.dart
class Usuario {
  final int id;
  final String email;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String telefono;
  final String rol;
  
  Usuario({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.telefono,
    required this.rol,
  });
}

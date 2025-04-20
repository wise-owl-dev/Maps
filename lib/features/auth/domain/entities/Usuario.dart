// lib/features/auth/domain/entities/usuario.dart
class Usuario {
  final int id;
  final String email;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String telefono;
  final String rol;
  final bool requiresPasswordReset;
  final DateTime? lastLogin;
  final bool isLoggedIn;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Usuario({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.telefono,
    required this.rol,
    this.requiresPasswordReset = false,
    this.lastLogin,
    this.isLoggedIn = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Constructor de copia con modificaciones
  Usuario copyWith({
    int? id,
    String? email,
    String? nombre,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? telefono,
    String? rol,
    bool? requiresPasswordReset,
    DateTime? lastLogin,
    bool? isLoggedIn,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Usuario(
      id: id ?? this.id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      apellidoPaterno: apellidoPaterno ?? this.apellidoPaterno,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
      requiresPasswordReset: requiresPasswordReset ?? this.requiresPasswordReset,
      lastLogin: lastLogin ?? this.lastLogin,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  // Método útil para convertir a Map para operaciones de base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'correo': email,
      'nombre': nombre,
      'apellido_paterno': apellidoPaterno,
      'apellido_materno': apellidoMaterno,
      'telefono': telefono,
      'tipo_usuario': rol,
      'requires_password_reset': requiresPasswordReset,
      'last_login': lastLogin?.toIso8601String(),
      'is_logged_in': isLoggedIn,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Método para crear una entidad a partir de un Map (de la base de datos)
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      email: map['correo'],
      nombre: map['nombre'],
      apellidoPaterno: map['apellido_paterno'],
      apellidoMaterno: map['apellido_materno'],
      telefono: map['telefono'],
      rol: map['role'] ?? map['tipo_usuario'],
      requiresPasswordReset: map['requires_password_reset'] ?? false,
      lastLogin: map['last_login'] != null 
                 ? DateTime.parse(map['last_login']) 
                 : null,
      isLoggedIn: map['is_logged_in'] ?? false,
      createdAt: map['created_at'] != null 
                 ? DateTime.parse(map['created_at']) 
                 : DateTime.now(),
      updatedAt: map['updated_at'] != null 
                 ? DateTime.parse(map['updated_at']) 
                 : DateTime.now(),
    );
  }
}
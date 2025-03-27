class AuthService {
  // Usuarios mock para simular autenticación con roles
  static final Map<String, Map<String, dynamic>> _mockUsers = {
    'user@example.com': {
      'password': 'user123',
      'role': 'user',
      'name': 'Juan Pérez',
      'email': 'user@example.com'
    },
    'operador@transporte.com': {
      'password': 'operador123',
      'role': 'operador',
      'name': 'María Gómez',
      'email': 'operador@transporte.com'
    },
    'admin@transporte.com': {
      'password': 'admin123',
      'role': 'admin',
      'name': 'Carlos Rodríguez',
      'email': 'admin@transporte.com'
    }
  };

  Future<Map<String, dynamic>?> signInWithEmailAndPassword(String email, String password) async {
    // Simular tiempo de red
    await Future.delayed(const Duration(seconds: 1));
    
    // Validación de credenciales
    if (_mockUsers.containsKey(email) && _mockUsers[email]!['password'] == password) {
      return _mockUsers[email];
    }
    return null;
  }

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    // Simular inicio de sesión con Google
    await Future.delayed(const Duration(seconds: 2));
    // En una implementación real, obtendrías el rol del usuario
    return null;
  }
}
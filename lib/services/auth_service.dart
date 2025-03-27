class AuthService {
  // Usuarios mock para simular autenticación
  static final Map<String, String> _mockUsers = {
    'user@example.com': 'password123',
    'admin@example.com': 'admin123'
  };

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    // Simular tiempo de red
    await Future.delayed(const Duration(seconds: 1));
    
    // Validación de credenciales
    return _mockUsers.containsKey(email) && _mockUsers[email] == password;
  }

  Future<bool> signInWithGoogle() async {
    // Simular inicio de sesión con Google
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  Future<bool> signUp(String email, String password) async {
    // Simular registro de usuario
    await Future.delayed(const Duration(seconds: 1));
    _mockUsers[email] = password;
    return true;
  }
}
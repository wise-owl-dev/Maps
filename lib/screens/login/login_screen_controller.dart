import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginScreenController {
  final AuthService _authService = AuthService();

  Future<void> handleLogin(
    BuildContext context, 
    String email, 
    String password
  ) async {
    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog(context, 'Por favor, complete todos los campos');
      return;
    }

    try {
      final userInfo = await _authService.signInWithEmailAndPassword(email, password);
      if (userInfo != null) {
        // Navegar según el rol del usuario
        switch (userInfo['role']) {
          case 'admin':
            Navigator.of(context).pushReplacementNamed('/admin-menu');
            break;
          case 'operador':
            Navigator.of(context).pushReplacementNamed('/operador-menu');
            break;
          case 'user':
            Navigator.of(context).pushReplacementNamed('/user-menu');
            break;
          default:
            Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        _showErrorDialog(context, 'Credenciales inválidas');
      }
    } catch (e) {
      _showErrorDialog(context, 'Error de inicio de sesión');
    }
  }

  Future<void> handleGoogleSignIn(BuildContext context) async {
    try {
      final userInfo = await _authService.signInWithGoogle();
      if (userInfo != null) {
        // Navegar según el rol del usuario (implementación de ejemplo)
        switch (userInfo['role']) {
          case 'admin':
            Navigator.of(context).pushReplacementNamed('/admin-menu');
            break;
          case 'operador':
            Navigator.of(context).pushReplacementNamed('/operador-menu');
            break;
          case 'user':
            Navigator.of(context).pushReplacementNamed('/user-menu');
            break;
          default:
            Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        _showErrorDialog(context, 'Error en inicio de sesión con Google');
      }
    } catch (e) {
      _showErrorDialog(context, 'Error de conexión');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), 
            child: const Text('Aceptar')
          )
        ],
      ),
    );
  }
}
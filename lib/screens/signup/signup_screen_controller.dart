import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class SignUpScreenController {
  final AuthService _authService = AuthService();

  Future<void> handleSignUp(
    BuildContext context, 
    String nombre,
    String apellidoPaterno,
    String apellidoMaterno,
    String email,
    String password,
    String telefono
  ) async {
    try {
      // Aquí agregarías la lógica de registro
      // Por ahora, solo mostraremos un diálogo de éxito
      _showSuccessDialog(context);
    } catch (e) {
      _showErrorDialog(context, 'Error durante el registro');
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registro Exitoso'),
        content: const Text('Su cuenta ha sido creada correctamente.'),
        actions: [
          TextButton(
            onPressed: () {
              // Cerrar diálogo y navegar a login
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacementNamed('/login');
            }, 
            child: const Text('Aceptar')
          )
        ],
      ),
    );
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
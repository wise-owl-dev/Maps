// lib/core/error/error_handler.dart
import 'package:flutter/material.dart';
import 'package:maps_app/features/auth/infrastructure/datasources/auth_datasource_impl.dart';

/// Clase para manejar errores de forma centralizada
class ErrorHandler {
  /// Convierte excepciones técnicas en mensajes amigables para el usuario
  static String getUserFriendlyMessage(dynamic error) {
    // Verificar si es un error de autenticación con tipo específico
    if (error is AuthException) {
      switch (error.errorType) {
        case AuthErrorType.userNotFound:
          return 'No existe una cuenta con ese correo electrónico.';
        case AuthErrorType.incorrectPassword:
          return 'La contraseña ingresada es incorrecta.';
        case AuthErrorType.emailAlreadyExists:
          return 'Este correo electrónico ya está registrado. Intenta iniciar sesión o usa otro correo.';
        case AuthErrorType.networkError:
          return 'Problemas de conexión. Verifica tu conexión a internet e intenta nuevamente.';
        case AuthErrorType.serverError:
          return 'Error en el servidor. Intenta nuevamente más tarde.';
        case AuthErrorType.unknown:
        default:
          return error.message;
      }
    }
    
    // Para otros tipos de errores, procesar el mensaje
    final String errorMessage = error.toString();
    
    // Errores de autenticación
    if (errorMessage.contains('Error en el inicio de sesión')) {
      return 'No se pudo iniciar sesión. Verifica tus credenciales e intenta nuevamente.';
    }
    
    if (errorMessage.contains('Credenciales inválidas')) {
      return 'Correo electrónico o contraseña incorrecta.';
    }
    
    if (errorMessage.contains('contraseña incorrecta')) {
      return 'La contraseña ingresada es incorrecta.';
    }
    
    if (errorMessage.contains('Usuario no encontrado')) {
      return 'No se encontró una cuenta con ese correo electrónico.';
    }
    
    // Errores de registro
    if (errorMessage.contains('Error en el registro')) {
      return 'No se pudo completar el registro. Verifica los datos e intenta nuevamente.';
    }
    
    if (errorMessage.contains('El correo electrónico ya está registrado')) {
      return 'Este correo electrónico ya está en uso. Intenta con otro o inicia sesión.';
    }
    
    // Errores de conexión
    if (errorMessage.contains('network') || 
        errorMessage.contains('SocketException') || 
        errorMessage.contains('Connection')) {
      return 'Problemas de conexión. Verifica tu conexión a internet e intenta nuevamente.';
    }
    
    // Errores de base de datos
    if (errorMessage.contains('database') || 
        errorMessage.contains('supabase')) {
      return 'Error en el servidor. Intenta nuevamente más tarde.';
    }
    
    // Errores de cierre de sesión
    if (errorMessage.contains('Error al cerrar sesión')) {
      return 'No se pudo cerrar sesión correctamente. Intenta nuevamente.';
    }
    
    // Error genérico para cualquier otro caso
    return 'Se ha producido un error inesperado. Intenta nuevamente.';
  }
  
  /// Muestra un snackbar con un mensaje de error amigable
  static void showErrorSnackBar(BuildContext context, dynamic error) {
    final String friendlyMessage = getUserFriendlyMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(friendlyMessage)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  /// Muestra un diálogo de error
  static Future<void> showErrorDialog(BuildContext context, dynamic error) async {
    final String friendlyMessage = getUserFriendlyMessage(error);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text('Error'),
          ],
        ),
        content: Text(friendlyMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
  
  /// Muestra un mensaje de error específico para inicio de sesión/registro
  static void showAuthErrorSnackBar(BuildContext context, dynamic error) {
    final String friendlyMessage = getUserFriendlyMessage(error);
    
    // Determinar el ícono adecuado según el tipo de error
    IconData iconData = Icons.error_outline;
    
    if (error is AuthException) {
      switch (error.errorType) {
        case AuthErrorType.userNotFound:
          iconData = Icons.person_off;
          break;
        case AuthErrorType.incorrectPassword:
          iconData = Icons.lock;
          break;
        case AuthErrorType.emailAlreadyExists:
          iconData = Icons.email;
          break;
        default:
          iconData = Icons.error_outline;
      }
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(iconData, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(friendlyMessage)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
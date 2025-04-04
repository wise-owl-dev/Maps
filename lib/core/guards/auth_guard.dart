// lib/core/guards/auth_guard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maps_app/features/auth/presentation/providers/auth_provider.dart';

/// Widget encargado de proteger rutas según el estado de autenticación y rol del usuario
class AuthGuard extends ConsumerWidget {
  final Widget child;
  final List<String> allowedRoles;
  
  const AuthGuard({
    Key? key,
    required this.child,
    this.allowedRoles = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    // Si no está autenticado, redirigir al login
    if (!authState.isAuthenticated) {
      // Usar WidgetsBinding para evitar problemas de navegación durante el build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        GoRouter.of(context).go('/login');
      });
      
      // Mostrar un indicador de carga mientras se redirecciona
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Si no se especificaron roles permitidos, cualquier usuario autenticado puede acceder
    if (allowedRoles.isEmpty) {
      return child;
    }
    
    // Verificar si el usuario tiene un rol permitido
    final userRole = authState.userRole ?? 'usuario';
    
    if (!allowedRoles.contains(userRole)) {
      // Redirigir según el rol
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Redirigir a la pantalla correspondiente según el rol
        switch (userRole) {
          case 'admin':
            GoRouter.of(context).go('/admin-menu');
            break;
          case 'operador':
            GoRouter.of(context).go('/operador-menu');
            break;
          default:
            GoRouter.of(context).go('/user-menu');
            break;
        }
      });
      
      // Mostrar un indicador de carga mientras se redirecciona
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Si está autenticado y tiene los permisos adecuados, mostrar la pantalla
    return child;
  }
}

/*
/// Ejemplo de uso: Para proteger cualquier pantalla
/// 
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return AuthGuard(
///     allowedRoles: ['administrador'],
///     child: AdminScreen(),
///   );
/// }
/// ```
*/
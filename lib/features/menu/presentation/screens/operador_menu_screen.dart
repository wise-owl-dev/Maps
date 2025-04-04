// lib/features/menu/presentation/screens/operador_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maps_app/core/guards/auth_guard.dart';
import 'package:maps_app/features/auth/presentation/providers/auth_provider.dart';

class OperadorMenuScreen extends ConsumerWidget {
  const OperadorMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Proteger esta pantalla solo para operadores
    return AuthGuard(
      allowedRoles: ['operador'],
      child: _OperadorMenuContent(),
    );
  }
}

class _OperadorMenuContent extends ConsumerWidget {
  void _handleMenuOption(BuildContext context, String option) {
    print('Navegando a: $option');
    // Implementar navegación
  }

  void _handleLogout(BuildContext context, WidgetRef ref) async {
    try {
      // Llama al método logout del provider
      await ref.read(authProvider.notifier).logout();
      
      // Navegar usando go_router después de cerrar sesión
      if (context.mounted) {
        context.go('/login');
      }
      
      print('Cierre de sesión exitoso');
    } catch (e) {
      print('Error al cerrar sesión: $e');
      // Mostrar un mensaje de error si es necesario
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener información del usuario autenticado
    final authState = ref.watch(authProvider);
    final userName = authState.user?.nombre ?? 'Operador';
    final userEmail = authState.user?.email ?? 'operador@transporte.com';
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Encabezado de usuario operador
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.directions_bus,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(),

            // Opciones del menú de operador
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  _MenuOption(
                    icon: Icons.directions_bus_outlined,
                    title: 'Ver Recorrido',
                    onTap: () => _handleMenuOption(context, 'Ver Recorrido'),
                  ),
                  _MenuOption(
                    icon: Icons.map_outlined,
                    title: 'Ver Horarios',
                    onTap: () => _handleMenuOption(context, 'Ver Horarios'),
                  ),
                  
                ],
              ),
            ),

            // Mover cerrar sesión al final
            const Divider(),
            _MenuOption(
              icon: Icons.logout,
              title: 'Cerrar sesión',
              textColor: Colors.blue,
              iconColor: Colors.blue,
              onTap: () => _handleLogout(context, ref),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Reutilizamos la misma clase _MenuOption del menú de admin
class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? badge;
  final Color textColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _MenuOption({
    required this.icon,
    required this.title,
    this.badge,
    this.textColor = const Color(0xFF1F2937),
    this.iconColor = const Color(0xFF6B7280),
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge!,
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
      onTap: onTap,
    );
  }
}
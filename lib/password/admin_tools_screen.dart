import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maps_app/password/password_migration_util.dart';


import '../features/auth/presentation/providers/auth_provider.dart' show supabaseClientProvider;
// Importa la utilidad de migración

class AdminToolsScreen extends ConsumerWidget {
  const AdminToolsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabaseClient = ref.watch(supabaseClientProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Herramientas de Administrador'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  final migrationUtil = PasswordMigrationUtil(supabaseClient);
                  
                  // Mostrar diálogo de carga
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Migrando contraseñas...')
                        ],
                      ),
                    ),
                  );
                  
                  // Ejecutar migración
                  await migrationUtil.migrateAdminOperatorPasswords();
                  
                  // Cerrar diálogo de carga
                  Navigator.of(context).pop();
                  
                  // Mostrar mensaje de éxito
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Migración de contraseñas completada con éxito'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  // Cerrar diálogo de carga si hay error
                  Navigator.of(context).pop();
                  
                  // Mostrar error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Migrar Contraseñas de Admin/Operador'),
            ),
          ],
        ),
      ),
    );
  }
}
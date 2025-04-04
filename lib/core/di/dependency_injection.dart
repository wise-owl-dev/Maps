// lib/core/di/dependency_injection.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maps_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:maps_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:maps_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:maps_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:maps_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:maps_app/features/auth/domain/usecases/is_authenticated_usecase.dart';
import 'package:maps_app/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:maps_app/features/auth/infrastructure/datasources/auth_datasource_impl.dart';
import 'package:maps_app/services/key_value_storage_service.dart';

/// Configuración de inyección de dependencias usando Riverpod

// Providers de infraestructura
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final keyValueStorageProvider = Provider<KeyValueStorageService>((ref) {
  return KeyValueStorageService();
});

final authDataSourceProvider = Provider<AuthDataSourceImpl>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AuthDataSourceImpl(supabaseClient);
});

// Providers de repositorios
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

// Providers de casos de uso
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final isAuthenticatedUseCaseProvider = Provider<IsAuthenticatedUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return IsAuthenticatedUseCase(repository);
});
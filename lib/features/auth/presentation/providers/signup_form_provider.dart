// lib/features/auth/presentation/providers/signup_form_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import '../../../shared/shared.dart';
import 'auth_provider.dart';

class SignUpFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final Name name;
  final LastName lastName;
  final LastName maternalLastName;
  final Email email;
  final Password password;
  final Phone phone;
  final String? errorMessage;

  SignUpFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.name = const Name.pure(),
    this.lastName = const LastName.pure(),
    this.maternalLastName = const LastName.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.phone = const Phone.pure(),
    this.errorMessage,
  });

  SignUpFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    Name? name,
    LastName? lastName,
    LastName? maternalLastName,
    Email? email,
    Password? password,
    Phone? phone,
    String? errorMessage,
  }) {
    return SignUpFormState(
      isPosting: isPosting ?? this.isPosting,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      isValid: isValid ?? this.isValid,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      maternalLastName: maternalLastName ?? this.maternalLastName,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SignUpFormNotifier extends StateNotifier<SignUpFormState> {
  final Function({
    required String email,
    required String password,
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String telefono,
  }) registerUserCallback;

  SignUpFormNotifier({
    required this.registerUserCallback,
  }) : super(SignUpFormState());

  onNameChanged(String value) {
    final name = Name.dirty(value);
    state = state.copyWith(
      name: name,
      isValid: _isFormValid(),
    );
  }

  onLastNameChanged(String value) {
    final lastName = LastName.dirty(value);
    state = state.copyWith(
      lastName: lastName,
      isValid: _isFormValid(),
    );
  }

  onMaternalLastNameChanged(String value) {
    final maternalLastName = LastName.dirty(value);
    state = state.copyWith(
      maternalLastName: maternalLastName,
      isValid: _isFormValid(),
    );
  }

  onEmailChange(String value) {
    final email = Email.dirty(value);
    state = state.copyWith(
      email: email,
      isValid: _isFormValid(),
    );
  }

  onPasswordChanged(String value) {
    final password = Password.dirty(value);
    state = state.copyWith(
      password: password,
      isValid: _isFormValid(),
    );
  }

  onPhoneChanged(String value) {
    final phone = Phone.dirty(value);
    state = state.copyWith(
      phone: phone,
      isValid: _isFormValid(),
    );
  }

  bool _isFormValid() {
    return Formz.validate([
      state.name,
      state.lastName, 
      state.maternalLastName,
      state.email,
      state.password,
      state.phone,
    ]);
  }

  onFormSubmit() async {
    _touchEveryField();

    if (!state.isValid) return;

    try {
      state = state.copyWith(
        isPosting: true,
        errorMessage: null,
      );

      await registerUserCallback(
        email: state.email.value,
        password: state.password.value,
        nombre: state.name.value,
        apellidoPaterno: state.lastName.value,
        apellidoMaterno: state.maternalLastName.value,
        telefono: state.phone.value,
      );

      state = state.copyWith(
        isPosting: false,
      );
    } catch (e) {
      state = state.copyWith(
        isPosting: false,
        errorMessage: e.toString(),
      );
    }
  }

  _touchEveryField() {
    final name = Name.dirty(state.name.value);
    final lastName = LastName.dirty(state.lastName.value);
    final maternalLastName = LastName.dirty(state.maternalLastName.value);
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);
    final phone = Phone.dirty(state.phone.value);

    state = state.copyWith(
      isFormPosted: true,
      name: name,
      lastName: lastName,
      maternalLastName: maternalLastName,
      email: email,
      password: password,
      phone: phone,
      isValid: Formz.validate([name, lastName, maternalLastName, email, password, phone]),
    );
  }
}

// Provider
final signUpFormProvider = StateNotifierProvider.autoDispose<SignUpFormNotifier, SignUpFormState>((ref) {
  final registerUserCallback = ref.watch(authProvider.notifier).registerUser;

  return SignUpFormNotifier(
    registerUserCallback: registerUserCallback,
  );
});
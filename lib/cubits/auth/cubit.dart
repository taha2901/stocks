import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:management_stock/core/helper/api_paths.dart';
import 'package:management_stock/core/helper/firestore_services.dart';
import 'package:management_stock/core/services/auth_service.dart';
import 'package:management_stock/cubits/auth/states.dart';


class AuthCubit extends Cubit<AuthState> {
  final AuthServices _authService;
  final firestore = FirestoreServices.instance;

  AuthCubit(this._authService) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());
      final user = await _authService.loginWithEmailAndPassword(email, password);
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Login failed'));
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  /// 🧩 التسجيل + إنشاء المستخدم في قاعدة البيانات
  Future<void> register(String email, String password) async {
    try {
      emit(AuthLoading());
      final user = await _authService.registerWithEmailAndPassword(email, password);
      if (user != null) {
        // ✅ إنشاء بيانات المستخدم في Firestore
        final userData = {
          'id': user.uid,
          'email': email,
          'role': 'user',
          'createdAt': DateTime.now().toIso8601String(),
        };

        await firestore.setData(
          path: ApiPaths.users(user.uid),
          data: userData,
        );

        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Register failed'));
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    await _authService.logOut();
    emit(AuthUnauthenticated());
  }

  void checkAuthState() {
    final user = _authService.currentUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}

import 'package:blog_app/core/constants/constants.dart';
import 'package:blog_app/core/error/server_exception_error.dart';
import 'package:blog_app/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  Session? get currentUserSession;
  Future<UserModel> signUpWithEmailPassword({
    required name,
    required email,
    required password,
  });

  Future<UserModel> signInWithEmailPassword({
    required email,
    required password,
  });

  Future<UserModel?> getCurrentUserData();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  @override
  Session? get currentUserSession => supabaseClient.auth.currentSession;
  AuthRemoteDataSourceImpl(this.supabaseClient);
  @override
  Future<UserModel> signInWithEmailPassword({
    required email,
    required password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        password: password,
        email: email,
      );
      if (response.user == null) {
        throw ServerExceptionError(Constants.userNull);
      }
      return UserModel.fromJson(
        response.user!.toJson(),
      );
    } on AuthException catch (e) {
      throw ServerExceptionError(e.message);
    } catch (e) {
      throw ServerExceptionError(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword({
    required name,
    required email,
    required password,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        password: password,
        email: email,
        data: {
          'name': name,
        },
      );
      if (response.user == null) {
        throw ServerExceptionError(Constants.userNull);
      }
      return UserModel.fromJson(
        response.user!.toJson(),
      );
    } on AuthException catch (e) {
      throw ServerExceptionError(e.message);
    } catch (e) {
      throw ServerExceptionError(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      // write supabase query here to get specific data
      if (currentUserSession != null) {
        final userData = await supabaseClient.from(Constants.profilesTable).select().eq(
              'id',
              currentUserSession!.user.id,
            );

        return UserModel.fromJson(userData.first).copyWith(
          email: currentUserSession!.user.email,
        );
      }
      return null;
    } on AuthException catch (e) {
      throw ServerExceptionError(e.message);
    } catch (e) {
      throw ServerExceptionError(e.toString());
    }
  }
}

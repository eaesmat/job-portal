import 'package:blog_app/core/common/network/connection_checker.dart';
import 'package:blog_app/core/constants/constants.dart';
import 'package:blog_app/core/error/failure.dart';
import 'package:blog_app/core/error/server_exception_error.dart';
import 'package:blog_app/features/auth/data/datasrouces/auth_remote_datasource.dart';
import 'package:blog_app/core/common/entities/user.dart';
import 'package:blog_app/features/auth/data/models/user_model.dart';
import 'package:blog_app/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final ConnectionChecker connectionChecker;
  const AuthRepositoryImpl(this.authRemoteDataSource, this.connectionChecker);
  @override
  Future<Either<Failure, User>> signInWithEmailPassword({
    required email,
    required password,
  }) async {
    return _getUser(
      () async => await authRemoteDataSource.signInWithEmailPassword(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required name,
    required email,
    required password,
  }) async {
    return _getUser(
      () async => await authRemoteDataSource.signUpWithEmailPassword(
        name: name,
        email: email,
        password: password,
      ),
    );
  }

// made this wrapper method to avoid the repetition of tr catch and returning user
// as this is the same so far
  Future<Either<Failure, User>> _getUser(
    Future<User> Function() fn,
  ) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(const Failure(Constants.noInternetConnection));
      }
      final user = await fn();

      return right(user);
    } on ServerExceptionError catch (e) {
      return left(
        Failure(e.serverExceptionErrorMessage),
      );
    }
  }

  @override
  Future<Either<Failure, User>> currentUser() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final session = authRemoteDataSource.currentUserSession;
        if (session == null) {
          return left(
            const Failure(Constants.userNotLoggedIn),
          );
        }
        return right(UserModel(
            id: session.user.id, name: '', email: session.user.email ?? ''));
      }
      final user = await authRemoteDataSource.getCurrentUserData();
      if (user == null) {
        return left(
          const Failure(Constants.userNotLoggedIn),
        );
      }
      return right(user);
    } on ServerExceptionError catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }
}

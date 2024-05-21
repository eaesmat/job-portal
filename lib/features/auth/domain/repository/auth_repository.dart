import 'package:blog_app/core/error/failure.dart';
import 'package:blog_app/core/common/entities/user.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required name,
    required email,
    required password,
  });
  Future<Either<Failure, User>> signInWithEmailPassword({
    required email,
    required password,
  });

  Future<Either<Failure, User>> currentUser();
}

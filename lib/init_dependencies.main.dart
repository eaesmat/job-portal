part of 'init_dependencies.dart';

// Dependencies Injection happens here
// make global instance to used all over the file
final serviceLocator = GetIt.instance;

// this is must be async as long we get connected to remote data source
//
Future<void> initDependencies() async {
  _initAuth();
  _initBlog();
  final supabase = await Supabase.initialize(
    url: AppSecret.supaBaseUrl,
    anonKey: AppSecret.supaBaseAnonKey,
  );

  Hive.defaultDirectory = (await getApplicationDocumentsDirectory()).path;

  // Singleton is used to make only one object useful here
  // data source
  serviceLocator.registerLazySingleton(() => supabase.client);

  serviceLocator.registerLazySingleton(() => Hive.box(name: 'blogs'));

  serviceLocator.registerFactory(() => InternetConnection());

  // core
  serviceLocator.registerLazySingleton(() => AppUserCubit());
  serviceLocator.registerFactory<ConnectionChecker>(
      () => ConnectionCheckerImpl(serviceLocator()));
}

void _initAuth() {
  // registerFactory is used to make more instances as long as app runs that is must
  // mention what class this impl will return if not will make error
  serviceLocator.registerFactory<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      serviceLocator<SupabaseClient>(),
    ),
  );

  // mention what class this impl will return if not will make error
  serviceLocator.registerFactory<AuthRepository>(
    () => AuthRepositoryImpl(
      serviceLocator<AuthRemoteDataSource>(),
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<UserSignUp>(
    () => UserSignUp(
      serviceLocator<AuthRepository>(),
    ),
  );
  serviceLocator.registerFactory<UserLogin>(
    () => UserLogin(
      serviceLocator<AuthRepository>(),
    ),
  );
  serviceLocator.registerFactory<CurrentUser>(
    () => CurrentUser(
      serviceLocator<AuthRepository>(),
    ),
  );

  // As long as we need one state of bloc singleton is used
  serviceLocator.registerLazySingleton(
    () => AuthBloc(
      userSignUp: serviceLocator<UserSignUp>(),
      userLogin: serviceLocator<UserLogin>(),
      currentUser: serviceLocator<CurrentUser>(),
      appUserCubit: serviceLocator<AppUserCubit>(),
    ),
  );
}

void _initBlog() {
  //Data Source
  serviceLocator.registerFactory<BlogRemoteDataSource>(
    () => BlogRemoteDataSourceImpl(serviceLocator()),
  );
  serviceLocator.registerFactory<BlogLocaleDataSource>(
      () => BlogLocaleDataSourceImpl(serviceLocator()));
  // Blog Repository
  serviceLocator.registerFactory<BlogRepository>(
    () => BlogRepositoryImpl(
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
    ),
  );

  // UploadUse Case
  serviceLocator.registerFactory<UploadBlog>(
    () => UploadBlog(serviceLocator()),
  );

  // Fetch Blogs use case
  serviceLocator.registerFactory<GetAllBlogs>(
    () => GetAllBlogs(serviceLocator()),
  );

  // Blog Bloc
  serviceLocator.registerLazySingleton(
    () => BlogBloc(
      uploadBlog: serviceLocator<UploadBlog>(),
      getAllBlogs: serviceLocator<GetAllBlogs>(),
    ),
  );
}

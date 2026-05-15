import 'package:drain_eye/data/repositories_impl/auth_repository_impl.dart';
import 'package:drain_eye/data/repositories_impl/inspection_repository_impl.dart';
import 'package:drain_eye/domain/repositories/auth_repository.dart';
import 'package:drain_eye/domain/repositories/inspection_repository.dart';
import 'package:drain_eye/domain/usecases/check_auth.dart';
import 'package:drain_eye/domain/usecases/get_user_inspections.dart';
import 'package:drain_eye/domain/usecases/login_user.dart';
import 'package:drain_eye/domain/usecases/register_user.dart';
import 'package:drain_eye/domain/usecases/cache_inspection_offline.dart';
import 'package:drain_eye/domain/usecases/run_damage_model.dart';
import 'package:drain_eye/domain/usecases/submit_inspection.dart';
import 'package:drain_eye/domain/usecases/sync_pending_inspections.dart';
import 'package:drain_eye/presentation/widgets/inspection_sync_lifecycle.dart';
import 'package:drain_eye/presentation/blocs/auth/auth_bloc.dart';
import 'package:drain_eye/presentation/blocs/new_inspection/new_inspection_bloc.dart';
import 'package:drain_eye/presentation/blocs/user_inspection/user_inspection_bloc.dart';
import 'package:drain_eye/presentation/screens/auth/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();

  final InspectionRepository inspectionRepository = InspectionRepositoryImpl();
  final AuthRepository authRepository = AuthRepositoryImpl();

  final getUserInspections = GetUserInspections(inspectionRepository);
  final userInspectionBloc = UserInspectionBloc(
    getUserInspections: getUserInspections,
  );
  final syncPendingInspections =
      SyncPendingInspections(inspectionRepository);
  final newInspectionBloc = NewInspectionBloc(
    runDamageModel: RunDamageModel(inspectionRepository),
    submitInspection: SubmitInspection(inspectionRepository),
    cacheInspectionOffline: CacheInspectionOffline(inspectionRepository),
    syncPendingInspections: syncPendingInspections,
    inspectionRepository: inspectionRepository,
  );

  final loginUser = LoginUser(authRepository);
  final registerUser = RegisterUser(authRepository);
  final checkAuth = CheckAuth(authRepository);
  final authBloc = AuthBloc(
    loginUser: loginUser,
    registerUser: registerUser,
    checkAuth: checkAuth,
    authRepository: authRepository,
  );

  runApp(MyApp(
    userInspectionBloc: userInspectionBloc,
    newInspectionBloc: newInspectionBloc,
    authBloc: authBloc,
    syncPendingInspections: syncPendingInspections,
  ));
}

Future<void> _initializeFirebase() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

// корневой виджет — стартовый экран: LoginScreen (UC-1)
class MyApp extends StatelessWidget {
  final UserInspectionBloc userInspectionBloc;
  final NewInspectionBloc newInspectionBloc;
  final AuthBloc authBloc;
  final SyncPendingInspections syncPendingInspections;

  const MyApp({
    super.key,
    required this.userInspectionBloc,
    required this.newInspectionBloc,
    required this.authBloc,
    required this.syncPendingInspections,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: userInspectionBloc),
        BlocProvider.value(value: newInspectionBloc),
        BlocProvider.value(value: authBloc),
      ],
      child: InspectionSyncLifecycle(
        syncPendingInspections: syncPendingInspections,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const LoginScreen(),
        ),
      ),
    );
  }
}

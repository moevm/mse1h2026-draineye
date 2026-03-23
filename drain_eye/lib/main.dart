import 'package:drain_eye/data/repositories_impl/inspection_repository_impl.dart';
import 'package:drain_eye/domain/repositories/inspection_repository.dart';
import 'package:drain_eye/domain/usecases/get_user_inspections.dart';
import 'package:drain_eye/domain/usecases/run_damage_model.dart';
import 'package:drain_eye/domain/usecases/submit_inspection.dart';
import 'package:drain_eye/presentation/blocs/new_inspection/new_inspection_bloc.dart';
import 'package:drain_eye/presentation/blocs/user_inspection/user_inspection_bloc.dart';
import 'package:drain_eye/presentation/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  final InspectionRepository repository = InspectionRepositoryImpl();
  final getUserInspections = GetUserInspections(repository);
  final userInspectionBloc = UserInspectionBloc(
    getUserInspections: getUserInspections,
  );
  final newInspectionBloc = NewInspectionBloc(
    runDamageModel: RunDamageModel(repository),
    submitInspection: SubmitInspection(repository),
  );

  runApp(MyApp(
    userInspectionBloc: userInspectionBloc,
    newInspectionBloc: newInspectionBloc,
  ));
}

// корневой виджет — стартовый экран: LoginScreen (UC-1)
class MyApp extends StatelessWidget {
  final UserInspectionBloc userInspectionBloc;
  final NewInspectionBloc newInspectionBloc;

  const MyApp({
    super.key,
    required this.userInspectionBloc,
    required this.newInspectionBloc,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: userInspectionBloc),
        BlocProvider.value(value: newInspectionBloc),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const LoginScreen(),
      ),
    );
  }
}


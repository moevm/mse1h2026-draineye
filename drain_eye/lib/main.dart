import 'package:drain_eye/data/repositories_impl/inspection_repository_impl.dart';
import 'package:drain_eye/domain/repositories/inspection_repository.dart';
import 'package:drain_eye/domain/usecases/get_user_inspections.dart';
import 'package:drain_eye/presentation/blocs/user_inspection/user_inspection_bloc.dart';
import 'package:drain_eye/presentation/screens/auth/login_screen.dart';
import 'package:drain_eye/presentation/screens/user/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  // создание объектов
  final InspectionRepository repository = InspectionRepositoryImpl();
  final GetUserInspections getUserInspections = GetUserInspections(repository);
  final UserInspectionBloc userInspectionBloc = UserInspectionBloc(
    getUserInspections: getUserInspections,
  );

  // запуск приложения
  runApp(MyApp(bloc: userInspectionBloc));
}

// корневой виджет — стартовый экран: LoginScreen (UC-1)
class MyApp extends StatelessWidget {
  final UserInspectionBloc bloc;

  const MyApp({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider.value(
        value: bloc,
        child: const LoginScreen(),
      ),
    );
  }
}

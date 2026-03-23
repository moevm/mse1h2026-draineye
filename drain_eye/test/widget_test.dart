import 'package:drain_eye/data/repositories_impl/inspection_repository_impl.dart';
import 'package:drain_eye/domain/repositories/inspection_repository.dart';
import 'package:drain_eye/domain/usecases/get_user_inspections.dart';
import 'package:drain_eye/domain/usecases/run_damage_model.dart';
import 'package:drain_eye/domain/usecases/submit_inspection.dart';
import 'package:drain_eye/presentation/blocs/new_inspection/new_inspection_bloc.dart';
import 'package:drain_eye/presentation/blocs/user_inspection/user_inspection_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drain_eye/main.dart';

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

  testWidgets('app starts and shows login title', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(
      userInspectionBloc: userInspectionBloc,
      newInspectionBloc: newInspectionBloc,
    ));
    await tester.pumpAndSettle();
    expect(find.text('DrainEye'), findsOneWidget);
  });
}

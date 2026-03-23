// события NewInspectionBloc
part of 'new_inspection_bloc.dart';

@immutable
abstract class NewInspectionEvent {}

// запуск анализа снимков локальной моделью
class RunDamageAnalysis extends NewInspectionEvent {
  final List<String> photoPaths;
  RunDamageAnalysis(this.photoPaths);
}

// отправка инспекции на сервер
class SubmitNewInspection extends NewInspectionEvent {
  final int userId;
  final List<String> photoPaths;
  final ModelInferenceResult modelResult;

  SubmitNewInspection({
    required this.userId,
    required this.photoPaths,
    required this.modelResult,
  });
}

// сброс состояния (после навигации / закрытия экрана)
class ResetNewInspection extends NewInspectionEvent {}

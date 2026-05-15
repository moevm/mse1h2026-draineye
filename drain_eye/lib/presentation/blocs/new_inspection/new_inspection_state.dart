// состояния NewInspectionBloc
part of 'new_inspection_bloc.dart';

@immutable
abstract class NewInspectionState {}

class NewInspectionInitial extends NewInspectionState {}

class NewInspectionAnalyzing extends NewInspectionState {}

class NewInspectionAnalysisSuccess extends NewInspectionState {
  final ModelInferenceResult result;
  final List<String> photoPaths;

  NewInspectionAnalysisSuccess(this.result, this.photoPaths);
}

class NewInspectionAnalysisFailure extends NewInspectionState {
  final String message;
  NewInspectionAnalysisFailure(this.message);
}

class NewInspectionSubmitting extends NewInspectionState {}

class NewInspectionSubmitSuccess extends NewInspectionState {
  final String message;

  NewInspectionSubmitSuccess({this.message = 'Инспекция сохранена'});
}

class NewInspectionSubmitFailure extends NewInspectionState {
  final String message;
  NewInspectionSubmitFailure(this.message);
}

/// Нет сети — показать экран UC-10.
class NewInspectionOfflineRequired extends NewInspectionState {
  final String engineerId;
  final String address;
  final List<String> photoPaths;
  final ModelInferenceResult modelResult;
  final int pendingCount;

  NewInspectionOfflineRequired({
    required this.engineerId,
    required this.address,
    required this.photoPaths,
    required this.modelResult,
    required this.pendingCount,
  });
}

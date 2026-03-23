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

class NewInspectionSubmitSuccess extends NewInspectionState {}

class NewInspectionSubmitFailure extends NewInspectionState {
  final String message;
  NewInspectionSubmitFailure(this.message);
}

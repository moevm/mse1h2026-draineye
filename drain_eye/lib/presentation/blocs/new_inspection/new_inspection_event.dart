// события NewInspectionBloc
part of 'new_inspection_bloc.dart';

@immutable
abstract class NewInspectionEvent {}

class RunDamageAnalysis extends NewInspectionEvent {
  final List<String> photoPaths;
  RunDamageAnalysis(this.photoPaths);
}

class SubmitNewInspection extends NewInspectionEvent {
  final String engineerId;
  final List<String> photoPaths;
  final ModelInferenceResult modelResult;

  SubmitNewInspection({
    required this.engineerId,
    required this.photoPaths,
    required this.modelResult,
  });
}

class CacheNewInspectionOffline extends NewInspectionEvent {
  final String engineerId;
  final List<String> photoPaths;
  final ModelInferenceResult modelResult;

  CacheNewInspectionOffline({
    required this.engineerId,
    required this.photoPaths,
    required this.modelResult,
  });
}

class ResetNewInspection extends NewInspectionEvent {}

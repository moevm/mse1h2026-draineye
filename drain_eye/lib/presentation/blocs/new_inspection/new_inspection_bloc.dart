// BLoC: анализ снимков локальной моделью и отправка новой инспекции на сервер
import 'package:bloc/bloc.dart';
import 'package:drain_eye/domain/entities/model_inference_result.dart';
import 'package:drain_eye/domain/usecases/run_damage_model.dart';
import 'package:drain_eye/domain/usecases/submit_inspection.dart';
import 'package:flutter/foundation.dart';

part 'new_inspection_event.dart';
part 'new_inspection_state.dart';

class NewInspectionBloc extends Bloc<NewInspectionEvent, NewInspectionState> {
  final RunDamageModel _runDamageModel;
  final SubmitInspection _submitInspection;

  NewInspectionBloc({
    required RunDamageModel runDamageModel,
    required SubmitInspection submitInspection,
  })  : _runDamageModel = runDamageModel,
        _submitInspection = submitInspection,
        super(NewInspectionInitial()) {
    on<RunDamageAnalysis>(_onRunDamageAnalysis);
    on<SubmitNewInspection>(_onSubmitNewInspection);
    on<ResetNewInspection>((_, emit) => emit(NewInspectionInitial()));
  }

  Future<void> _onRunDamageAnalysis(
    RunDamageAnalysis event,
    Emitter<NewInspectionState> emit,
  ) async {
    emit(NewInspectionAnalyzing());
    try {
      final result = await _runDamageModel(event.photoPaths);
      emit(NewInspectionAnalysisSuccess(
        result,
        List<String>.from(event.photoPaths),
      ));
    } catch (e, st) {
      if (kDebugMode) {
        print('RunDamageAnalysis error: $e\n$st');
      }
      emit(NewInspectionAnalysisFailure(e.toString()));
    }
  }

  Future<void> _onSubmitNewInspection(
    SubmitNewInspection event,
    Emitter<NewInspectionState> emit,
  ) async {
    emit(NewInspectionSubmitting());
    try {
      await _submitInspection(
        userId: event.userId,
        photoPaths: event.photoPaths,
        modelResult: event.modelResult,
      );
      emit(NewInspectionSubmitSuccess());
    } catch (e, st) {
      if (kDebugMode) {
        print('SubmitNewInspection error: $e\n$st');
      }
      emit(NewInspectionSubmitFailure(e.toString()));
    }
  }
}

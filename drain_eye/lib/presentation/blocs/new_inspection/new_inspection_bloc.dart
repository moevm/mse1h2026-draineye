import 'package:bloc/bloc.dart';
import 'package:drain_eye/core/offline_inspection_exception.dart';
import 'package:drain_eye/domain/entities/model_inference_result.dart';
import 'package:drain_eye/domain/repositories/inspection_repository.dart';
import 'package:drain_eye/domain/usecases/cache_inspection_offline.dart';
import 'package:drain_eye/domain/usecases/run_damage_model.dart';
import 'package:drain_eye/domain/usecases/submit_inspection.dart';
import 'package:drain_eye/domain/usecases/sync_pending_inspections.dart';
import 'package:flutter/foundation.dart';

part 'new_inspection_event.dart';
part 'new_inspection_state.dart';

class NewInspectionBloc extends Bloc<NewInspectionEvent, NewInspectionState> {
  final RunDamageModel _runDamageModel;
  final SubmitInspection _submitInspection;
  final CacheInspectionOffline _cacheInspectionOffline;
  final SyncPendingInspections _syncPendingInspections;
  final InspectionRepository _inspectionRepository;

  NewInspectionBloc({
    required RunDamageModel runDamageModel,
    required SubmitInspection submitInspection,
    required CacheInspectionOffline cacheInspectionOffline,
    required SyncPendingInspections syncPendingInspections,
    required InspectionRepository inspectionRepository,
  })  : _runDamageModel = runDamageModel,
        _submitInspection = submitInspection,
        _cacheInspectionOffline = cacheInspectionOffline,
        _syncPendingInspections = syncPendingInspections,
        _inspectionRepository = inspectionRepository,
        super(NewInspectionInitial()) {
    on<RunDamageAnalysis>(_onRunDamageAnalysis);
    on<SubmitNewInspection>(_onSubmitNewInspection);
    on<CacheNewInspectionOffline>(_onCacheOffline);
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
      final result = await _submitInspection(
        engineerId: event.engineerId,
        photoPaths: event.photoPaths,
        modelResult: event.modelResult,
      );
      emit(NewInspectionSubmitSuccess(
        message: 'Инспекция сохранена (${result.status.labelRu})',
      ));
    } on OfflineInspectionException {
      final pending = await _inspectionRepository.pendingInspectionsCount();
      emit(NewInspectionOfflineRequired(
        engineerId: event.engineerId,
        photoPaths: event.photoPaths,
        modelResult: event.modelResult,
        pendingCount: pending,
      ));
    } catch (e, st) {
      if (kDebugMode) {
        print('SubmitNewInspection error: $e\n$st');
      }
      emit(NewInspectionSubmitFailure(_errorMessage(e)));
    }
  }

  Future<void> _onCacheOffline(
    CacheNewInspectionOffline event,
    Emitter<NewInspectionState> emit,
  ) async {
    emit(NewInspectionSubmitting());
    try {
      await _cacheInspectionOffline(
        engineerId: event.engineerId,
        photoPaths: event.photoPaths,
        modelResult: event.modelResult,
      );
      await _syncPendingInspections();
      emit(NewInspectionSubmitSuccess(
        message: 'Сохранено в кэш. Будет отправлено при появлении сети',
      ));
    } catch (e, st) {
      if (kDebugMode) {
        print('CacheNewInspectionOffline error: $e\n$st');
      }
      emit(NewInspectionSubmitFailure(_errorMessage(e)));
    }
  }

  String _errorMessage(Object e) {
    return e.toString().replaceFirst('Exception: ', '').replaceFirst(
          'ArgumentError: ',
          '',
        );
  }
}

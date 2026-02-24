// реализация BLoC для управления состоянием списка инспекций пользователя

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:drain_eye/domain/usecases/get_user_inspections.dart';
import 'package:drain_eye/domain/entities/inspection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// подключение частей с определениями событий и состояний
part 'user_inspection_event.dart';
part 'user_inspection_state.dart';


// BLoC для управления инспекциями пользователя
// принимает событие LoadUserInspections и emits состояния из файла с состояниями
class UserInspectionBloc extends Bloc<UserInspectionEvent, UserInspectionState> {
  final GetUserInspections _getUserInspections;   // use case для получения потока инспекций пользователя
  StreamSubscription? _subscription;              // подписка на поток данных из use case

  UserInspectionBloc({required GetUserInspections getUserInspections})
      : _getUserInspections = getUserInspections,
        super(UserInspectionInitial()) {
    // регистрация обработчиков событий 
    // (то есть при получении события LoadUserInspections будет вызыван
    // метод _onLoadUserInspections и тд)
    on<LoadUserInspections>(_onLoadUserInspections);
    on<_InspectionsUpdated>(_onInspectionsUpdated);
    on<_InspectionsError>(_onInspectionsError);
  }

  // обрабатывает событие LoadUserInspections
  // переводит состояние в Loading, отменяет предыдущую подписку
  // и подписывается на поток данных из use case
  Future<void> _onLoadUserInspections(
    LoadUserInspections event,
    Emitter<UserInspectionState> emit,
  ) async {
    // отправление информации об изменении состояния всем подписчикам потока
    emit(UserInspectionLoading());

    // отменение предыдущей подписки
    await _subscription?.cancel();

    // подписка на поток инспекций из use case
    _subscription = _getUserInspections(event.userId).listen(
      (inspections) {
        // при приходе новых данных добавляется внутреннее событие
        add(_InspectionsUpdated(inspections));
      },
      onError: (error) {
        add(_InspectionsError(error.toString()));
      },
    );
  }

  // обрабатывает внутреннее событие _InspectionsUpdated
  // получает список инспекций и переводит состояние в UserInspectionLoaded
  void _onInspectionsUpdated(_InspectionsUpdated event, Emitter<UserInspectionState> emit) {
    emit(UserInspectionLoaded(event.inspections));
  }

  // обрабатывает внутреннее событие _InspectionsError
  // переводит состояние в UserInspectionError с текстом ошибки. 
  void _onInspectionsError(_InspectionsError event, Emitter<UserInspectionState> emit) {
    emit(UserInspectionError(event.message));
  }

  // закрывает BLoC - отменяет подписку 
  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}


// внутренние события 
class _InspectionsUpdated extends UserInspectionEvent {
  final List<Inspection> inspections;
  _InspectionsUpdated(this.inspections);
}

class _InspectionsError extends UserInspectionEvent {
  final String message;
  _InspectionsError(this.message);
}
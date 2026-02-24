// описание всех состояний, которые может принимать UserInspectionBloc

// указывает, что данный файл является частью библиотеки user_inspection_bloc
part of 'user_inspection_bloc.dart';

// абстрактный класс для всех состояний
@immutable
abstract class UserInspectionState {}

// начальное состояние BLoC до того, как произошло какое-либо событие
class UserInspectionInitial extends UserInspectionState {}

// состояние, означающее, что данные загружаются 
class UserInspectionLoading extends UserInspectionState {}

// состояние, сигнализирующее об успешной загрузке данных
class UserInspectionLoaded extends UserInspectionState {
  final List<Inspection> inspections;       // полученные из репозитория инспекции
  UserInspectionLoaded(this.inspections);
}

// состояние ошибки, возникающее при сбое загрузки данных
class UserInspectionError extends UserInspectionState {
  final String message;
  UserInspectionError(this.message);
}
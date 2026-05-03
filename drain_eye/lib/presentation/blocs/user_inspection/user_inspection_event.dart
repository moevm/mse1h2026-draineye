// определение событий, которые могут быть отправлены в UserInspectionBloc

// указывает, что данный файл является частью библиотеки user_inspection_bloc
part of 'user_inspection_bloc.dart';

// абстрактный класс для всех событий
@immutable
abstract class UserInspectionEvent {}

// событие, сигнализирующее о необходимости загрузить список инспекций
// текущего авторизованного пользователя
class LoadUserInspections extends UserInspectionEvent {
  LoadUserInspections();
}

// Базовый URL сервера. Меняется при каждом запуске tuna.am — обновлять здесь.
class ApiConfig {
  static const String baseUrl = 'https://q3cxua-95-161-60-178.ru.tuna.am';

  static const String inspectorApiBase = '$baseUrl/inspector';

  static const String login = '$inspectorApiBase/login';
  static const String register = '$inspectorApiBase/register';
  static const String myInspections = '$inspectorApiBase/my_inspections';
  static const String addInspection = '$inspectorApiBase/add_inspection';

  static const Map<String, String> defaultHeaders = {
    'Accept': 'application/json',
    'tuna-skip-browser-warning': 'true',
  };
}

class TestConstants {
  // Тестовые данные
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'Test123!@#';
  static const String testName = 'Test User';

  // Страница входа
  static const String appName = 'DrainEye';
  static const String loginTitle = 'Вход в систему';
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Пароль';
  static const String loginButtonText = 'Войти';
  static const String forgotPasswordText = 'Забыли пароль?';
  static const String googleAuthButtonText = 'Войти через Google';
  static const String registerLinkText = 'Зарегистрироваться';
  static const String noAccountText = 'Нет аккаунта?';
  static const String emailPlaceholder = 'user@example.com';
  static const String passwordPlaceholder = 'Введите пароль';

  // Страница регистрации
  static const String registrationTitle = 'Регистрация';
  static const String registrationSubtitle = 'Создайте аккаунт DrainEye';
  static const String nameLabel = 'Имя';
  static const String namePlaceholder = 'Иван Петров';
  static const String createAccountButtonText = 'Создать аккаунт';
  static const String alreadyHaveAccountText = 'Уже есть аккаунт?';
  static const String loginLinkText = 'Войти';

  // Страница сброса пароля
  static const String forgotPasswordTitle = 'Восстановление пароля';
  static const String resetButtonText = 'Отправить инструкцию';

  // Главная страница
  static const String mainScreenTitle = 'DrainEye';
  static const String newInspectionTitle = 'Новая инспекция';
  static const String profileTitle = 'Профиль';
  static const String historyTabLabel = 'История';
  static const String shootingTabLabel = 'Съёмка';
  static const String profileTabLabel = 'Профиль';
  static const String logoutButtonText = 'Выйти';

  // Время ожидания
  static const Duration defaultWaitDuration = Duration(seconds: 5);
  static const Duration shortWaitDuration = Duration(seconds: 2);
}

// Навигация
enum AppScreen { login, register, forgotPassword, main, inspection }

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

    // Страница восстановления пароля
  static const String forgotPasswordTitle = 'Восстановление пароля';
  static const String forgotPasswordSubtitle = 'Введите email для получения ссылки';
  static const String sendLinkButtonText = 'Отправить ссылку';
  static const String backToLoginButtonText = '\u2190 Назад ко входу';
  static const String newPasswordTitle = 'Новый пароль';
  static const String emailSentMessage = 'Письмо отправлено. Проверьте почту и папку «Спам»';

  // Время ожидания
  static const Duration defaultWaitDuration = Duration(seconds: 5);
  static const Duration shortWaitDuration = Duration(seconds: 2);
}

// Навигация
enum AppScreen { login, register, forgotPassword, main, inspection }

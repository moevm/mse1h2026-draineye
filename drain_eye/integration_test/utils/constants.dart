class TestConstants {
  // Тестовые данные
  static const String testEmail = 'ivanov@mail.com';
  static const String testPassword = 'Test123!@#';
  static const String testName = 'Иванов Алексей';

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

  // Страница "Восстановление пароля"
  static const String forgotPasswordTitle = 'Восстановление пароля';
  static const String forgotPasswordSubtitle =
      'Введите email для получения ссылки';
  static const String sendLinkButtonText = 'Отправить ссылку';
  static const String backToLoginButtonText = '\u2190 Назад ко входу';
  static const String newPasswordTitle = 'Новый пароль';
  static const String emailSentMessage = 'Письмо отправлено. Проверьте почту и папку «Спам»';

  // Сраница "Регистрация"
  static const String registrationTitle = 'Регистрация';
  static const String registrationSubtitle = 'Создайте аккаунт DrainEye';
  static const String nameLabel = 'Имя';
  static const String namePlaceholder = 'Иван Петров';
  static const String createAccountButtonText = 'Создать аккаунт';
  static const String alreadyHaveAccountText = 'Уже есть аккаунт?';
  static const String loginLinkText = 'Войти';

  // Страница "История"
  static const String historyPageTitle = 'История';
  static const String backButtonText = 'Назад';

  // Страница "Съемка"
  static const String cameraScreenTitle = 'Съёмка';
  static const String takePhotoButtonText = 'Сделать фото';
  static const String cameraCanceledMessage = 'Из галереи';

  // Страница "Профиль"
  static const String profilePageTitle = 'Профиль';
  static const String userStatusText = 'Активен';
  static const String logoutButtonText = 'Выйти';
  static const String userInfoLabel = 'Информация';
  static const String roleText = 'Роль';
  static const String registrationDate = '15.01.2026';
  static const String lastActivity = '23.02.2026';
  static const String inspectorText = 'Инспектор';
  static const int totalInspections = 124;

  // Время ожидания
  static const Duration defaultWaitDuration = Duration(seconds: 5);
  static const Duration shortWaitDuration = Duration(seconds: 2);
}

// Навигация
enum AppScreen { login, register, forgotPassword, main, inspection }

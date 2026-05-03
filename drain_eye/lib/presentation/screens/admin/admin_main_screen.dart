import 'package:drain_eye/presentation/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';

const _teal = Color(0xFF0D9488);

/// Главный экран администратора — заглушка панели управления.
class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Панель управления';
      case 1:
        return 'Пользователи';
      case 2:
        return 'Инспекции';
      case 3:
        return 'Настройки';
      default:
        return 'DrainEye Admin';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        title: Row(
          children: [
            if (_selectedIndex == 0) ...[
              const Icon(Icons.admin_panel_settings, size: 22),
              const SizedBox(width: 8),
            ],
            Text(_getAppBarTitle()),
          ],
        ),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
        toolbarHeight: 56,
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Пользователи',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Инспекции',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Настройки',
            ),
          ],
          selectedItemColor: _teal,
          unselectedItemColor: const Color(0xFF94A3B8),
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 12,
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildUsersTab();
      case 2:
        return _buildInspectionsTab();
      case 3:
        return _buildSettingsTab();
      default:
        return const SizedBox.shrink();
    }
  }

  // --- Вкладка: Панель управления ---
  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Обзор системы',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 16),
          // статистика — карточки
          Row(
            children: [
              Expanded(child: _statCard('Инспекторов', '12', Icons.person, const Color(0xFF3B82F6))),
              const SizedBox(width: 12),
              Expanded(child: _statCard('Инспекций', '148', Icons.assignment, _teal)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _statCard('За сегодня', '5', Icons.today, const Color(0xFFF59E0B))),
              const SizedBox(width: 12),
              Expanded(child: _statCard('На проверке', '3', Icons.pending_actions, const Color(0xFFEF4444))),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Последние действия',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 12),
          _activityItem('Иванов А.П.', 'Новая инспекция #147', '10 мин назад'),
          _activityItem('Петров С.К.', 'Загрузил фото к инспекции #145', '25 мин назад'),
          _activityItem('Сидоров Д.В.', 'Завершил инспекцию #143', '1 час назад'),
          _activityItem('Козлова М.А.', 'Зарегистрировалась в системе', '2 часа назад'),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _activityItem(String user, String action, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _teal.withOpacity(0.1),
            child: Text(
              user.split(' ').first[0],
              style: const TextStyle(color: _teal, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 2),
                Text(action, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  // --- Вкладка: Пользователи ---
  Widget _buildUsersTab() {
    final users = [
      _UserRow('Иванов Алексей Петрович', 'ivanov@mail.com', 'Инспектор', true),
      _UserRow('Петров Сергей Константинович', 'petrov@mail.com', 'Инспектор', true),
      _UserRow('Сидоров Дмитрий Владимирович', 'sidorov@mail.com', 'Инспектор', false),
      _UserRow('Козлова Мария Андреевна', 'kozlova@mail.com', 'Инспектор', true),
      _UserRow('Админов Павел Игоревич', 'admin@draineye.com', 'Администратор', true),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Text('Все пользователи', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final u = users[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: _teal.withOpacity(0.1),
                      child: Text(
                        u.name.split(' ').map((w) => w[0]).take(2).join(),
                        style: const TextStyle(color: _teal, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          const SizedBox(height: 2),
                          Text(u.email, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: u.role == 'Администратор' ? const Color(0xFFEDE9FE) : const Color(0xFFF0FDFA),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            u.role,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: u.role == 'Администратор' ? const Color(0xFF7C3AED) : _teal,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: u.active ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Вкладка: Инспекции ---
  Widget _buildInspectionsTab() {
    final inspections = [
      _InspectionRow('#147', 'Иванов А.П.', 'ул. Ленина, 12', 'На проверке', const Color(0xFFF59E0B)),
      _InspectionRow('#146', 'Петров С.К.', 'пр. Мира, 45', 'Завершена', const Color(0xFF22C55E)),
      _InspectionRow('#145', 'Петров С.К.', 'ул. Гагарина, 8', 'Завершена', const Color(0xFF22C55E)),
      _InspectionRow('#144', 'Сидоров Д.В.', 'ул. Пушкина, 3', 'Отклонена', const Color(0xFFEF4444)),
      _InspectionRow('#143', 'Сидоров Д.В.', 'пр. Невский, 100', 'Завершена', const Color(0xFF22C55E)),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Text('Все инспекции', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              const Spacer(),
              Text('${inspections.length} записей', style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: inspections.length,
            itemBuilder: (context, index) {
              final i = inspections[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.camera_alt, color: Color(0xFF94A3B8), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Инспекция ${i.id}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: i.statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(i.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: i.statusColor)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('${i.inspector} \u2022 ${i.address}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Вкладка: Настройки ---
  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _settingsSection('Система', [
            _settingsItem(Icons.cloud_upload, 'Синхронизация данных', 'Автоматическая'),
            _settingsItem(Icons.model_training, 'ML-модель', 'v2.1.0'),
            _settingsItem(Icons.storage, 'Хранилище', '2.3 ГБ из 10 ГБ'),
          ]),
          const SizedBox(height: 20),
          _settingsSection('Уведомления', [
            _settingsItem(Icons.notifications, 'Push-уведомления', 'Включены'),
            _settingsItem(Icons.email, 'Email-отчёты', 'Еженедельно'),
          ]),
          const SizedBox(height: 20),
          _settingsSection('Безопасность', [
            _settingsItem(Icons.lock, 'Смена пароля', ''),
            _settingsItem(Icons.security, 'Двухфакторная аутентификация', 'Выключена'),
          ]),
          const SizedBox(height: 24),
          // кнопка выхода
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFEF4444)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Выйти из аккаунта', style: TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _settingsItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _teal),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF334155)))),
          if (value.isNotEmpty)
            Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}

class _UserRow {
  final String name;
  final String email;
  final String role;
  final bool active;
  _UserRow(this.name, this.email, this.role, this.active);
}

class _InspectionRow {
  final String id;
  final String inspector;
  final String address;
  final String status;
  final Color statusColor;
  _InspectionRow(this.id, this.inspector, this.address, this.status, this.statusColor);
}

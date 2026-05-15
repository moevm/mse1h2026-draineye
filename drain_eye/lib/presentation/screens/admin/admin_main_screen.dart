import 'package:drain_eye/data/datasources/admin_remote_datasource.dart';
import 'package:drain_eye/domain/entities/admin_inspection.dart';
import 'package:drain_eye/domain/entities/admin_user.dart';
import 'package:drain_eye/presentation/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const _teal = Color(0xFF0D9488);

/// Главный экран администратора.
class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;
  final _ds = AdminRemoteDataSource();

  // Состояние дашборда
  DashboardMetrics? _metrics;
  bool _metricsLoading = false;
  String? _metricsError;

  // Состояние списка пользователей
  final List<AdminUser> _users = [];
  String? _usersNextCursor;
  bool _usersHasMore = true;
  bool _usersLoading = false;
  bool _usersInitialLoaded = false;
  String? _usersError;

  // Состояние списка инспекций
  final List<AdminInspection> _inspections = [];
  String? _inspectionsNextCursor;
  bool _inspectionsHasMore = true;
  bool _inspectionsLoading = false;
  bool _inspectionsInitialLoaded = false;
  String? _inspectionsError;

  // Последние инспекции на главной (фиксированное число записей)
  static const int _recentInspectionsLimit = 4;
  List<AdminInspection> _recentInspections = const [];
  bool _recentLoading = false;
  String? _recentError;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
    _loadRecentInspections();
  }

  Future<void> _loadMetrics() async {
    setState(() { _metricsLoading = true; _metricsError = null; });
    try {
      final result = await _ds.getDashboardMetrics();
      if (mounted) setState(() => _metrics = result);
    } on AdminException catch (e) {
      if (mounted) setState(() => _metricsError = e.message);
    } catch (_) {
      if (mounted) setState(() => _metricsError = 'Нет соединения с сервером');
    } finally {
      if (mounted) setState(() => _metricsLoading = false);
    }
  }

  Future<void> _loadRecentInspections() async {
    setState(() { _recentLoading = true; _recentError = null; });
    try {
      final result = await _ds.getInspections(limit: _recentInspectionsLimit);
      if (mounted) setState(() => _recentInspections = result.items);
    } on AdminException catch (e) {
      if (mounted) setState(() => _recentError = e.message);
    } catch (_) {
      if (mounted) setState(() => _recentError = 'Нет соединения с сервером');
    } finally {
      if (mounted) setState(() => _recentLoading = false);
    }
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1 && !_usersInitialLoaded) _loadUsers();
    if (index == 2 && !_inspectionsInitialLoaded) _loadInspections();
  }

  Future<void> _loadUsers({bool reset = false}) async {
    if (_usersLoading) return;
    setState(() {
      _usersLoading = true;
      _usersError = null;
      if (reset) {
        _users.clear();
        _usersNextCursor = null;
        _usersHasMore = true;
      }
    });
    try {
      final result = await _ds.getUsers(nextCursor: _usersNextCursor);
      if (!mounted) return;
      setState(() {
        _users.addAll(result.items);
        _usersNextCursor = result.nextCursor;
        _usersHasMore = result.hasMore;
        _usersInitialLoaded = true;
      });
    } on AdminException catch (e) {
      if (mounted) setState(() => _usersError = e.message);
    } catch (_) {
      if (mounted) setState(() => _usersError = 'Нет соединения с сервером');
    } finally {
      if (mounted) setState(() => _usersLoading = false);
    }
  }

  Future<void> _loadInspections({bool reset = false}) async {
    if (_inspectionsLoading) return;
    setState(() {
      _inspectionsLoading = true;
      _inspectionsError = null;
      if (reset) {
        _inspections.clear();
        _inspectionsNextCursor = null;
        _inspectionsHasMore = true;
      }
    });
    try {
      final result = await _ds.getInspections(nextCursor: _inspectionsNextCursor);
      if (!mounted) return;
      setState(() {
        _inspections.addAll(result.items);
        _inspectionsNextCursor = result.nextCursor;
        _inspectionsHasMore = result.hasMore;
        _inspectionsInitialLoaded = true;
      });
    } on AdminException catch (e) {
      if (mounted) setState(() => _inspectionsError = e.message);
    } catch (_) {
      if (mounted) setState(() => _inspectionsError = 'Нет соединения с сервером');
    } finally {
      if (mounted) setState(() => _inspectionsLoading = false);
    }
  }

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
        titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        toolbarHeight: 56,
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
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
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Главная'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Пользователи'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Инспекции'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Настройки'),
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

  Widget _buildDashboard() {
    if (_metricsLoading) {
      return const Center(child: CircularProgressIndicator(color: _teal));
    }
    if (_metricsError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_metricsError!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            TextButton(onPressed: _loadMetrics, child: const Text('Повторить')),
          ],
        ),
      );
    }
    final m = _metrics;
    return RefreshIndicator(
      color: _teal,
      onRefresh: () async {
        await Future.wait([_loadMetrics(), _loadRecentInspections()]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Обзор системы', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _statCard('Инспекторов', '${m?.totalInspectors ?? 0}', Icons.person, const Color(0xFF3B82F6))),
                const SizedBox(width: 12),
                Expanded(child: _statCard('Инспекций', '${m?.totalInspections ?? 0}', Icons.assignment, _teal)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _statCard('За сегодня', '${m?.todayCount ?? 0}', Icons.today, const Color(0xFFF59E0B))),
                const SizedBox(width: 12),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Последние инспекции', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
            const SizedBox(height: 12),
            _buildRecentInspections(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentInspections() {
    if (_recentLoading && _recentInspections.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: _teal),
      );
    }
    if (_recentError != null && _recentInspections.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Column(
          children: [
            Text(_recentError!, style: const TextStyle(fontSize: 13, color: Color(0xFFEF4444))),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _loadRecentInspections, child: const Text('Повторить')),
          ],
        ),
      );
    }
    if (_recentInspections.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: const Text('Пока нет инспекций', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
      );
    }
    return Column(
      children: [
        for (final i in _recentInspections) _recentInspectionCard(i),
      ],
    );
  }

  Widget _recentInspectionCard(AdminInspection i) {
    final fullName = i.engineer?.fullName ?? '—';
    final inspectorShort = _shortName(fullName);
    final initial = fullName.trim().isNotEmpty ? fullName.trim()[0].toUpperCase() : '?';
    final shortId = '#${i.id.length > 6 ? i.id.substring(i.id.length - 6) : i.id}';
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
            child: Text(initial, style: const TextStyle(color: _teal, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(inspectorShort, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 2),
                Text('Новая инспекция $shortId', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(_relativeTime(i.timestamp), style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  String _relativeTime(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inSeconds < 60) return 'только что';
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин назад';
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h ${h == 1 ? 'час' : (h < 5 ? 'часа' : 'часов')} назад';
    }
    if (diff.inDays < 7) {
      final d = diff.inDays;
      return '$d ${d == 1 ? 'день' : (d < 5 ? 'дня' : 'дней')} назад';
    }
    return DateFormat('dd.MM.yyyy').format(ts);
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
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
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


  // --- Вкладка: Пользователи ---
  Widget _buildUsersTab() {
    if (!_usersInitialLoaded && _usersLoading) {
      return const Center(child: CircularProgressIndicator(color: _teal));
    }
    if (_usersError != null && _users.isEmpty) {
      return _errorView(_usersError!, () => _loadUsers(reset: true));
    }
    return RefreshIndicator(
      color: _teal,
      onRefresh: () => _loadUsers(reset: true),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _users.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Все пользователи', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              ),
            );
          }
          if (index == _users.length + 1) {
            return _buildLoadMore(_usersHasMore, _usersLoading, _usersError, () => _loadUsers());
          }
          return _userCard(_users[index - 1]);
        },
      ),
    );
  }

  Widget _userCard(AdminUser u) {
    final isAdmin = u.role.toLowerCase() == 'admin' || u.role == 'Администратор';
    final initials = u.fullName.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0]).join();
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
            child: Text(initials, style: const TextStyle(color: _teal, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u.fullName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
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
                  color: isAdmin ? const Color(0xFFEDE9FE) : const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isAdmin ? 'Администратор' : 'Инспектор',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isAdmin ? const Color(0xFF7C3AED) : _teal),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: u.isActive ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Вкладка: Инспекции ---
  Widget _buildInspectionsTab() {
    if (!_inspectionsInitialLoaded && _inspectionsLoading) {
      return const Center(child: CircularProgressIndicator(color: _teal));
    }
    if (_inspectionsError != null && _inspections.isEmpty) {
      return _errorView(_inspectionsError!, () => _loadInspections(reset: true));
    }
    return RefreshIndicator(
      color: _teal,
      onRefresh: () => _loadInspections(reset: true),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _inspections.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Text('Все инспекции', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                  const Spacer(),
                  Text('${_inspections.length} записей', style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                ],
              ),
            );
          }
          if (index == _inspections.length + 1) {
            return _buildLoadMore(_inspectionsHasMore, _inspectionsLoading, _inspectionsError, () => _loadInspections());
          }
          return _inspectionCard(_inspections[index - 1]);
        },
      ),
    );
  }

  Widget _inspectionCard(AdminInspection i) {
    final statusInfo = _statusUi(i.statusSync);
    final inspectorShort = _shortName(i.engineer?.fullName ?? '');
    final shortId = '#${i.id.length > 6 ? i.id.substring(i.id.length - 6) : i.id}';
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
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.camera_alt, color: Color(0xFF94A3B8), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Инспекция $shortId', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: statusInfo.color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(statusInfo.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: statusInfo.color)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('$inspectorShort • ${i.address}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 20),
        ],
      ),
    );
  }

  String _shortName(String full) {
    final parts = full.split(' ').where((w) => w.isNotEmpty).toList();
    if (parts.isEmpty) return '—';
    if (parts.length == 1) return parts.first;
    final initials = parts.skip(1).map((w) => '${w[0]}.').join('');
    return '${parts.first} $initials';
  }

  ({String label, Color color}) _statusUi(String status) {
    switch (status) {
      case 'save':
      case 'synced':
        return (label: 'Завершена', color: const Color(0xFF22C55E));
      case 'pending':
        return (label: 'На проверке', color: const Color(0xFFF59E0B));
      case 'rejected':
        return (label: 'Отклонена', color: const Color(0xFFEF4444));
      default:
        return (label: status, color: const Color(0xFF94A3B8));
    }
  }

  // --- Кнопка «Загрузить ещё» ---
  Widget _buildLoadMore(bool hasMore, bool loading, String? error, VoidCallback onLoad) {
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(error, style: const TextStyle(fontSize: 13, color: Color(0xFFEF4444))),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onLoad, child: const Text('Повторить')),
          ],
        ),
      );
    }
    if (!hasMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: Text('Больше нет записей', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)))),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: _teal,
            side: const BorderSide(color: _teal),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: loading ? null : onLoad,
          child: loading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: _teal))
              : const Text('Загрузить ещё', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _errorView(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Color(0xFF334155))),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _teal, foregroundColor: Colors.white),
              onPressed: onRetry,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
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
          if (value.isNotEmpty) Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}

// Используется только как placeholder для intl-форматтера дат, если понадобится.
// ignore: unused_element
String _formatTs(DateTime dt) => DateFormat('dd.MM.yyyy HH:mm').format(dt);

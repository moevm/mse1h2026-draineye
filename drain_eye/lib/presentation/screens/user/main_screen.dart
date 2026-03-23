import 'package:drain_eye/domain/entities/inspection.dart';
import 'package:drain_eye/presentation/blocs/user_inspection/user_inspection_bloc.dart';
import 'package:drain_eye/presentation/screens/user/camera_screen.dart';
import 'package:drain_eye/presentation/screens/user/history_screen.dart';
import 'package:drain_eye/presentation/screens/user/inspection_screen.dart';
import 'package:drain_eye/presentation/screens/user/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// цвета из макета
const _teal = Color(0xFF0D9488);

// главный экран приложения пользователя
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final int _userId = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<UserInspectionBloc>(context).add(LoadUserInspections(_userId));
    });
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'DrainEye';
      case 1:
        return 'Новая инспекция';
      case 2:
        return 'Профиль';
      default:
        return 'DrainEye';
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onInspectionTap(Inspection inspection) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InspectionScreen(inspection: inspection),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        title: Row(
          children: [
            if (_selectedIndex == 0) ...[
              const Icon(Icons.visibility, size: 22),
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
      ),
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'История',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt),
              label: 'Съёмка',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Профиль',
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
        return BlocBuilder<UserInspectionBloc, UserInspectionState>(
          builder: (context, state) {
            if (state is UserInspectionLoading) {
              return const Center(child: CircularProgressIndicator(color: _teal));
            } else if (state is UserInspectionLoaded) {
              return HistoryScreen(
                inspections: state.inspections,
                onInspectionTap: _onInspectionTap,
              );
            } else if (state is UserInspectionError) {
              return Center(child: Text('Ошибка: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        );
      case 1:
        return const CameraScreen();
      case 2:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}

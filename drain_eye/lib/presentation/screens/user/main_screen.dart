import 'package:drain_eye/domain/entities/inspection.dart';
import 'package:drain_eye/presentation/blocs/user_inspection/user_inspection_bloc.dart';
import 'package:drain_eye/presentation/screens/user/camera_screen.dart';
import 'package:drain_eye/presentation/screens/user/history_screen.dart';
import 'package:drain_eye/presentation/screens/user/inspection_screen.dart';
import 'package:drain_eye/presentation/screens/user/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// главный экран приложения пользователя
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}


class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;   // 0 – история, 1 – камера, 2 – профиль
  final int _userId = 1;    // пока нет авторизации

  // вызывает BLoC для загрузки инспекций
  // выполняется только один раз при создании виджета 
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      BlocProvider.of<UserInspectionBloc>(context).add(LoadUserInspections(_userId));
    });
  }

  // возвращает заголовок в шапке в зависимости от страницы, 
  // на которой находится пользователь
  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return '𓁺 DrainEye';
      case 1:
        return 'Новая инспекция';
      case 2:
        return 'Профиль';
      default:
        return 'DrainEye';
    }
  }

  // обрабатывает нажатие на пункт нижней навигации
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // обрабатывает нажатие на конкретную карточку инспекции 
  // вызывает экран с информацией об инспекции
  void _onInspectionTap(Inspection inspection) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InspectionScreen(inspection: inspection),
      ),
    );
  }

  // создает главный экран
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 213, 225, 224),
      // верхняя панель
      appBar: AppBar(
        title: Text(_getAppBarTitle()),   
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 23,
        ),
        toolbarHeight: 70,
        backgroundColor: const Color.fromARGB(255, 2, 155, 124),
        foregroundColor: Colors.white,
      ),
      // содержимое зависит от выбранной вкладки
      body: _buildBody(),
      // нижняя панель 
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
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
        selectedItemColor: const Color.fromARGB(255, 2, 155, 124),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }

  // построение основы экрана в зависимости от выбранной вкладки 
  Widget _buildBody() {
    switch (_selectedIndex) {
      // вкладка с историей инспекций
      case 0: 
        return BlocBuilder<UserInspectionBloc, UserInspectionState>(
          builder: (context, state) {
            if (state is UserInspectionLoading) {
              return const Center(child: CircularProgressIndicator());
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
      // вкладка с камерой для новой инспекции
      case 1: 
        return CameraScreen();
      // вкладка с профилем
      case 2:
        return ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}

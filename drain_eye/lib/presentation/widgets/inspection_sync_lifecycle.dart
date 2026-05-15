import 'package:drain_eye/domain/usecases/sync_pending_inspections.dart';
import 'package:drain_eye/presentation/blocs/user_inspection/user_inspection_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Фоновая синхронизация кэша при старте и возврате в приложение (UC-10).
class InspectionSyncLifecycle extends StatefulWidget {
  final Widget child;
  final SyncPendingInspections syncPendingInspections;

  const InspectionSyncLifecycle({
    super.key,
    required this.child,
    required this.syncPendingInspections,
  });

  @override
  State<InspectionSyncLifecycle> createState() =>
      _InspectionSyncLifecycleState();
}

class _InspectionSyncLifecycleState extends State<InspectionSyncLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sync();
    }
  }

  Future<void> _sync() async {
    try {
      await widget.syncPendingInspections();
      if (mounted) {
        context.read<UserInspectionBloc>().add(LoadUserInspections());
      }
    } catch (_) {
      // Синхронизация best-effort при появлении сети.
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

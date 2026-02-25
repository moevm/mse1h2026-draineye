import 'package:flutter/material.dart';
import 'package:drain_eye/domain/entities/inspection.dart';
import 'package:drain_eye/presentation/widgets/inspection_card.dart';

// экран с историей инспекций пользователя — по макету UC-7
class HistoryScreen extends StatelessWidget {
  final List<Inspection> inspections;
  final Function(Inspection) onInspectionTap;

  const HistoryScreen({
    super.key,
    required this.inspections,
    required this.onInspectionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // заголовок
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Мои инспекции',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        // список инспекций
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 8),
            itemCount: inspections.length,
            itemBuilder: (context, index) {
              final insp = inspections[index];
              return InspectionCard(
                inspection: insp,
                onTap: () => onInspectionTap(insp),
              );
            },
          ),
        ),
      ],
    );
  }
}

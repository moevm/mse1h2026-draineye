import 'package:flutter/material.dart';
import 'package:drain_eye/domain/entities/inspection.dart';
import 'package:drain_eye/presentation/widgets/inspection_card.dart';

// экран с историей инспекций пользователя
class HistoryScreen extends StatelessWidget {
  final List<Inspection> inspections;           // отображаемые инспекции
  final Function(Inspection) onInspectionTap;   // обработчик нажатия

  const HistoryScreen({
    super.key,
    required this.inspections,
    required this.onInspectionTap,
  });

  // создает экран с историей инспекций
  @override
  Widget build(BuildContext context) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // заголовок 
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Мои инспекции',
                style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: const Color.fromARGB(195, 0, 0, 0)
                    ),
              ),
            ),
            // инспекции
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: inspections.length,
                itemBuilder: (context, index) {
                  final insp = inspections[index];
                  return InspectionCard(
                    inspection: insp,
                    // при нажатии на инспекцию вызывается функция для смены экрана
                    onTap: () => onInspectionTap(insp)   
                  );
                },
              ),
            ),
          ],
        );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/inspection.dart';

// виджет карточки для отображения краткой информации об инспекции
class InspectionCard extends StatelessWidget {
  final Inspection inspection;  // отображаемая инспекция
  final VoidCallback onTap;     // обратный вызов при нажатии на карточку

  const InspectionCard({
    super.key,
    required this.inspection,
    required this.onTap,
  });

  // создает виджет карточки инспекции
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy, HH:mm');
    final dateTimeStr = dateFormat.format(inspection.timestamp);
    // преобразование уверенности модели в проценты
    final confidencePercent = (inspection.confidence * 100).round();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        // заглушка для будущего фото
        leading: Container(
          width: 60,
          height: 60,
          color: Colors.grey.shade300,
          child: const Icon(Icons.image, color: Colors.grey),
        ),
        // дата инспекции
        title: Text(dateTimeStr, style: TextStyle(
          color: const Color.fromARGB(100, 0, 0, 0), 
          fontSize: 13)
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
            ),
            // адрес инспекции
            Text(
              inspection.address, 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16
              ),
            ),
            const SizedBox(height: 4),
            // материал, состояние и увереность модели
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                  child: Text(
                    inspection.material,
                    style: TextStyle(color: const Color.fromARGB(114, 0, 0, 0)),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1),
                  child: Text(' •', style: TextStyle(color: Color.fromARGB(114, 0, 0, 0)),),
                ),
                const SizedBox(width: 8),
                Text(
                  'Состояние: ${inspection.condition}/5',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: Color.fromARGB(255, 2, 155, 124)
                    )
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1),
                  child: Text(' •', style: TextStyle(color: Color.fromARGB(114, 0, 0, 0)),),
                ),
                const SizedBox(width: 8),
                Text('$confidencePercent%', style: TextStyle(color: const Color.fromARGB(114, 0, 0, 0)),),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        onTap: onTap
      ),
    );
  }
}
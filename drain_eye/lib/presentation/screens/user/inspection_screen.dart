import 'package:flutter/material.dart';
import 'package:drain_eye/domain/entities/inspection.dart'; // импортируйте вашу модель

class InspectionScreen extends StatelessWidget {
  final Inspection inspection;

  const InspectionScreen({super.key, required this.inspection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Инспекция #${inspection.id}'),
      ),
      body: Center(
        child: 
        Text("Экран инспекции (заглушка)",
          style: TextStyle(fontSize: 18),
        ),
      )
    );
  }
}
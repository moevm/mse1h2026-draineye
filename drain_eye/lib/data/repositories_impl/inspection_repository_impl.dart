import 'package:drain_eye/domain/repositories/inspection_repository.dart';
import 'package:drain_eye/domain/entities/inspection.dart';
import 'package:flutter/foundation.dart';

// реализация репозитория из domain-слоя (заглушка с синтетическими данными)
class InspectionRepositoryImpl implements InspectionRepository {
  @override
  Stream<List<Inspection>> getUserInspections(int userId) {
    List<Inspection> insp = [
      Inspection(
        id: 1,
        userId: 1,
        timestamp: DateTime(2026, 2, 23, 14, 32),
        photoUrl: "no",
        material: 'Бетон',
        confidence: 0.92,
        condition: 4,
        defects: List.empty(),
        synchronized: true,
        address: 'ул. Ленина, 15 — колодец #3',
      ),
      Inspection(
        id: 2,
        userId: 1,
        timestamp: DateTime(2026, 2, 22, 10, 15),
        photoUrl: "no",
        material: 'Пластик',
        confidence: 0.67,
        condition: 3,
        defects: List.empty(),
        synchronized: true,
        address: 'пр. Мира, 8 — труба D500',
      ),
      Inspection(
        id: 3,
        userId: 1,
        timestamp: DateTime(2026, 2, 21, 16, 48),
        photoUrl: "no",
        material: 'Металл',
        confidence: 0.45,
        condition: 1,
        defects: List.empty(),
        synchronized: true,
        address: 'ул. Садовая, 22 — коллектор',
      ),
      Inspection(
        id: 4,
        userId: 1,
        timestamp: DateTime(2026, 2, 20, 9, 3),
        photoUrl: "no",
        material: 'Бетон',
        confidence: 0.98,
        condition: 5,
        defects: List.empty(),
        synchronized: true,
        address: 'ул. Пушкина, 4 — дренаж',
      ),
    ];
    Stream<List<Inspection>> result = Stream.value(insp);
    if (kDebugMode) {
      print('>>> Returning ${insp.length} inspections from repo');
    }
    return result;
  }
}
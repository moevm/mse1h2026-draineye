// сущность инспекции
class Inspection {
  final int id;
  final int userId;
  final DateTime timestamp;
  final String photoUrl;    
  final String material;  
  final double confidence;    
  final int condition;  
  final List<String> defects;
  final bool synchronized;           
  final String address;
  /// Код типа повреждения из model_verdict (corrosion / crack / no_damage).
  final String? damageTypeCode;
  /// Степень повреждения из model_verdict (если есть).
  final double? damageDegree;

  Inspection({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.photoUrl,
    required this.material,
    required this.confidence,
    required this.condition,
    required this.defects,
    required this.synchronized,
    required this.address,
    this.damageTypeCode,
    this.damageDegree,
  });

  // отображение состояния в UI
  String get conditionLabel => '$condition/5';

  // отображение уверенности в процентах
  int get confidencePercent => (confidence * 100).round();
}
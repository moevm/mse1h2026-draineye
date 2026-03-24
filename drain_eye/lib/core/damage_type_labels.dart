// русские подписи кода damage_type для UI (в API остаётся snake_case / англ.)
String damageTypeLabelRu(String? code) {
  if (code == null || code.isEmpty) return '?';
  switch (code) {
    case 'corrosion':
      return 'Коррозия';
    case 'crack':
      return 'Трещина';
    case 'no_damage':
      return 'Повреждений нет';
    default:
      return 'Неизвестно';
  }
}

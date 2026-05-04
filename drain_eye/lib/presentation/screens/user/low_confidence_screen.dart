import 'package:drain_eye/core/damage_type_labels.dart';
import 'package:drain_eye/domain/entities/model_inference_result.dart';
import 'package:flutter/material.dart';

const _teal = Color(0xFF0D9488);
const _gray400 = Color(0xFF94A3B8);
const _gray500 = Color(0xFF64748B);
const _orange = Color(0xFFF59E0B);

enum LowConfidenceAction {
  retakePhoto,
  manualReview,
}

class LowConfidenceDecision {
  final LowConfidenceAction action;
  final ModelInferenceResult? correctedResult;

  const LowConfidenceDecision({
    required this.action,
    this.correctedResult,
  });
}

/// Экран низкой уверенности модели (UC-9) — предупреждение + выбор действия.
class LowConfidenceScreen extends StatefulWidget {
  final ModelInferenceResult result;

  const LowConfidenceScreen({
    super.key,
    required this.result,
  });

  @override
  State<LowConfidenceScreen> createState() => _LowConfidenceScreenState();
}

class _LowConfidenceScreenState extends State<LowConfidenceScreen> {
  final _manualFormKey = GlobalKey<FormState>();
  late final TextEditingController _stateController;
  late final TextEditingController _damageDegreeController;

  int _selectedOption = 0;
  late String _selectedDamageType;

  final _options = [
    'Переснять фото',
    'Проверить вручную',
  ];

  final _damageTypes = const [
    'no_damage',
    'corrosion',
    'crack',
  ];

  @override
  void initState() {
    super.initState();
    _stateController = TextEditingController(
      text: (widget.result.state ?? 1).toString(),
    );
    _damageDegreeController = TextEditingController(
      text: (widget.result.damageDegree ?? 1.0).toStringAsFixed(2),
    );
    _selectedDamageType = _damageTypes.contains(widget.result.damageType)
        ? widget.result.damageType
        : 'no_damage';
  }

  @override
  void dispose() {
    _stateController.dispose();
    _damageDegreeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        title: const Text('Результат'),
        titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // фото
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.camera_alt, color: _gray400, size: 32),
            ),
            const SizedBox(height: 14),

            // карточка результата (оранжевая граница)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: const Border(left: BorderSide(color: _orange, width: 4)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Результат анализа', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _orange)),
                  const SizedBox(height: 10),
                  _row('Материал', widget.result.material ?? '?'),
                  _row('Состояние', '${widget.result.state ?? '?'} / 5', badge: true),
                  _row('Тип повреждения', damageTypeLabelRu(widget.result.damageType)),
                  _row('Уверенность', '${(widget.result.accuracyModel * 100).toStringAsFixed(1)}%', valueColor: _orange),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // предупреждение
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('! Низкая уверенность', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _orange)),
                  SizedBox(height: 4),
                  Text('Выберите действие:', style: TextStyle(fontSize: 13, color: _gray500)),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // варианты действий (radio)
            ...List.generate(_options.length, (i) {
              final selected = _selectedOption == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedOption = i),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? _teal.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? _teal : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: selected ? _teal : _gray400, width: 2),
                        ),
                        child: selected
                            ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: _teal)))
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Text(_options[i], style: TextStyle(fontSize: 14, color: selected ? _teal : const Color(0xFF0F172A))),
                    ],
                  ),
                ),
              );
            }),
            if (_selectedOption == 1) ...[
              const SizedBox(height: 8),
              Form(
                key: _manualFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _manualLabel('Состояние (1-5)'),
                    _manualNumberField(
                      controller: _stateController,
                      hintText: 'Например, 3',
                      validator: (value) => _validateNumber(
                        value,
                        min: 1,
                        max: 5,
                        integerOnly: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _manualLabel('Тип повреждения'),
                    _damageTypeDropdown(),
                    const SizedBox(height: 10),
                    _manualLabel('Степень повреждения (1-5)'),
                    _manualNumberField(
                      controller: _damageDegreeController,
                      hintText: 'Например, 3.50',
                      validator: (value) => _validateNumber(
                        value,
                        min: 1,
                        max: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),

            // кнопки OK / Отмена
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final action = LowConfidenceAction.values[_selectedOption];
                        if (action == LowConfidenceAction.manualReview &&
                            !_manualFormKey.currentState!.validate()) {
                          return;
                        }
                        Navigator.pop(
                          context,
                          LowConfidenceDecision(
                            action: action,
                            correctedResult: action == LowConfidenceAction.manualReview
                                ? _correctedResult()
                                : null,
                          ),
                        );
                      },
                      child: const Text('OK', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _gray500,
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Отмена', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool badge = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: _gray500)),
          badge
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: _orange.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _orange)),
                )
              : Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: valueColor ?? const Color(0xFF0F172A))),
        ],
      ),
    );
  }

  ModelInferenceResult _correctedResult() {
    final state = int.parse(_stateController.text.trim());
    final damageDegree = double.parse(_damageDegreeController.text.trim());
    return widget.result.copyWith(
      state: state,
      damageType: _selectedDamageType,
      damageDegree: double.parse(damageDegree.toStringAsFixed(2)),
      comments: 'Низкая уверенность модели: результат скорректирован вручную.',
    );
  }

  Widget _manualLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _manualNumberField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: _gray400, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _teal, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }

  Widget _damageTypeDropdown() {
    return Container(
      width: double.infinity,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDamageType,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: _gray400),
          style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
          items: _damageTypes
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(damageTypeLabelRu(type)),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedDamageType = value);
            }
          },
        ),
      ),
    );
  }

  String? _validateNumber(
    String? value, {
    required double min,
    required double max,
    bool integerOnly = false,
  }) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return 'введите значение';
    final parsed = double.tryParse(text.replaceAll(',', '.'));
    if (parsed == null) return 'введите число';
    if (integerOnly && parsed % 1 != 0) return 'введите целое число';
    if (parsed < min || parsed > max) {
      return 'значение должно быть от ${min.toStringAsFixed(0)} до ${max.toStringAsFixed(0)}';
    }
    return null;
  }
}

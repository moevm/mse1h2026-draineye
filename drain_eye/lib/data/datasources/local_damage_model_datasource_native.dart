import 'dart:io';
import 'dart:typed_data';

import 'package:drain_eye/domain/entities/model_inference_result.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

// локальный tflite: resize до 640x640, вход uint8 [1,640,640,3] без нормализации
class LocalDamageModelDataSource {
  static const String _assetPath = 'assets/model.tflite';
  static const int _inputSize = 640;
  static const int _outputDetections = 300;
  static const int _outputValues = 6;
  static const double _confidenceThreshold = 0.25;
  static const List<String> kDamageTypeByClass = [
    'corrosion',
    'crack',
    'no_damage',
  ];

  Interpreter? _interpreter;

  static String _basename(String path) {
    final i = path.lastIndexOf('/');
    final j = path.lastIndexOf(r'\');
    final k = i > j ? i : j;
    return k < 0 ? path : path.substring(k + 1);
  }

  Future<Interpreter> _getInterpreter() async {
    if (_interpreter != null) return _interpreter!;
    _interpreter = await Interpreter.fromAsset(_assetPath);
    _interpreter!.resizeInputTensor(0, [1, _inputSize, _inputSize, 3]);
    _interpreter!.allocateTensors();
    return _interpreter!;
  }

  Future<_SingleImageDetectionResult> _runSingle(String path) async {
    final interpreter = await _getInterpreter();
    final bytes = await File(path).readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw FormatException('не удалось декодировать изображение: $path');
    }
    final resized = img.copyResize(
      image,
      width: _inputSize,
      height: _inputSize,
      interpolation: img.Interpolation.linear,
    );
    final inputTensor = interpreter.getInputTensor(0);
    final inputBuffer = Uint8List(_inputSize * _inputSize * 3);
    var idx = 0;
    for (var y = 0; y < _inputSize; y++) {
      for (var x = 0; x < _inputSize; x++) {
        final p = resized.getPixel(x, y);
        inputBuffer[idx++] = p.r.toInt().clamp(0, 255);
        inputBuffer[idx++] = p.g.toInt().clamp(0, 255);
        inputBuffer[idx++] = p.b.toInt().clamp(0, 255);
      }
    }
    inputTensor.data = inputBuffer;
    interpreter.invoke();
    final outTensor = interpreter.getOutputTensor(0);
    final outBytes = outTensor.data;
    final outFloat = Float32List.view(
      outBytes.buffer,
      outBytes.offsetInBytes,
      outBytes.lengthInBytes ~/ 4,
    );
    if (outFloat.length < _outputDetections * _outputValues) {
      throw StateError(
        'ожидался выход [1,$_outputDetections,$_outputValues], получено ${outFloat.length} float',
      );
    }

    final detections = _parseDetections(outFloat);
    final scores = _scoresByClass(detections);
    final damageAreas = _damageAreasByClass(detections);
    if (kDebugMode) {
      debugPrint(
        '[DamageModel] ${_basename(path)} (${image.width}×${image.height} -> ${_inputSize}×$_inputSize): '
        'detections=${detections.length}, '
        'corrosion=${scores[0].toStringAsFixed(4)}, '
        'crack=${scores[1].toStringAsFixed(4)}, '
        'corrosion_area=${damageAreas[0].toStringAsFixed(4)}, '
        'crack_area=${damageAreas[1].toStringAsFixed(4)}',
      );
    }
    return _SingleImageDetectionResult(
      detections: detections,
      scoresByClass: scores,
      damageAreasByClass: damageAreas,
    );
  }

  List<ModelDetection> _parseDetections(Float32List output) {
    final detections = <ModelDetection>[];
    for (var i = 0; i < _outputDetections; i++) {
      final offset = i * _outputValues;
      final confidence = output[offset + 4].clamp(0.0, 1.0);
      final classId = output[offset + 5].round();
      if (confidence <= _confidenceThreshold || classId < 0 || classId > 1) {
        continue;
      }

      final x1 = output[offset].clamp(0.0, 1.0);
      final y1 = output[offset + 1].clamp(0.0, 1.0);
      final x2 = output[offset + 2].clamp(0.0, 1.0);
      final y2 = output[offset + 3].clamp(0.0, 1.0);
      if (x2 <= x1 || y2 <= y1) continue;

      detections.add(
        ModelDetection(
          x1: x1,
          y1: y1,
          x2: x2,
          y2: y2,
          confidence: confidence,
          classId: classId,
        ),
      );
    }
    return detections;
  }

  List<double> _scoresByClass(List<ModelDetection> detections) {
    final scores = List<double>.filled(2, 0);
    for (final detection in detections) {
      final classId = detection.classId;
      if (detection.confidence > scores[classId]) {
        scores[classId] = detection.confidence;
      }
    }
    return scores;
  }

  List<double> _damageAreasByClass(List<ModelDetection> detections) {
    final areas = List<double>.filled(2, 0);
    for (final detection in detections) {
      areas[detection.classId] += detection.areaFraction;
    }
    return areas;
  }

  double _scoreByArea(double areaFraction) {
    if (areaFraction <= 0) return 1;
    if (areaFraction < 0.05) return 2;
    if (areaFraction < 0.15) return 3;
    if (areaFraction <= 0.30) return 4;
    return 5;
  }

  Future<ModelInferenceResult> runAverageProbabilities(List<String> photoPaths) async {
    if (photoPaths.isEmpty) {
      throw ArgumentError('photoPaths пуст');
    }
    final scoreSum = List<double>.filled(2, 0);
    final areaSumByClass = List<double>.filled(2, 0);
    final allDetections = <ModelDetection>[];
    for (final p in photoPaths) {
      final result = await _runSingle(p);
      allDetections.addAll(result.detections);
      for (var i = 0; i < 2; i++) {
        areaSumByClass[i] += result.damageAreasByClass[i];
      }
      for (var i = 0; i < 2; i++) {
        scoreSum[i] += result.scoresByClass[i];
      }
    }
    final n = photoPaths.length.toDouble();
    for (var i = 0; i < 2; i++) {
      scoreSum[i] /= n;
      areaSumByClass[i] /= n;
    }
    final hasDamage = allDetections.isNotEmpty;
    final corrosionDamageScore = _scoreByArea(areaSumByClass[0]);
    final crackDamageScore = _scoreByArea(areaSumByClass[1]);
    final maxDamageScore = corrosionDamageScore > crackDamageScore
        ? corrosionDamageScore
        : crackDamageScore;
    final averageDamageScore = (corrosionDamageScore + crackDamageScore) / 2;
    final finalDamageScore = _round2(
      0.7 * maxDamageScore + 0.3 * averageDamageScore,
    );
    var best = 0;
    if (scoreSum[1] > scoreSum[0]) {
      best = 1;
    }
    final damageType = hasDamage ? kDamageTypeByClass[best] : 'no_damage';
    final accuracy = hasDamage ? scoreSum[best] : 1.0;
    if (kDebugMode) {
      debugPrint(
        '[DamageModel] среднее по ${photoPaths.length} фото: '
        'detections=${allDetections.length}, '
        'corrosion=${scoreSum[0].toStringAsFixed(4)}, '
        'crack=${scoreSum[1].toStringAsFixed(4)} → '
        'класс=$damageType, '
        'accuracy_model=${accuracy.toStringAsFixed(4)}, '
        'corrosion_area=${areaSumByClass[0].toStringAsFixed(4)}, '
        'crack_area=${areaSumByClass[1].toStringAsFixed(4)}, '
        'damage_score=${finalDamageScore.toStringAsFixed(2)}',
      );
    }
    return ModelInferenceResult(
      material: null,
      state: hasDamage ? finalDamageScore.round().clamp(1, 5) : 1,
      damageType: damageType,
      damageDegree: hasDamage ? finalDamageScore : 1.0,
      accuracyModel: accuracy,
      comments: null,
      detections: allDetections,
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }

  double _round2(double value) => double.parse(value.toStringAsFixed(2));
}

class _SingleImageDetectionResult {
  final List<ModelDetection> detections;
  final List<double> scoresByClass;
  final List<double> damageAreasByClass;

  const _SingleImageDetectionResult({
    required this.detections,
    required this.scoresByClass,
    required this.damageAreasByClass,
  });
}

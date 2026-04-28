import 'dart:io';
import 'dart:typed_data';

import 'package:drain_eye/domain/entities/model_inference_result.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

// локальный tflite: без ручной нормализации; вход [1,H,W,3] float под размер декодированного JPEG
class LocalDamageModelDataSource {
  static const String _assetPath = 'assets/model.tflite';
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
    _interpreter!.allocateTensors();
    return _interpreter!;
  }

  Future<List<double>> _runSingle(String path) async {
    final interpreter = await _getInterpreter();
    final bytes = await File(path).readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw FormatException('не удалось декодировать изображение: $path');
    }
    final h = image.height;
    final w = image.width;
    interpreter.resizeInputTensor(0, [1, h, w, 3]);
    interpreter.allocateTensors();
    final inputTensor = interpreter.getInputTensor(0);
    final floatBuffer = Float32List(h * w * 3);
    var idx = 0;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final p = image.getPixel(x, y);
        floatBuffer[idx++] = p.r.toDouble();
        floatBuffer[idx++] = p.g.toDouble();
        floatBuffer[idx++] = p.b.toDouble();
      }
    }
    inputTensor.data = Uint8List.view(
      floatBuffer.buffer,
      floatBuffer.offsetInBytes,
      floatBuffer.lengthInBytes,
    );
    interpreter.invoke();
    final outTensor = interpreter.getOutputTensor(0);
    final outBytes = outTensor.data;
    final outFloat = Float32List.view(
      outBytes.buffer,
      outBytes.offsetInBytes,
      outBytes.lengthInBytes ~/ 4,
    );
    final probs = [outFloat[0], outFloat[1], outFloat[2]];
    if (kDebugMode) {
      debugPrint(
        '[DamageModel] ${_basename(path)} (${w}×$h): '
        'corrosion=${probs[0].toStringAsFixed(4)}, '
        'crack=${probs[1].toStringAsFixed(4)}, '
        'no_damage=${probs[2].toStringAsFixed(4)}',
      );
    }
    return probs;
  }

  Future<ModelInferenceResult> runAverageProbabilities(List<String> photoPaths) async {
    if (photoPaths.isEmpty) {
      throw ArgumentError('photoPaths пуст');
    }
    final sum = List<double>.filled(3, 0);
    for (final p in photoPaths) {
      final v = await _runSingle(p);
      for (var i = 0; i < 3; i++) {
        sum[i] += v[i];
      }
    }
    final n = photoPaths.length.toDouble();
    for (var i = 0; i < 3; i++) {
      sum[i] /= n;
    }
    var best = 0;
    for (var i = 1; i < 3; i++) {
      if (sum[i] > sum[best]) best = i;
    }
    if (kDebugMode) {
      debugPrint(
        '[DamageModel] среднее по ${photoPaths.length} фото: '
        'corrosion=${sum[0].toStringAsFixed(4)}, '
        'crack=${sum[1].toStringAsFixed(4)}, '
        'no_damage=${sum[2].toStringAsFixed(4)} → '
        'класс=${kDamageTypeByClass[best]}, '
        'accuracy_model=${sum[best].toStringAsFixed(4)}',
      );
    }
    return ModelInferenceResult(
      material: null,
      state: null,
      damageType: kDamageTypeByClass[best],
      damageDegree: null,
      accuracyModel: sum[best],
      comments: null,
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}

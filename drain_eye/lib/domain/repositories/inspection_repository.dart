import 'package:drain_eye/domain/entities/inspection.dart';
import 'package:drain_eye/domain/entities/model_inference_result.dart';

// абстрактный класс репозитория для работы с инспекциями
// определяет контракт, который должны реализовать конкретные источники данных
abstract class InspectionRepository {
  Stream<List<Inspection>> getUserInspections(int userId);

  // локальный tflite: усреднение вероятностей по списку путей к фото
  Future<ModelInferenceResult> runDamageModel(List<String> photoPaths);

  // отправка новой инспекции на сервер (JSON + изображения в base64)
  Future<void> createInspection({
    required int userId,
    required List<String> photoPaths,
    required ModelInferenceResult modelResult,
  });
}

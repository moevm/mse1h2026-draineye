# DrainEye — Обучение модели

Ноутбук с реализацией, обучением и анализом CNN-модели для классификации дефектов дренажных систем.

## Структура

| Файл | Содержимое |
|---|---|
| `draineye_model.ipynb` | Ноутбук: загрузка датасета, EDA, подготовка `tf.data` pipeline, baseline, обучение модели, оценка качества и конвертация в TFLite |

---

## Модель

**Архитектура:** MobileNetV2 (Transfer Learning)  
**Классы:** `corrosion` / `crack` / `no_damage`  
**Датасет:** [`draineye/draineye-defects`](https://huggingface.co/datasets/draineye/draineye-defects)

---

## Запуск

### Переменные окружения

| Переменная | Подробнее | Зачем |
|---|---|---|
| `HF_TOKEN` | [HuggingFace PAT](https://huggingface.co/docs/hub/security-tokens) | доступ к датасету |

### Google Colab

1. Открыть Colab и загрузить `draineye_model.ipynb`
2. Выбрать runtime с GPU
3. (опционально) добавить `HF_TOKEN`
4. Запускать ячейки последовательно

# DrainEye — Выбор архитектуры модели

Ноутбук для первичной реализации и проверки архитектуры модели классификации дефектов дренажных систем.

## Структура

| Файл | Содержимое |
|---|---|
| `draineye_model.ipynb` | Ноутбук: загрузка датасета, базовый EDA, подготовка `tf.data` pipeline, baseline и проверка выбранной архитектуры |

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

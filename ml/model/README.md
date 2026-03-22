# DrainEye — Обучение модели

Обучение CNN для классификации дефектов дренажных систем на базе MobileNetV2 (Transfer Learning).

## Структура

| Файл | Содержимое |
|---|---|
| `draineye_model.ipynb` | Ноутбук: загрузка датасета, EDA, подготовка tf.data pipeline, случайный классификатор (baseline) |

---

## Модель

**Архитектура:** MobileNetV2 (Transfer Learning)  
**Классы:** `corrosion` / `crack` / `no_damage`  
**Датасет:** [`draineye/draineye-defects`](https://huggingface.co/datasets/draineye/draineye-defects) — 1500 фото, split 70/15/15

---

## Запуск

### Переменные окружения

| Переменная | Подробнее | Зачем |
|---|---|---|
| `HF_TOKEN` | [HuggingFace PAT](https://huggingface.co/docs/hub/security-tokens) | Ускоряет скачивание датасета (необязательно) |

### Открыть в Google Colab

1. Открыть [Google Colab](https://colab.research.google.com) и загрузить `draineye_model.ipynb` через **File --> Upload notebook**
2. Выбрать runtime: **Runtime --> Change runtime type --> T4 GPU**
3. Добавить секрет `HF_TOKEN`: панель слева --> **Secrets --> Add new secret**
4. Запускать ячейки последовательно — порядок важен

# DrainEye — Обучение модели

Ноутбуки и скрипты для обучения и экспорта моделей детекции дефектов дренажных труб.

## Структура

| Файл | Содержимое |
|---|---|
| `src/` | Директория с исходным кодом обучения |
| `models/` | Директория для сохранения моделей |
| `data/` | Директория, соответствующая датасету с Roboflow |
| `notebook/draineye-classification.ipynb` | Классификатор MobileNetV2 (итерация 2) |
| `notebook/draineye-model-detection.ipynb` | Детектор YOLOv8s (итерация 3) |
| `config.py` | Параметры обучения и экспорта |
| `train.py` | Скрипт обучения YOLOv8s |
| `export.py` | Экспорт в TFLite с встроенным препроцессингом |
| `requirements.txt` | Зависимости |
| `Dockerfile` | Docker образ |
| `docker-compose.yml` | Запуск обучения и экспорта через Docker |

---

## Модели

### Детектор (итерация 3, актуальная)
**Архитектура:** YOLOv8s (Transfer Learning)  
**Классы:** `corrosion` / `crack`  
**Датасет:** [`draineye/draineye-defects`](https://universe.roboflow.com/draineye/draineye-defects)

**Формат TFLite модели:**
- Вход: `[1, 640, 640, 3]`, dtype: `uint8` (нормализация встроена)
- Выход: `[1, 300, 6]`, dtype: `float32`, формат `[x1, y1, x2, y2, conf, class_id]`
- Координаты нормализованы [0, 1], NMS встроен

### Классификатор (итерация 2)
**Архитектура:** MobileNetV2 (Transfer Learning)  
**Классы:** `corrosion` / `crack` / `no_damage`  
**Датасет:** [`draineye/draineye-defects`](https://huggingface.co/datasets/draineye/draineye-defects)

---

## Запуск

### Переменные окружения

Перед запуском необходимо скопировать `.env.template`.
```bash
cp .env.template .env
```

| Переменная | Содержимое |
|---|---|
| `ROBOFLOW_API_KEY` | API-ключ с Roboflow для загрузки датасета |

### Docker Compose

Ссылка на обученную модель: https://drive.google.com/file/d/1gCWwMfv6LOSAUnKyfLkuQTKPHdTMAEZm/view?usp=sharing  
> Необходимо разархивировать в `models/`

```bash
# Сборка проекта
docker compose build

# Обучение
docker compose run train

# Прогноз
docker compose run predict

# Экспорт в TFLite
docker compose run export
```

### Google Colab

Ссылка на Colab: https://colab.research.google.com/drive/1VMwgjrRUfdmS27xBG9gaX8CKPJJD70HO?usp=sharing

> Перед запуском **необходимо** установить `ROBOFLOW_API_KEY` в секреты Colab.

---

## Результаты (итерация 3)

| Класс | mAP50 | Precision | Recall |
|---|---|---|---|
| corrosion | 0.508 | 0.862 | 0.431 |
| crack | 0.442 | 0.558 | 0.456 |
| **all** | **0.475** | **0.710** | **0.443** |

**Наблюдения:**
- Модель корректно классифицирует найденные дефекты — путаницы между corrosion и crack нет
- Основная проблема — низкий recall: модель пропускает часть дефектов
- val/box_loss растёт с ~эпохи 10 — переобучение на локализации, техдолг итерации 4
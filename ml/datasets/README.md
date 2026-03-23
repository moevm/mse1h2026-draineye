# DrainEye — Датасеты для обучения ML-моделей

---

## 1. Классификация дефектов (corrosion / crack / no_damage)

Собран из 5 публичных Kaggle-датасетов, сбалансирован по 500 изображений на класс, разбит на train/val/test.

---

## Источники

### Коррозия (`corrosion`)
| Датасет | Что взяли |
|---|---|
| [pipeline-corrosion-dataset](https://www.kaggle.com/datasets/aditya068/pipeline-corrosion-dataset) | папка `Corroded/` — коррозия морских трубопроводов (121) |
| [corrosion-detection](https://www.kaggle.com/datasets/bsurya27/corrosion-detection) | папка `images/` — только фото, без YOLO-разметки (129) |
| [corrosion-detect-dataset](https://www.kaggle.com/datasets/wednesday233/corrosion-detect-dataset) | папка `images/` — только фото, без YOLO-разметки (268) |

### Трещины (`crack`)
| Датасет | Что взяли |
|---|---|
| [surface-crack-detection](https://www.kaggle.com/datasets/arunrk7/surface-crack-detection) | папка `Positive/` — трещины на бетоне (20 000) |
| [concrete-and-pavement-crack-images](https://www.kaggle.com/datasets/oluwaseunad/concrete-and-pavement-crack-images) | папка `Positive/` — трещины на дорожном покрытии (15 000) |

### Норма (`no_damage`)
Только датасеты без YOLO-разметки — папки `Negative/` и `Normal/`:

| Датасет | Что взяли |
|---|---|
| [surface-crack-detection](https://www.kaggle.com/datasets/arunrk7/surface-crack-detection) | папка `Negative/` — чистый бетон (20 000) |
| [concrete-and-pavement-crack-images](https://www.kaggle.com/datasets/oluwaseunad/concrete-and-pavement-crack-images) | папка `Negative/` — чистое дорожное покрытие (15 000) |
| [pipeline-corrosion-dataset](https://www.kaggle.com/datasets/aditya068/pipeline-corrosion-dataset) | папка `Normal/` — чистые трубопроводы (120) |

---

## Итоговая структура

Балансировка: из каждого класса случайно выбирается 500 фото (`random.seed=42`), остальное отбрасывается. Для коррозии доступно всего 518 фото — вошли почти все; для трещин и нормы выборка из 35 000+.

```
draineye_defects/
├── train/
│   ├── corrosion/   [350 фото]
│   ├── crack/       [350 фото]
│   └── no_damage/   [350 фото]
├── val/
│   ├── corrosion/   [75 фото]
│   ├── crack/       [75 фото]
│   └── no_damage/   [75 фото]
└── test/
    ├── corrosion/   [75 фото]
    ├── crack/       [75 фото]
    └── no_damage/   [75 фото]
```

| Сплит | Фото | Доля |
|---|---|---|
| train | 1050 | 70% |
| val | 225 | 15% |
| test | 225 | 15% |
| **Итого** | **1500** | |

---

## Файлы

- Датасет: [`draineye_defects`](https://github.com/mse1h2026-draineye/tree/main/ml/datasets/draineye_defects) — готовый датасет, можно скачать сразу
- Ноутбук: [`notebooks/DrainEye_Defects_Dataset.ipynb`](https://github.com/mse1h2026-draineye/blob/main/ml/datasets/notebooks/DrainEye_Defects_Dataset.ipynb) — для повторной сборки или экспериментов

---

## Как собрать датасет

### Требования
Аккаунт Kaggle и файл `kaggle.json` (API-токен).  
Получить токен: kaggle.com → Settings → API → **Create Legacy API Key** → скачается `kaggle.json`.

### Запуск

1. Открыть [Google Colab](https://colab.research.google.com) и загрузить `notebooks/DrainEye_Defects_Dataset.ipynb` через **File → Upload notebook**
2. Запускать ячейки последовательно:
   - **Шаг 1** — загрузит `kaggle.json` через диалог выбора файла
   - **Шаг 2** — скачает 5 датасетов (~700 МБ, ~2–3 мин)
   - **Шаг 3** — выведет структуру скачанных папок
   - **Шаг 4** — соберёт и сбалансирует датасет (500 фото на класс, split 70/15/15)
   - **Шаг 5** — покажет по одному примеру из каждого класса и сплита
   - **Шаг 6** — создаст `draineye_defects.zip` и скачает его
# DrainEye — ML

Датасеты для обучения модели.

> Готового датасета под 7 материалов не существует.

---

## Датасеты

### Трещины

| Ключ | Датасет | Чем поможет |
|---|---|---|
| `cracks` | [Surface Crack Detection](https://www.kaggle.com/datasets/arunrk7/surface-crack-detection) | Основа для обучения детектора трещин |
| `cracks_concrete` | [Concrete Crack Classification](https://www.kaggle.com/datasets/imtkaggleteam/concrete-crack-classification) | Дополнительные снимки бетонных трещин, разнообразие условий съёмки |
| `cracks_pavement` | [Concrete and Pavement Crack Images](https://www.kaggle.com/datasets/oluwaseunad/concrete-and-pavement-crack-images) | Трещины на дорожном покрытии — близкая к дренажу текстура |

### Коррозия

| Ключ | Датасет | Чем поможет |
|---|---|---|
| `corrosion` | [Corrosion Detection](https://www.kaggle.com/datasets/bsurya27/corrosion-detection) | Включает трубопроводы и конструкции |
| `pipe_corrosion` | [Pipeline Corrosion Dataset](https://www.kaggle.com/datasets/aditya068/pipeline-corrosion-dataset) | Коррозия именно на трубах |

### Дефекты труб

| Ключ | Датасет | Чем поможет |
|---|---|---|
| `pipe_defects` | [Welded Pipe Surface Defect](https://www.kaggle.com/datasets/wentinghou/welded-pipe-surface-defect-data-set) | Царапины, поры, трещины на металлических трубах |
| `pipeline_defects` | [Pipeline Defect Dataset](https://www.kaggle.com/datasets/simplexitypipeline/pipeline-defect-dataset) | Дефекты трубопроводов со съёмки роботом — условия близки к полевой инспекции |

### Материалы

| Ключ | Датасет | Чем поможет |
|---|---|---|
| `plastic_types` | [Visual Plastic Type Recognition](https://www.kaggle.com/datasets/harshitkandoi7850/dataset-for-visual-plastic-type-recognition) | Классификация типов пластика по фото — основа для распознавания ПНД и геокомпозита |

Дополнительно: [Sewer Defects](https://universe.roboflow.com/sewage-defect-detection-s68df/sewer-defects-u8zwz) — дефекты канализационных труб.

---

## Зависимости

```
kaggle>=1.6.0
```

---

## Установка через Docker

Скопировать `.env-example` в `.env` и заполнить:

```
KAGGLE_USERNAME=your_username
KAGGLE_KEY=your_key
```

Токен можно получить на [kaggle.com](https://www.kaggle.com).

Запустить скачивание:

```bash
docker compose run --rm download
```

Датасеты сохранятся в папку `data/`.

---

## Установка без Docker

```bash
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt
python download_datasets.py
```

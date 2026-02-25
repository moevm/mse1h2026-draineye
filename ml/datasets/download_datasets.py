from pathlib import Path
from dotenv import load_dotenv

import kaggle

from huggingface_hub import snapshot_download  # 1. Добавлен импорт
from roboflow import Roboflow

load_dotenv()
DATA_DIR = Path("data")

KAGGLE_DATASETS = {
    # дефекты: трещины
    "cracks":           "arunrk7/surface-crack-detection",
    "cracks_concrete":  "imtkaggleteam/concrete-crack-classification",
    "cracks_pavement":  "oluwaseunad/concrete-and-pavement-crack-images",

    # дефекты: коррозия
    "corrosion":        "bsurya27/corrosion-detection",
    "pipe_corrosion":   "aditya068/pipeline-corrosion-dataset",

    # дефекты: трубы
    "pipe_defects":     "wentinghou/welded-pipe-surface-defect-data-set",
    "pipeline_defects": "simplexitypipeline/pipeline-defect-dataset",

    # материалы
    "plastic_types":    "harshitkandoi7850/dataset-for-visual-plastic-type-recognition",
}

HF_DATASETS = {
    # дефекты: трубы
    "pipeline_defects":     "MMKata/Sewer_pipe_defects"
}

ROBOFLOW_DATASETS = {
    # дефекты: трещины
    "cracks_1": {
        "workspace": "objectdetection-qxiqx", "project": "detr_crack_dataset", "format": "yolov8"
        },
    "cracks_2": {
        "workspace": "sayali-hkjtm", "project": "crcak", "format": "yolov8"
    },
    # дефекты: трубы
    "pipeline_defects": {
        "workspace": "computervision-naujm", "project": "pipe-defects-howis", "format": "yolov8"
    }
}


def download_kaggle():
    """Скачивает все датасеты из KAGGLE_DATASETS в DATA_DIR/<folder>."""
    for folder, kaggle_id in KAGGLE_DATASETS.items():
        out_dir = DATA_DIR / folder
        out_dir.mkdir(parents=True, exist_ok=True)

        print(f"[kaggle] {kaggle_id}")
        kaggle.api.dataset_download_files(
            kaggle_id, path=out_dir, unzip=True, quiet=False)


def download_huggingface():
    """Скачивает все датасеты из HF_DATASETS в DATA_DIR/<folder>."""
    for folder, repo_id in HF_DATASETS.items():
        out_dir = DATA_DIR / folder
        out_dir.mkdir(parents=True, exist_ok=True)

        print(f"[huggingface] {repo_id}")
        try:
            snapshot_download(
                repo_id=repo_id,
                repo_type="dataset",
                local_dir=out_dir,
                local_dir_use_symlinks=False,
            )
            print(f"Скачано в {out_dir}")
        except Exception as e:
            print(f"Ошибка при скачивании {repo_id}: {e}")


def download_roboflow():
    """Скачивает все датасеты из ROBOFLOW_DATASETS в DATA_DIR/<folder>."""
    for folder, config in ROBOFLOW_DATASETS.items():
        out_dir = DATA_DIR / folder
        out_dir.mkdir(parents=True, exist_ok=True)

        workspace = config["workspace"]
        project = config["project"]
        version = config.get("version", 1)
        fmt = config.get("format", "yolov8")

        print(f"[roboflow] {workspace}/{project} v{version} ({fmt})")
        try:
            project_obj = Roboflow().workspace(workspace).project(project)
            dataset = project_obj.version(version).download(
                model_format=fmt,
                location=str(out_dir),
                overwrite=True,
            )
            print(f"Скачано в {dataset.location}")
        except Exception as e:
            print(f"Ошибка при скачивании: {workspace}/{project}: {e}")


def download_all():
    """Точка входа: скачивает датасеты из всех источников."""
    DATA_DIR.mkdir(exist_ok=True)

    print("=" * 60)
    download_kaggle()

    print("-" * 60)
    download_huggingface()

    print("-" * 60)
    download_roboflow()


if __name__ == "__main__":
    download_all()

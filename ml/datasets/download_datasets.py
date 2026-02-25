from pathlib import Path

import kaggle

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
    # "folder": "organization/dataset-name",
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
    pass


def download_all():
    """Точка входа: скачивает датасеты из всех источников."""
    DATA_DIR.mkdir(exist_ok=True)

    print("=" * 60)
    download_kaggle()

    print("-" * 60)

    download_huggingface()
    print("=" * 60)


if __name__ == "__main__":
    download_all()

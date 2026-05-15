import os, argparse
os.environ["PYTHONHASHSEED"] = "42"

from ultralytics import YOLO
from config import MODEL_TYPE, IMG_SIZE, EPOCHS, SEED, COS_LR, LRF, PATIENCE
from preprocessing import download_dataset


def train(data: str, output: str, name: str) -> None:
    if not os.path.exists(data):
        download_dataset(os.path.dirname(data))

    YOLO(f"{MODEL_TYPE}.pt").train(
        data=data,
        imgsz=IMG_SIZE,
        epochs=EPOCHS,
        seed=SEED,
        cos_lr=COS_LR,
        lrf=LRF,
        patience=PATIENCE,
        project=output,
        name=name,
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--data",   required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--name",   default="model_v1")
    args = parser.parse_args()

    train(args.data, args.output, args.name)
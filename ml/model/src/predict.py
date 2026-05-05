import os, argparse
from ultralytics import YOLO
from config import IMG_SIZE, CONF_THRESH
from preprocessing import download_dataset

CLASSES = {0: "corrosion", 1: "crack"}


def predict(image: str, weights: str, data_dir: str) -> None:
    if not os.path.exists(image):
        download_dataset(data_dir)

    results = YOLO(weights).predict(image, imgsz=IMG_SIZE, conf=CONF_THRESH)

    for result in results:
        print(f"\n{result.path}")
        if len(result.boxes) == 0:
            print("Повреждений не обнаружено")
            continue

        for box in result.boxes:
            cls  = int(box.cls)
            conf = float(box.conf)
            x1, y1, x2, y2 = [round(float(v), 2) for v in box.xyxy[0]]
            print(f"{CLASSES[cls]} | conf={conf:.2f} | bbox=[{x1}, {y1}, {x2}, {y2}]")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--image",    required=True)
    parser.add_argument("--weights",  required=True)
    parser.add_argument("--data-dir", default="/data")
    args = parser.parse_args()

    predict(args.image, args.weights, args.data_dir)
import os
import argparse
import tensorflow as tf
from ultralytics import YOLO
from config import IMG_SIZE


class YOLOWithPreprocess(tf.keras.Model):
    def __init__(self, yolo):
        super().__init__()

        self.yolo = yolo
        self.resize = tf.keras.layers.Resizing(IMG_SIZE, IMG_SIZE)
        self.rescale = tf.keras.layers.Rescaling(1./255)

    def call(self, x):
        x = self.rescale(self.resize(x))
        return self.yolo.signatures["serving_default"](images=x)["output_0"]


def export(weights: str, output: str) -> None:
    model_dir = os.path.dirname(weights)

    YOLO(weights).export(format="saved_model", imgsz=IMG_SIZE, nms=True)

    yolo = tf.saved_model.load(f"{model_dir}/best_saved_model")
    model = YOLOWithPreprocess(yolo)
    
    @tf.function(input_signature=[tf.TensorSpec(shape=(1, IMG_SIZE, IMG_SIZE, 3), dtype=tf.uint8)])
    def serving(x): 
        return model(x)

    tflite = tf.lite.TFLiteConverter.from_concrete_functions(
        [serving.get_concrete_function()]
    ).convert()
    
    open(output, "wb").write(tflite)
    print(f"Сохранено: {output}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--weights", required=True)
    parser.add_argument("--output",  required=True)
    args = parser.parse_args()

    export(args.weights, args.output)
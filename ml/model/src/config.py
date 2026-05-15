WORKSPACE = "draineye"
PROJECT_NAME = "draineye-defects"
PROJECT_VERSION = 1

MODEL_ARCH = "yolov8"
MODEL_TYPE = "yolov8s"
MODEL_NAME = "model_v1"

MODEL_DIR = f"models/{MODEL_NAME}"

IMG_SIZE = 640
CONF_THRESH = 0.25
CLASSES = {0: "corrosion", 1: "crack"}

SEED = 42
EPOCHS = 120
COS_LR = True
LRF = 0.1
PATIENCE = 15

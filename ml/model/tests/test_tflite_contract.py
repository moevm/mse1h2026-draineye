import os
import numpy as np
import tensorflow as tf

# Model contract
MODEL_PATH = "/models/model_v1.tflite"
EXPECTED_INPUT_SHAPE = (1, 640, 640, 3)
EXPECTED_INPUT_DTYPE = np.uint8
EXPECTED_OUTPUT_SHAPE = (1, 300, 6)
EXPECTED_OUTPUT_DTYPE = np.float32


def _load_interpreter(model_path: str) -> tf.lite.Interpreter:
    interpreter = tf.lite.Interpreter(model_path=model_path)
    interpreter.allocate_tensors()
    return interpreter


def test_tflite_file_exists():
    assert os.path.exists(MODEL_PATH), (
        f"TFLite модель не найдена: {MODEL_PATH}. "
        f"Выполните export или поместите модель в ml/model/models/model_v1.tflite"
    )


def test_tflite_io_contract():
    itp = _load_interpreter(MODEL_PATH)

    inputs = itp.get_input_details()
    outputs = itp.get_output_details()

    assert len(inputs) == 1, f"Expected 1 input tensor but got: {len(inputs)}"
    assert len(outputs) == 1, f"Expected 1 output tensor but got: {len(outputs)}"

    in0 = inputs[0]
    out0 = outputs[0]

    # Shape / dtype
    assert tuple(in0["shape"]) == EXPECTED_INPUT_SHAPE, f"Input shape: {in0['shape']}, expected: {EXPECTED_INPUT_SHAPE}"
    assert in0["dtype"] == EXPECTED_INPUT_DTYPE, f"Input dtype: {in0['dtype']}, expected: {EXPECTED_INPUT_DTYPE}"

    assert tuple(out0["shape"]) == EXPECTED_OUTPUT_SHAPE, f"Output shape: {out0['shape']}, expected: {EXPECTED_OUTPUT_SHAPE}"
    assert out0["dtype"] == EXPECTED_OUTPUT_DTYPE, f"Output dtype: {out0['dtype']}, expected: {EXPECTED_OUTPUT_DTYPE}"


def test_tflite_inference_smoke():
    itp = _load_interpreter(MODEL_PATH)
    in0 = itp.get_input_details()[0]
    out0 = itp.get_output_details()[0]

    # Нулевой uint8 вход
    x = np.zeros(tuple(in0["shape"]), dtype=in0["dtype"])
    itp.set_tensor(in0["index"], x)
    itp.invoke()

    y = itp.get_tensor(out0["index"])

    assert y.shape == EXPECTED_OUTPUT_SHAPE, f"Output shape mismatch: {y.shape}"
    assert y.dtype == EXPECTED_OUTPUT_DTYPE, f"Output dtype mismatch: {y.dtype}"

    assert not np.isnan(y).any(), "Output contains NaN"
    assert not np.isinf(y).any(), "Output contains Inf"
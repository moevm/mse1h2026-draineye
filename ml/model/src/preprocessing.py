import os, argparse
from roboflow import Roboflow
from config import WORKSPACE, PROJECT_NAME, PROJECT_VERSION, MODEL_ARCH


def download_dataset(output: str) -> str:
    api_key = os.environ.get("ROBOFLOW_API_KEY")
    if not api_key:
        raise ValueError("ROBOFLOW_API_KEY не задан")

    rf = Roboflow(api_key=api_key)
    project = rf.workspace(WORKSPACE).project(PROJECT_NAME)
    version = project.version(PROJECT_VERSION)
    dataset = version.download(MODEL_ARCH, location=output, overwrite=True)
    return dataset.location


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    download_dataset(args.output)
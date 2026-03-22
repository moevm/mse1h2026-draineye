import cloudinary
import cloudinary.uploader
import cloudinary.api
from app.config import settings
from app.imports import List, Dict, os, datetime

class CloudinaryService:
    _instance = None
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._init_cloudinary()
        return cls._instance

    def _init_cloudinary(self):
        if not all([
            settings.CLOUDINARY_CLOUD_NAME,
            settings.CLOUDINARY_API_KEY,
            settings.CLOUDINARY_API_SECRET
        ]):
            raise ValueError("Cloudinary credentials not configured")
        cloudinary.config(
            cloud_name=settings.CLOUDINARY_CLOUD_NAME,
            api_key=settings.CLOUDINARY_API_KEY,
            api_secret=settings.CLOUDINARY_API_SECRET,
            secure=True
        )

    def upload_photo(self, file_path: str, public_id: str):
        cloudinary.uploader.upload(
            file_path,
            public_id=public_id,
            folder="inspections",
            resource_type="image",
            overwrite=False
        )

    def upload_photos(self, file_paths: List[str], engineer_id: str) -> List[Dict]:
        uploaded = []
        for file_path in file_paths:
            filename = os.path.basename(file_path)
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            public_id = f"eng_{engineer_id}/{timestamp}_{filename}"
            self.upload_photo(file_path, public_id)
            uploaded.append(public_id)
        return uploaded



import cloudinary
import cloudinary.uploader
import cloudinary.api
from server_backend.config import settings
from server_backend.imports import List, os, io, UploadFile

'''
cинглтон-сервис для управления подключением к Cloudinary и доступа к облаку
Обеспечивает единую точку входа для всех операций с Cloudinary во всем приложении
'''
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

    '''генерирует public id для доступа к фотке с сервера'''
    def generate_public_id(self, engineer_id: str, inspection_id: str, filename: str) -> str:
        folder = f"inspections/eng_{engineer_id}/insp_{inspection_id}"
        public_id = f"{folder}/{filename}"
        return public_id

    '''генерирует public id для аватарки пользователя'''
    def generate_avatar_public_id(self, engineer_id: str, filename: str) -> str:
        folder = f"avatars/{engineer_id}"
        public_id = f"{folder}/{filename}"
        return public_id

    '''генерирует public id для всех фотографий из инспекции'''
    def generate_public_ids(self, filenames: List[str], engineer_id: str, inspection_id: str) -> List[str]:
        public_ids = []
        for filename in filenames:
            public_id = self.generate_public_id(engineer_id, inspection_id, filename)
            public_ids.append(public_id)
        return public_ids

    '''загрузка фоток на облако'''
    async def upload_photos(self, files: List[UploadFile], public_ids: List[str]):
        for file, public_id in zip(files, public_ids):
            if file and file.filename:
                await self.upload_photo(file, public_id)

    '''загрузка фото на облако'''
    async def upload_photo(self, file: UploadFile, public_id: str):
        try:
            content = await file.read()
            file_stream = io.BytesIO(content)
            folder = "/".join(public_id.split("/")[:-1])
            filename = public_id.split("/")[-1]
            cloudinary.uploader.upload(
                file_stream,
                public_id=filename,
                folder=folder,
                resource_type="image",
                overwrite=False
            )
            await file.seek(0)
        except Exception as e:
            print(f"Ошибка загрузки {public_id}: {e}")
            raise

    async def upload_avatar(self, file: UploadFile, user_id: str) -> str:
        try:
            content = await file.read()
            file_stream = io.BytesIO(content)
            public_id = self.generate_avatar_public_id(user_id, file.filename)
            folder = "/".join(public_id.split("/")[:-1])
            filename = public_id.split("/")[-1]
            result = cloudinary.uploader.upload(
                file_stream,
                public_id=filename,
                folder=folder,
                resource_type="image",
                overwrite=True
            )
            await file.seek(0)
            return result.get("secure_url")
        except Exception as e:
            print(f"Ошибка загрузки аватарки для {user_id}: {e}")
            raise
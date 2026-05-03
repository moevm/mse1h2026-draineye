from server_backend.services import FirebaseService
from server_backend.services.cloudinary_service import CloudinaryService
from server_backend.imports import Optional, List, UploadFile
from server_backend.schemas import InspectionSchema
from server_backend.models import Inspection

'''общий сервис для управлением хранилищами'''
class StorageService:
    _instance = None
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._init_storage()
        return cls._instance

    def _init_storage(self):
        self._firebase = FirebaseService()
        self._cloudinary = CloudinaryService()

    '''получение инспекции по id инженера'''
    def get_inspections_by_engineer(self, engineer_id: str, limit: int = None):
        return self._firebase.get_inspections_by_engineer(engineer_id, limit)

    '''добавление инспекции'''
    def add_inspection(self, inspection) -> str:
        return self._firebase.add_inspection(inspection)

    '''регистрирует инспектора'''
    def register_inspector(self, email: str, password: str, full_name: str) -> str:
        return self._firebase.register_inspector(email, password, full_name)

    '''регистрирует администратора'''
    def register_admin(self, email: str, password: str, full_name: str) -> str:
        return self._firebase.register_admin(email, password, full_name)

    '''создает инспекцию и загружает связанные фото'''
    async def create_inspection_with_photos(
        self,
        inspection_json: str,
        files: Optional[List[UploadFile]] = None
    ) -> dict:
        inspection_schema = InspectionSchema.model_validate_json(inspection_json)
        inspection = Inspection.from_schema(inspection_schema)
        inspection_id = self.add_inspection(inspection)

        photo_urls = []
        if files and inspection_id and len(files) > 0:
            valid_files = [f for f in files if f and f.filename]
            if valid_files:
                filenames = [f.filename for f in valid_files]
                public_ids = self._cloudinary.generate_public_ids(
                    filenames=filenames,
                    engineer_id=inspection_schema.engineer_id,
                    inspection_id=inspection_id
                )

                photo_urls = await self._cloudinary.upload_photos(valid_files, public_ids)
                placeholder_urls = [pid for pid in public_ids]
                self._firebase.inspections_collection.collection.document(inspection_id).update({
                    "photos": placeholder_urls
                })

        return {
            "inspection_id": inspection_id,
            "photo_urls": photo_urls,
            "status": "created"
        }
from app.services import FirebaseService
from app.services import CloudinaryService
from app.imports import List

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

    def get_inspections_by_engineer(self, engineer_id: str, limit: int = None):
        return self._firebase.inspections_collection.get_inspections_by_eng_id(engineer_id, limit)

    def add_inspection(self, inspection) -> str:
        return self._firebase.inspections_collection.add_inspection(inspection)







from server_backend.services import FirebaseService
from server_backend.services.cloudinary_service import CloudinaryService

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
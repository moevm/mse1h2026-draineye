from server_backend.services import FirebaseService
from server_backend.services.cloudinary_service import CloudinaryService
from server_backend.imports import Optional, List, UploadFile, Tuple
from server_backend.models import Inspection, User
from server_backend.models.user import UserRole
from server_backend.schemas import InspectionSchema

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
        self.log_activity(engineer_id)
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
        inspection_schema: InspectionSchema,
        files: Optional[List[UploadFile]] = None
    ) -> dict:
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
        self.log_activity(inspection.engineer_id)
        return {
            "inspection_id": inspection_id,
            "photo_urls": photo_urls,
            "status": "created"
        }

    def verify_token(self, token: str) -> Optional[str]:
        return self._firebase.verify_token(token)

    def get_user(self, uid: str):
        return  self._firebase.get_user_by_uid(uid)

    def log_activity(self, uid: str):
        return self._firebase.log_activity(uid)

    def get_dashboard_metrics(self) -> dict:
        try:
            active_inspectors = self._firebase.get_active_inspectors_count()
            total_inspections = self._firebase.get_inspections_count()
            today_inspections = self._firebase.get_today_inspections_count()
            return {
                "active_inspectors": active_inspectors,
                "total_inspections": total_inspections,
                "inspections_today": today_inspections
            }
        except Exception as e:
            raise e

    def get_users_by_role_paginated(
            self, role: UserRole, limit: int, next_cursor: Optional[List],active_only: bool
    ) -> Tuple[List[User], Optional[List]]:
        return self._firebase.get_users_by_role_paginated(
            role=role,
            limit=limit,
            next_cursor=next_cursor,
            active_only=active_only
        )

    def get_all_inspections_paginated_with_engineer(
         self,limit: int, next_cursor: Optional[List],
    ) -> Tuple[List[Tuple[Inspection, Optional[User]]], Optional[List]]:
        return self._firebase.get_all_inspections_paginated_with_engineer(
            limit=limit,
            next_cursor=next_cursor,
        )
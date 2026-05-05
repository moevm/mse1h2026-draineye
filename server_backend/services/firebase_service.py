from server_backend.imports import firebase_admin, auth
from server_backend.imports import credentials, firestore, datetime, timezone, Optional, Tuple, List
from server_backend.repositories import UsersCollection, InspectionsCollection
from server_backend.models.user import User, UserRole
from server_backend.config import settings
from server_backend.models import Inspection

'''
cинглтон-сервис для управления подключением к Firebase и доступа к коллекциям
Обеспечивает единую точку входа для всех операций с Firebase во всем приложении
'''
class FirebaseService:
    _instance = None
    '''контролирует создание экземпляра класса'''
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._init_firebase()

        return cls._instance

    '''инициализирует подключение к Firebase'''
    def _init_firebase(self):
        self._collections = {}
        self._app = None
        self._db = None
        try:
            self._app = firebase_admin.get_app()
        except ValueError:
            cred_path = settings.FIREBASE_CREDENTIALS_PATH
            cred = credentials.Certificate(cred_path)
            self._app = firebase_admin.initialize_app(
                cred,
                {'storageBucket': f"{settings.PROJECT_GOOGLE_ID}.appspot.com"}
            )
        self._db = firestore.client(app=self._app, database_id='dev-bd')

    '''для доступа к коллекции пользователей'''
    @property
    def users_collection(self) -> UsersCollection:
        if 'users' not in self._collections:
            self._collections['users'] = UsersCollection(self._db)
        return self._collections['users']

    '''создаёт пользователя в Firebase Auth и сохраняет профиль в Firestore'''
    def register_user(self, email: str, password: str, full_name: str, role: UserRole) -> str:
        if self.is_email_taken(email):
            raise ValueError("Email уже зарегистрирован")

        self.validate_password(password)

        user_record = auth.create_user(
            email=email,
            password=password,
            display_name=full_name
        )
        new_user = User(
            user_id=user_record.uid,
            email=email,
            full_name=full_name,
            role=role,
            created_at=datetime.now(timezone.utc),
            last_activity=datetime.now(timezone.utc),
            is_active=True
        )

        return self.users_collection.add_user(new_user)

    '''проверяет, занят ли email в Firebase Auth'''
    def is_email_taken(self, email: str) -> bool:
        try:
            auth.get_user_by_email(email)
            return True
        except auth.UserNotFoundError:
            return False
        except Exception:
            return True

    '''валидация пароля'''
    def validate_password(self, password: str):
        if len(password) < 8:
            raise ValueError("Минимум 8 символов")
        if not any(c.isdigit() for c in password):
            raise ValueError("Нужна хотя бы одна цифра")
        if not any(c.isupper() for c in password):
            raise ValueError("Пароль должен содержать заглавную букву")

    def get_user_by_uid(self, uid: str) -> Optional[User]:
        return self.users_collection.get_by_uid(uid)

    '''регистрирует инспектора'''
    def register_inspector(self, email: str, password: str, full_name: str) -> str:
        return self.register_user(email, password, full_name, UserRole.INSPECTOR)

    '''регистрирует администратора'''
    def register_admin(self, email: str, password: str, full_name: str) -> str:
        return self.register_user(email, password, full_name, UserRole.ADMIN)

    '''обновляет время последней активности пользователя'''
    def log_activity(self, uid: str):
        self.users_collection.update_activity(uid)

    '''верифицирует ID-токен и возвращает UID'''
    def verify_token(self, token: str) -> Optional[str]:
        try:
            decoded_token = auth.verify_id_token(token)
            return decoded_token['uid']
        except Exception:
            return None

    '''для доступа к коллекции инспекций'''
    @property
    def inspections_collection(self) -> InspectionsCollection:
        if 'inspections' not in self._collections:
            self._collections['inspections'] = InspectionsCollection(self._db)
        return self._collections['inspections']

    '''метод для выдачи инспекций по инженеру из хранилища'''
    def get_inspections_by_engineer(self, engineer_id: str, limit: int = None):
        return self.inspections_collection.get_inspections_by_eng_id(engineer_id, limit)

    '''метод для добавления инспеции'''
    def add_inspection(self, inspection: Inspection) -> str:
        self.users_collection.increment_inspections(inspection.engineer_id)
        return self.inspections_collection.add_inspection(inspection)

    def get_users_by_role_paginated(
        self, role: UserRole, limit: int, next_cursor: Optional[List], active_only: bool
    ) -> Tuple[List[User], Optional[List]]:
        return self.users_collection.get_inspectors_paginated(
            role=role,
            limit=limit,
            next_cursor=next_cursor,
            active_only=active_only
        )

    def get_all_inspections_paginated_with_engineer(
        self, limit: int, next_cursor: Optional[List]
    ) -> Tuple[List[Tuple[Inspection, Optional[User]]], Optional[List]]:
        inspections, raw_cursor = self.inspections_collection.get_all_inspections_paginated(
            limit=limit,
            next_cursor=next_cursor,
        )

        result_pairs = []
        for insp in inspections:
            engineer_user = None
            if insp.engineer_id:
                engineer_user = self.users_collection.get_by_uid(insp.engineer_id)
            result_pairs.append((insp, engineer_user))

        return result_pairs, raw_cursor
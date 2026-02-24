from app.imports import firebase_admin
from app.imports import credentials, firestore
from app.repositories import UsersCollection, InspectionsCollection
from app.config import settings

'''
cинглтон-сервис для управления подключением к Firebase и доступа к коллекциям
Обеспечивает единую точку входа для всех операций с Firebase во всем приложении
'''
class FirebaseService:
    _instance = None
    _app = None
    _db = None
    _collections = {}

    '''контролирует создание экземпляра класса'''
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._init_firebase()

        return cls._instance

    '''инициализирует подключение к Firebase'''
    def _init_firebase(self):
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

    '''для доступа к коллекции инспекций'''
    @property
    def inspections_collection(self) -> InspectionsCollection:
        if 'inspections' not in self._collections:
            self._collections['inspections'] = InspectionsCollection(self._db)
        return self._collections['inspections']

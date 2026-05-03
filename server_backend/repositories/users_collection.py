from google.cloud import firestore
from server_backend.imports import Optional, List
from server_backend.repositories.base_collection import BaseCollection
from server_backend.models.user import User, UserRole

class UsersCollection(BaseCollection):
    def __init__(self, db: firestore.Client):
        super().__init__(db, "users", User)

    '''получает пользователя по email'''
    def get_by_email(self, email: str, role: UserRole = UserRole.INSPECTOR) -> Optional[User]:
        docs = self.collection.where("email", "==", email).where("role", "==", role.value).limit(1).stream()
        for doc in docs:
            return User.from_dict(doc)
        return None

    '''получает список пользователей по полному имени'''
    def get_by_full_name(self, full_name: str, role: UserRole = UserRole.INSPECTOR) -> List[User]:
        docs = self.collection.where("full_name", "==", full_name).where("role", "==", role.value).stream()
        return [User.from_dict(doc) for doc in docs]

    '''получает пользователя по UID из Firestore'''
    def get_by_uid(self, uid: str) -> Optional[User]:
        doc = self.collection.document(uid).get()
        if not doc.exists:
            return None
        return User.from_dict(doc)

    '''получает список активных пользователей по роли'''
    def get_active_by_role(self, role: UserRole, limit: int = None) -> List[User]:
        query = self.collection.where("role", "==", role.value).where("is_active", "==", True)
        if limit:
            query = query.limit(limit)
        return [User.from_dict(doc) for doc in query.stream()]

    '''обновляет время последней активности пользователя'''
    def update_activity(self, user_id: str):
        from datetime import datetime, timezone
        self.collection.document(user_id).update({
            "last_activity": datetime.now(timezone.utc).isoformat()
        })

    '''увеличивает счётчик инспекций на 1'''
    def increment_inspections(self, user_id: str):
        self.collection.document(user_id).update({
            "count_inspections": firestore.Increment(1)
        })

    '''меняет роль пользователя'''
    def change_role(self, user_id: str, new_role: UserRole):
        self.collection.document(user_id).update({
            "role": new_role.value
        })
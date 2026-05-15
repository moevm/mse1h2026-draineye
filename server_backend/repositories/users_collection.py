from google.cloud import firestore
from server_backend.imports import Optional, List, FieldFilter, Tuple
from server_backend.repositories.base_collection import BaseCollection
from server_backend.models.user import User, UserRole

class UsersCollection(BaseCollection):
    def __init__(self, db: firestore.Client):
        super().__init__(db, "users", User)

    '''добавление пользователя'''
    def add_user(self, user: User):
        doc_ref = self.collection.document(user.user_id)
        doc_ref.set(user.to_dict())
        return user.user_id

    '''получение пользователя по email'''
    def get_by_email(self, email: str, role: UserRole = UserRole.INSPECTOR) -> Optional[User]:
        users = self.get_by_field("email", email, limit=1)
        for user in users:
            if user.role == role:
                return user
        return None

    '''получения списка пользователей по полному имени и роли'''
    def get_by_full_name(self, full_name: str, role: UserRole = UserRole.INSPECTOR) -> List[User]:
        users = self.get_by_field("full_name", full_name)
        return [user for user in users if user.role == role]

    '''получение пользователя по UID из Firestore'''
    def get_by_uid(self, uid: str) -> Optional[User]:
        return self.get_by_id(uid)

    '''получения списка активных пользователей по роли'''
    def get_active_by_role(self, role: UserRole, limit: int = None) -> List[User]:
        all_with_role = self.get_by_field("role", role.value, limit=limit)
        return [user for user in all_with_role if user.is_active]

    '''обновление время последней активности пользователя'''
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

    '''удаляет пользователя по UID'''
    def delete_user(self, user_id: str) -> bool:
        return self.delete_by_id(user_id)

    '''удаляет всех пользователей в коллекции'''
    def delete_all_users(self) -> int:
        return self.delete_all_test()

    '''количество активных инспекторов'''
    def get_active_inspectors_count(self) -> int:
        query = self.collection \
            .where(filter=FieldFilter("role", "==", UserRole.INSPECTOR)) \
            .where(filter=FieldFilter("is_active", "==", True))
        snapshot = query.count().get()
        return snapshot[0][0].value

    '''все инспекторы с сохранением прогресса'''
    def get_inspectors_paginated(
        self,
        role: UserRole = UserRole.INSPECTOR,
        limit: int = 50,
        next_cursor: Optional[List] = None,  # [last_activity_iso_str, user_id]
        active_only: bool = True
    ) -> Tuple[List[User], Optional[List]]:

        query = self.collection
        query = query.where(filter=FieldFilter("role", "==", role.value))
        if active_only:
            query = query.where(filter=FieldFilter("is_active", "==", True))

        query = query.order_by("last_activity", direction=firestore.Query.DESCENDING)
        query = query.order_by("__name__", direction=firestore.Query.DESCENDING)

        if next_cursor:
            query = query.start_after(next_cursor)

        query = query.limit(limit + 1)
        docs = list(query.stream())
        has_more = len(docs) > limit
        if has_more:
            docs = docs[:limit]

        users = [self.model_cls.from_dict(doc) for doc in docs]

        next_c = None
        if has_more and docs:
            last_doc = docs[-1]
            next_c = [last_doc.get("last_activity"), last_doc.id]

        return users, next_c
from server_backend.imports import Optional, Enum, datetime, timezone, Any
from dataclasses import *

'''роли пользователей'''
class UserRole(str, Enum):
    INSPECTOR = "inspector"
    ADMIN = "admin"

'''
класс, представляющий пользователя системы (инженера или администратора)
'''
@dataclass
class User:
    email: str
    full_name: str
    role: UserRole
    user_id: Optional[str] = None
    count_inspections: int = 0
    created_at: Optional[datetime] = None
    last_activity: Optional[datetime] = None
    is_active: bool = True

    '''конвертирует datetime в ISO-строку'''
    @staticmethod
    def _dt_to_iso(dt: Optional[datetime]) -> Optional[str]:
        if dt is None:
            return None
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        return dt.isoformat()

    '''парсит значение из Firestore в datetime'''
    @staticmethod
    def _parse_dt(value) -> Optional[datetime]:
        if value is None:
            return None
        if isinstance(value, datetime):
            return value
        if isinstance(value, str):
            return datetime.fromisoformat(value.replace("Z", "+00:00"))
        return None

    '''преобразует объект User в словарь для сохранения в Firestore'''
    def to_dict(self) -> dict:
        return {
            "email": self.email,
            "full_name": self.full_name,
            "role": self.role.value if isinstance(self.role, UserRole) else self.role,
            "count_inspections": self.count_inspections,
            "created_at": self._dt_to_iso(self.created_at),
            "last_activity": self._dt_to_iso(self.last_activity),
            "is_active": self.is_active,
        }

    '''создает объект User из документа Firestore'''
    @classmethod
    def from_dict(cls, doc: Any):
        data = doc.to_dict()
        if not data:
            return None
        return cls(
            user_id=doc.id,
            email=data["email"],
            full_name=data["full_name"],
            role=UserRole(data["role"]),
            count_inspections=data.get("count_inspections", 0),
            created_at=cls._parse_dt(data.get("created_at")),
            last_activity=cls._parse_dt(data.get("last_activity")),
            is_active=data.get("is_active", True),
        )

    '''обновляет время последней активности"'''
    def update_activity(self):
        self.last_activity = datetime.now(timezone.utc)

    '''проверка на админа'''
    def is_admin(self) -> bool:
        return self.role == UserRole.ADMIN

    '''возвращает email пользователя'''
    def get_email(self) -> str:
        return self.email

    '''возвращает полное имя пользователя'''
    def get_full_name(self) -> str:
        return self.full_name

    '''возвращает роль пользователя'''
    def get_role(self) -> UserRole:
        return self.role

    '''возвращает идентификатор пользователя (UID из Firebase Auth)'''
    def get_user_id(self) -> Optional[str]:
        return self.user_id

    '''возвращает количество выполненных инспекций'''
    def get_count_inspections(self) -> int:
        return self.count_inspections

    '''возвращает дату и время создания профиля'''
    def get_created_at(self) -> Optional[datetime]:
        return self.created_at

    '''возвращает время последней активности'''
    def get_last_activity(self) -> Optional[datetime]:
        return self.last_activity

    '''возвращает статус активности пользователя'''
    def get_is_active(self) -> bool:
        return self.is_active
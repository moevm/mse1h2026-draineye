from app.imports import Optional
from dataclasses import *

'''
класс, представляющий пользователя системы (инженера или администратора)
'''
@dataclass
class User:
    email: str
    full_name: str
    role: str
    user_id: Optional[str] = None
    count_inspections: int = 0

    """преобразует объект User в словарь для сохранения в Firestore"""
    def to_dict(self):
        return {
            "email": self.email,
            "full_name": self.full_name,
            "role": self.role,
            "count_inspections": self.count_inspections,
        }

    """создает объект User из документа Firestore"""
    @classmethod
    def from_dict(cls,  doc):
        data = doc.to_dict()
        return cls(
            user_id = doc.id,
            email = data["email"],
            full_name = data["full_name"],
            role = data["role"],
            count_inspections = data["count_inspections"]
        )


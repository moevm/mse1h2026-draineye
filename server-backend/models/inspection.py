from dataclasses import dataclass
from app.imports import datetime, List, Optional

'''
класс для хранения вердикта, вынесенного ML моделью
'''
@dataclass
class ModelVerdict:
    material: str
    state: int
    accuracy: float
    comments: str

    """преобразует объект ModelVerdict в словарь"""
    def to_dict(self):
        return {
            "material": self.material,
            "state": self.state,
            "accuracy": self.accuracy,
            "comments": self.comments
        }

    """создает объект ModelVerdict из словаря"""
    @classmethod
    def from_dict(cls, data):
        return cls(
            material = data["material"],
            state = data["state"],
            accuracy = data["accuracy"],
            comments= data["comments"]
        )

'''
класс, представляющий полную информацию об инспекции 
'''
@dataclass
class Inspection:
    engineer_id: str
    timestamp: datetime
    model_verdict: ModelVerdict
    address: str
    name: str
    photos: List[str]
    status_sync: str
    inspection_id: Optional[str] = None

    """преобразует объект Inspection в словарь для сохранения в Firestore"""
    def to_dict(self):
        return {
            'engineer_id': self.engineer_id,
            'timestamp': self.timestamp.isoformat(),
            'model_verdict': self.model_verdict.to_dict(),
            'address': self.address,
            'name': self.name,
            'photos': self.photos.copy(),
            'status_sync': self.status_sync
        }

    """создает объект Inspection из документа Firestore"""
    @classmethod
    def from_dict(cls, doc):
        data = doc.to_dict()
        return cls(
            inspection_id=doc.id,
            engineer_id=data['engineer_id'],
            timestamp=datetime.fromisoformat(data['timestamp']),
            model_verdict=ModelVerdict.from_dict(data['model_verdict']),
            address=data['address'],
            name = data['name'],
            photos=data['photos'].copy(),
            status_sync=data['status_sync']
        )
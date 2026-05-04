from dataclasses import dataclass
from server_backend.imports import datetime, List, Optional
from server_backend.schemas import InspectionSchema, ModelVerdictSchema

'''
класс для хранения вердикта, вынесенного ML моделью
'''
@dataclass
class ModelVerdict:
    material: str
    state: int
    damage_type: str
    damage_degree: float
    accuracy_model: float
    comments: str
    """преобразует объект ModelVerdict в словарь"""
    def to_dict(self):
        return {
            "material": self.material,
            "state": self.state,
            "accuracy_model": self.accuracy_model,
            "damage_degree": self.damage_degree,
            "damage_type": self.damage_type,
            "comments": self.comments
        }

    """создает объект ModelVerdict из словаря"""
    @classmethod
    def from_dict(cls, data):
        return cls(
            material = data["material"],
            state = data["state"],
            damage_type = data["damage_type"],
            damage_degree = data["damage_degree"],
            accuracy_model = data["accuracy_model"],
            comments= data["comments"]
        )

    '''преобразование из схемы'''
    @classmethod
    def from_schema(cls, schema):
        return cls(
            material=schema.material,
            state=schema.state,
            damage_type=schema.damage_type,
            damage_degree=schema.damage_degree,
            accuracy_model=schema.accuracy_model,
            comments=schema.comments
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

    '''преобразование из схемы'''
    @classmethod
    def from_schema(cls, schema: InspectionSchema, photos: List[str] = None):
        return cls(
            engineer_id=schema.engineer_id,
            timestamp=schema.timestamp,
            model_verdict=ModelVerdict.from_schema(schema.model_verdict),
            address=schema.address,
            name=schema.name,
            photos=photos or schema.photos,
            status_sync=schema.status_sync
        )

from google.cloud import firestore
from google.cloud.firestore_v1 import FieldFilter
from app.imports import Optional, Any, List
'''
базовый класс для работы с коллекциями Firestore,
реализующий общие CRUD операции для всех моделей данных
'''
class BaseCollection:
    def __init__(self, db: firestore.Client, collection_name: str, model_cls):
        self.collection = db.collection(collection_name)
        self.model_cls = model_cls

    '''получение элемента хранилища по id'''
    def get_by_id(self, doc_id: str):
        doc = self.collection.document(doc_id).get()
        return self.model_cls.from_dict(doc) if doc.exists else None

    '''выдача элемента по полю'''
    def get_by_field(self, field: str, value: Any, limit: Optional[int] = None) -> List[Any]:
        query = self.collection.where(filter=FieldFilter(field, "==", value))
        if limit:
            query = query.limit(limit)
        docs = query.stream()
        return [self.model_cls.from_dict(doc) for doc in docs]

    '''выдача всех элементов хранилища'''
    def get_all(self, limit: Optional[int] = None) -> List[Any]:
        query = self.collection
        if limit:
            query = query.limit(limit)
        docs = query.stream()
        return [self.model_cls.from_dict(doc) for doc in docs]

    '''проерка наличия элемента в хранилище'''
    def exists(self, doc_id: str) -> bool:
        doc = self.collection.document(doc_id).get()
        return doc.exists

    '''добавление элемента в хранилище'''
    def add(self, data: dict) -> str:
        doc = self.collection.document()
        doc.set(data)
        return doc.id


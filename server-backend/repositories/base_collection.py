from google.cloud import firestore

'''
базовый класс для работы с коллекциями Firestore,
реализующий общие CRUD операции для всех моделей данных
'''
class BaseCollection:
    def __init__(self, db: firestore.Client, collection_name: str, model_cls):
        self.collection = db.collection(collection_name)
        self.model_cls = model_cls

    '''примерная функция get по id'''
    def get(self, doc_id: str):
        doc = self.collection.document(doc_id).get()
        return self.model_cls.from_dict(doc.to_dict()) if doc.exists else None



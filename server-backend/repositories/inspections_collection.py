from google.cloud import firestore
from app.models import Inspection
from app.repositories import BaseCollection

'''
класс для работы с коллекцией "inspections" в Firestore,
наследует базовые методы от BaseCollection и добавляет специфичные для инспекций операции
'''
class InspectionsCollection(BaseCollection):
    def __init__(self, db: firestore.Client):
        super().__init__(db, "inspections", Inspection)
    '''получает все инспекции конкретного инженера по его ID'''
    def get_inspections_by_eng_id(self, engineer_id):
        docs = self.collection.where("engineer_id", "==", engineer_id).stream()
        return [self.model_cls.from_dict(doc) for doc in docs]

    '''добавление инспекции'''
    def add_inspection(self, inspection: dict):
        doc = self.collection.document()
        doc.set(inspection)

    '''удаление всех инспекций'''
    def delete_all_inspections(self):
        docs = self.collection.stream()
        count = 0
        for doc in docs:
            doc.reference.delete()
            count += 1

        print(count)
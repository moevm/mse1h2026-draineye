from app.imports import Optional, Any, List
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
    def get_inspections_by_eng_id(self, engineer_id: str, limit: Optional[int] = None) -> List[Inspection]:
        return self.get_by_field("engineer_id", engineer_id, limit)
    '''получает все инспекции'''
    def get_all_inspections(self, limit: Optional[int] = None):
        return self.get_all(limit)
    def get_status_of_inspection(self, inspection_id: str):
        inspection = self.get_by_id(inspection_id)
        return inspection.status_sync
    '''добавление инспекции'''
    def add_inspection(self, inspection: Inspection) -> str:
        return self.add(inspection.to_dict())
    '''удаление всех инспекций'''
    def delete_all_inspections(self):
        docs = self.collection.stream()
        count = 0
        for doc in docs:
            doc.reference.delete()
            count += 1
        print(count)

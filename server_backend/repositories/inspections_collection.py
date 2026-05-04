from server_backend.imports import Optional, Any, List
from google.cloud import firestore
from server_backend.models import Inspection
from server_backend.repositories import BaseCollection

'''
класс для работы с коллекцией "inspections" в Firestore,
наследует базовые методы от BaseCollection и добавляет специфичные для инспекций операции
'''
class InspectionsCollection(BaseCollection):
    def __init__(self, db: firestore.Client):
        super().__init__(db, "inspections", Inspection)

    '''получение всех инспекций конкретного инженера по его ID'''
    def get_inspections_by_eng_id(self, engineer_id: str, limit: Optional[int] = None) -> List[Inspection]:
        return self.get_by_field("engineer_id", engineer_id, limit)

    '''получение всех инспекций'''
    def get_all_inspections(self, limit: Optional[int] = None):
        return self.get_all(limit)

    '''получение статуса инспекции'''
    def get_status_of_inspection(self, inspection_id: str):
        inspection = self.get_by_id(inspection_id)
        return inspection.status_sync

    '''добавление инспекции'''
    def add_inspection(self, inspection: Inspection) -> str:
        return self.add(inspection.to_dict())

    '''удаление инспекции'''
    def delete_inspection(self, inspection_id: str) -> bool:
        return self.delete_by_id(inspection_id)

    '''удаление всех инспекций'''
    def delete_all_inspections_test(self) -> int:
        return self.delete_all_test()

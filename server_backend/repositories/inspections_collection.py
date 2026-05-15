from server_backend.imports import Optional, List, datetime, timezone, Tuple
from google.cloud import firestore
from server_backend.models import Inspection, SyncStatus
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
    def add_inspection(self, inspection: Inspection) -> Tuple[str, SyncStatus]:
        inspection.timestamp = inspection.timestamp.astimezone(timezone.utc)
        inspection.status_sync = self.check_by_address(inspection)
        return self.add(inspection.to_dict()), inspection.status_sync

    '''удаление инспекции'''
    def delete_inspection(self, inspection_id: str) -> bool:
        return self.delete_by_id(inspection_id)

    '''удаление всех инспекций'''
    def delete_all_inspections_test(self) -> int:
        return self.delete_all_test()

    '''количество инспекций'''
    def get_inspections_count(self) -> int:
        return self.collection.count().get()[0][0].value

    '''количество инспекций сегодня'''
    def get_today_inspections_count(self) -> int:
        start_of_day = datetime.now(timezone.utc).replace(hour=0, minute=0, second=0, microsecond=0)
        query = self.collection.where("created_at", ">=", start_of_day)
        return query.count().get()[0][0].value

    '''все инспекции с сохранением прогресса'''
    def get_all_inspections_paginated(
        self,
        limit: int = 50,
        next_cursor: Optional[List] = None, # [timestamp, doc_id]
    ) -> Tuple[List[Inspection], Optional[List]]:
        query = self.collection

        query = query.order_by("timestamp", direction=firestore.Query.DESCENDING)
        query = query.order_by("__name__", direction=firestore.Query.ASCENDING)

        if next_cursor:
            query = query.start_after(next_cursor)

        query = query.limit(limit + 1)
        docs = list(query.stream())

        has_more = len(docs) > limit
        if has_more:
            docs = docs[:limit]

        inspections = [self.model_cls.from_dict(doc) for doc in docs]
        next_c = None
        if has_more and docs:
            last_doc = docs[-1]
            next_c = [last_doc.get("timestamp"), last_doc.id]

        return inspections, next_c

    '''проверка для синхронизации инспекции'''
    def check_by_address(self, inspection: Inspection) -> SyncStatus:
        query = (
            self.collection
            .where("address", "==", inspection.address)
            .order_by("timestamp", direction=firestore.Query.DESCENDING)
            .limit(1)
        )
        docs = list(query.stream())

        if not docs:
            return SyncStatus.SYNCED

        latest_doc = docs[0]
        latest_ts_raw = latest_doc.to_dict().get("timestamp")
        latest_ts = datetime.fromisoformat(latest_ts_raw)

        latest_ts = latest_ts.replace(tzinfo=None) if latest_ts.tzinfo else latest_ts
        new_ts = inspection.timestamp.replace(tzinfo=None)

        if latest_ts > new_ts:
            return SyncStatus.OUTDATED
        else:
            latest_doc.reference.update({"status_sync": SyncStatus.OUTDATED.value})
            return SyncStatus.SYNCED
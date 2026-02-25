from app.imports import FastAPI, Depends
from app.services import FirebaseService


server_app = FastAPI()

'''создание экземпляра FirebaseService'''
def create_firebase_service() -> FirebaseService:
    return FirebaseService()

'''endpoint для получения всех инспекций конкретного инженера'''
@server_app.get("/inspections_by_user/{id}")
def get_inspections(id: str, fs: FirebaseService = Depends(create_firebase_service)):
    inspections = fs.inspections_collection.get_inspections_by_eng_id(id)
    result = [inspection.to_dict() for inspection in inspections]
    return result

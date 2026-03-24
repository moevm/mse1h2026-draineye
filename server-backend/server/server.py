from app.services import StorageService
from app.imports import Optional, List
from app.imports import FastAPI, Depends, UploadFile, File, HTTPException, Form
from app.models import ModelVerdict, Inspection
from app.schemas import InspectionSchema, ModelVerdictSchema

server_app = FastAPI()

'''создание экземпляра FirebaseService'''
def create_storage_service() -> StorageService:
    return StorageService()

'''endpoint для получения всех инспекций конкретного инженера'''
@server_app.get("/inspections_by_user/{id}")
def get_inspections(id: str, ss: StorageService = Depends(create_storage_service)):
    result  = ss.get_inspections_by_engineer(id)
    return result

'''endpoint для добавления инспекции конкретного инженера'''
@server_app.post("/add_inspection", status_code=201)
async def create_inspection(
        inspection_json: str = Form(...),
        files: Optional[List[UploadFile]] = File(default=None),
        ss: StorageService = Depends(create_storage_service)
):
    try:
        inspection_schema = InspectionSchema.model_validate_json(inspection_json)
        inspection = Inspection.from_schema(inspection_schema)
        inspection_id = ss.add_inspection(inspection)

        if files and inspection_id:
            filenames = [f.filename for f in files if f and f.filename]
            public_ids = ss._cloudinary.generate_public_ids(
                filenames=filenames,
                engineer_id=inspection_schema.engineer_id,
                inspection_id=inspection_id
            )
            placeholder_urls = [pid for pid in public_ids]
            ss._firebase.inspections_collection.collection.document(inspection_id).update({
                "photos": placeholder_urls
            })
            await ss._cloudinary.upload_photos(files, public_ids)

        return {
            "inspection_id": inspection_id,
            "status": "created"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

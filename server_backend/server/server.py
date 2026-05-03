from server_backend.services import StorageService
from server_backend.imports import Optional, List
from server_backend.imports import FastAPI, Depends, UploadFile, File, HTTPException, Form
from server_backend.models import ModelVerdict, Inspection
from server_backend.schemas import InspectionSchema, ModelVerdictSchema

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


'''endpoint для регистрации инспектора'''
@server_app.post("/register/inspector", status_code=201)
def register_inspector(
    request: RegisterRequest,
    ss: StorageService = Depends(create_storage_service)
):
    try:
        uid = ss.register_inspector(
            email=str(request.email).strip().lower(),
            password=request.password,
            full_name=request.full_name
        )
        return {"user_id": uid, "status": "created", "role": "inspector"}

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ошибка сервера: {str(e)}")


'''endpoint для регистрации администратора'''
@server_app.post("/register/admin", status_code=201)
def register_admin(
    request: RegisterRequest,
    ss: StorageService = Depends(create_storage_service)
):
    try:
        uid = ss.register_admin(
            email=str(request.email).strip().lower(),
            password=request.password,
            full_name=request.full_name
        )
        return {"user_id": uid, "status": "created", "role": "admin"}

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ошибка сервера: {str(e)}")

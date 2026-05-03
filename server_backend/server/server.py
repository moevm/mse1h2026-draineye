from server_backend.services.storage_service import StorageService
from server_backend.imports import Optional, List
from server_backend.imports import FastAPI, Depends, UploadFile, File, HTTPException, Form
from server_backend.schemas.auth_request import RegisterRequest

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
        result = await ss.create_inspection_with_photos(inspection_json, files)
        return {
            "inspection_id": result["inspection_id"],
            "status": result["status"]
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
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

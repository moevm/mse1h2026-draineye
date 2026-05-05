from server_backend.services.storage_service import StorageService
from server_backend.imports import APIRouter, Depends, HTTPException, json
from server_backend.models import User
from server_backend.schemas.auth_request import RegisterRequest
from server_backend.server.auth import  require_admin
from server_backend.schemas.user_schema import PaginatedUsersResponse, UserListQueryParams, UserResponse
from server_backend.schemas.inspection_schema import PaginatedInspectionsResponse, InspectionListQueryParams, EngineerBriefResponse, InspectionResponse

router = APIRouter(
    prefix="/admin",
    tags=["Admin & Auth"]
)

'''создание экземпляра FirebaseService'''
def create_storage_service() -> StorageService:
    return StorageService()

'''endpoint для регистрации администратора'''
@router.post("/register", status_code=201)
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

@router.post("/login")
def login_admin(
    user: User = Depends(require_admin)
):
    return {
        "status": "success",
        "user_id": user.user_id,
        "role": user.role.value,
        "full_name": user.full_name,
        "email": user.email,
        "message": "Вход выполнен успешно"
    }

@router.get("/metrics/dashboard")
def get_dashboard_metrics(
    ss: StorageService = Depends(create_storage_service),
    user: User = Depends(require_admin)
):
    try:
        metrics_data = ss.get_dashboard_metrics()
        return metrics_data
    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Внутренняя ошибка сервера при получении метрик"
        )

@router.get("/users/by-role", response_model=PaginatedUsersResponse)
def get_users_by_role(
    ss: StorageService = Depends(create_storage_service),
    user: User = Depends(require_admin),
    params: UserListQueryParams = Depends(),
):
    parsed_cursor = json.loads(params.next_cursor) if params.next_cursor else None

    users_list, raw_next_cursor = ss.get_users_by_role_paginated(
        role=params.role,
        limit=params.limit,
        next_cursor=parsed_cursor,
        active_only=params.active_only
    )

    str_next = json.dumps(raw_next_cursor) if raw_next_cursor else None
    response_users = [UserResponse.model_validate(u) for u in users_list]

    return PaginatedUsersResponse(
        users=response_users,
        next_cursor=str_next,
        has_more=str_next is not None,
        total_returned=len(response_users)
    )

@router.get("/inspections", response_model=PaginatedInspectionsResponse)
def get_all_inspections(
    ss: StorageService = Depends(create_storage_service),
    user: User = Depends(require_admin),
    params: InspectionListQueryParams = Depends(),
):
    parsed_cursor = json.loads(params.next_cursor) if params.next_cursor else None

    pairs, raw_next_cursor = ss.get_all_inspections_paginated_with_engineer(
        limit=params.limit,
        next_cursor=parsed_cursor,
    )

    response_inspections = []
    for inspection, engineer_user in pairs:
        engineer_info = None
        if engineer_user:
            engineer_info = EngineerBriefResponse(
                user_id=engineer_user.user_id,
                full_name=engineer_user.full_name,
                email=engineer_user.email
            )

        verdict_dict = inspection.model_verdict.to_dict()

        resp_dict = {
            "id": inspection.inspection_id,
            "engineer_id": inspection.engineer_id,
            "timestamp": inspection.timestamp,
            "model_verdict": verdict_dict,
            "address": inspection.address,
            "name": inspection.name,
            "photos": inspection.photos,
            "status_sync": inspection.status_sync,
            "engineer": engineer_info
        }

        response_inspections.append(InspectionResponse.model_validate(resp_dict))

    str_next = json.dumps(raw_next_cursor) if raw_next_cursor else None

    return PaginatedInspectionsResponse(
        inspections=response_inspections,
        next_cursor=str_next,
        has_more=str_next is not None,
        total_returned=len(response_inspections)
    )

from server_backend.api import inspector_routes, admin_routes
from server_backend.imports import FastAPI
from fastapi.middleware.cors import CORSMiddleware

server_app = FastAPI()

server_app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r".*",
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

server_app.include_router(inspector_routes.router)
server_app.include_router(admin_routes.router)

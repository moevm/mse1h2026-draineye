from server_backend.api import inspector_routes, admin_routes
from server_backend.imports import FastAPI

server_app = FastAPI()

server_app.include_router(inspector_routes.router)
server_app.include_router(admin_routes.router)
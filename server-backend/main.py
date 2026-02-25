from app.imports import uvicorn
from app.config import settings
from tests.test_beta import test1
'''
запуск сервера и всей программы
'''
if __name__ == "__main__":
    test1()
    print("Запуск сервера...")
    uvicorn.run(
        "app.server.server:server_app",
        host=settings.SERVER_HOST,
        port=settings.SERVER_PORT,
    )




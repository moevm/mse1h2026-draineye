import uuid
from datetime import datetime, timezone

import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

from server_backend.config import settings


def _create_client():
    """
    Инициализация Firestore клиента
    """
    if not firebase_admin._apps:
        cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
        firebase_admin.initialize_app(
            cred,
            {"storageBucket": f"{settings.PROJECT_GOOGLE_ID}.appspot.com"},
        )

    return firestore.client(database_id="dev-bd")


def test_successful_access_to_model_verdicts():
    """
    Тест проверки подключения к базе данных вердиктов модели
    """
    db = _create_client()

    test_id = f"test-verdict-{uuid.uuid4()}"
    payload = {
        "engineer_id": "test-engineer",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "address": "test",
        "name": "test",
        "photos": [],
        "status_sync": "TEST_VERDICT_OK",
        "model_verdict": {
            "material": "test",
            "state": 0,
            "damage_type": "test",
            "damage_degree": 0.0,
            "accuracy_model": 1.0,
            "comments": "test",
        },
    }

    doc_ref = db.collection("inspections").document(test_id)
    try:
        doc_ref.set(payload)
        doc = doc_ref.get()
        assert doc.exists, "Ошибка: запись не создана"

        data = doc.to_dict()
        assert data["status_sync"] == "tets_verdict_ok"
        assert data["model_verdict"]["material"] == "test"
    finally:
        doc_ref.delete()
from google.cloud import firestore

from app.repositories.base_collection import BaseCollection
from app.models.user import User

class UsersCollection(BaseCollection):
    def __init__(self, db: firestore.Client):
        super().__init__(db, "users", User)


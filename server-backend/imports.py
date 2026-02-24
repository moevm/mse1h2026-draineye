from  typing import List, Optional
from datetime import datetime
from firebase_admin import firestore
from firebase_admin import credentials
import uvicorn
import firebase_admin
import os
from dotenv import load_dotenv
from pathlib import Path
from fastapi import FastAPI, Depends


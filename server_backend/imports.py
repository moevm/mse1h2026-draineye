from  typing import List, Optional, Any, Dict
from datetime import datetime
from firebase_admin import firestore
from firebase_admin import credentials
import uvicorn
import firebase_admin
import os, io
from dotenv import load_dotenv
from pathlib import Path
from fastapi import FastAPI, Depends, UploadFile, File, HTTPException, Form
from datetime import datetime
from pydantic import BaseModel
from enum import Enum
from datetime import timezone
from firebase_admin import auth